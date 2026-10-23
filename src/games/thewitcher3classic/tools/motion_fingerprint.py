"""Conservative scalar dataflow fingerprints for straight-line 3Dmigoto HLSL.

Compares the complete SV_Position expression, including skinning, deformation,
world/view matrices and input semantics. Temporary register names and unrelated
material outputs do not affect the fingerprint. Unsupported expressions remain
unknown; this is a review aid, never a runtime shader matcher.
"""
import ast
import re


class Fingerprinter:
    def __init__(self):
        self.nodes = {}

    def node(self, operation, *children):
        if None in children:
            return None
        key = (operation, *children)
        if key not in self.nodes:
            self.nodes[key] = len(self.nodes) + 1
        return self.nodes[key]

    def position(self, source):
        main = source[source.index('void main('):]
        signature, body = main.split('{', 1)
        values = {}
        for kind, name, semantic in re.findall(r'\b(float[1-4]?|uint[1-4]?)\s+(v\d+)\s*:\s*(\w+)', signature):
            width = int(kind[-1]) if kind[-1].isdigit() else 1
            values[name] = tuple(self.node('input', semantic.upper(), kind, index) for index in range(width))
        position = re.search(r'out float4 (o\d+) : SV_Position0', signature)
        if not position:
            raise ValueError('No native float4 position output')
        position = position[1]

        def broadcast(left, right):
            width = max(len(left), len(right))
            if len(left) not in (1, width) or len(right) not in (1, width):
                raise ValueError('Vector width mismatch')
            return zip(left * width if len(left) == 1 else left, right * width if len(right) == 1 else right)

        def evaluate(expr):
            if isinstance(expr, ast.Constant) and isinstance(expr.value, (int, float)):
                return (self.node('constant', float(expr.value)),)
            if isinstance(expr, ast.Name):
                if expr.id not in values:
                    raise ValueError('Unknown register ' + expr.id)
                return values[expr.id]
            if isinstance(expr, ast.Attribute) and re.fullmatch('[xyzw]{1,4}', expr.attr):
                vector = evaluate(expr.value)
                return tuple(vector['xyzw'.index(index)] for index in expr.attr)
            if isinstance(expr, ast.Subscript):
                index = evaluate(expr.slice)
                if len(index) != 1:
                    raise ValueError('Nonscalar buffer index')
                if isinstance(expr.value, ast.Name) and re.fullmatch(r'cb\d+', expr.value.id):
                    return tuple(self.node('cb', expr.value.id, index[0], component) for component in range(4))
                if isinstance(expr.value, ast.Attribute) and expr.value.attr == 'val':
                    buffer = expr.value.value
                    if isinstance(buffer, ast.Subscript) and isinstance(buffer.value, ast.Name):
                        return (self.node('structured', buffer.value.id, evaluate(buffer.slice)[0], index[0]),)
                raise ValueError('Unknown buffer access')
            if isinstance(expr, ast.BinOp):
                return tuple(self.node(type(expr.op).__name__, a, b) for a, b in broadcast(evaluate(expr.left), evaluate(expr.right)))
            if isinstance(expr, ast.UnaryOp):
                return tuple(self.node(type(expr.op).__name__, item) for item in evaluate(expr.operand))
            if isinstance(expr, ast.Call):
                args = [evaluate(arg) for arg in expr.args]
                if isinstance(expr.func, ast.Name):
                    name = expr.func.id
                    if re.fullmatch('(float|uint|int)[1-4]?', name):
                        width = int(name[-1]) if name[-1].isdigit() else 1
                        result = sum(args, ())
                        if len(result) == 1:
                            result *= width
                        if len(result) != width:
                            raise ValueError('Unsupported constructor')
                        return result if name.startswith('float') else tuple(self.node(name, item) for item in result)
                    if name == 'dot' and len(args) == 2 and len(args[0]) == len(args[1]):
                        return (self.node('dot', *sum(zip(args[0], args[1]), ())),)
                    if name in ('saturate', 'sqrt', 'rsqrt', 'abs', 'frac', 'floor') and len(args) == 1:
                        return tuple(self.node(name, item) for item in args[0])
                    if name in ('min', 'max') and len(args) == 2:
                        return tuple(self.node(name, a, b) for a, b in broadcast(*args))
                if isinstance(expr.func, ast.Attribute) and expr.func.attr == 'Load' and isinstance(expr.func.value, ast.Name):
                    return tuple(self.node('load', expr.func.value.id, *args[0], component) for component in range(4))
                raise ValueError('Unsupported function')
            raise ValueError('Unsupported expression')

        # Evaluate assignments in native order, preserving lane-level SSA state.
        # Poison unsupported expressions instead of accidentally matching them.
        depth = 0
        for line in body.splitlines():
            # Lighting branches can be unrelated to an already computed clip
            # position. Conservatively poison every register lane written in
            # control flow, rather than excluding the entire vertex shader.
            # A position depending on any such lane will still be rejected.
            conditional = depth > 0 or re.search(r'\b(if|else|for|while|switch)\b', line)
            if conditional:
                for name, mask in re.findall(r'([ro]\d+)(?:\.([xyzw]+))? = ', line):
                    previous = list(values.get(name, (None,) * 4))
                    for component in mask or 'xyzw':
                        previous['xyzw'.index(component)] = None
                    values[name] = tuple(previous)
            depth += line.count('{') - line.count('}')
            if conditional:
                continue
            match = re.fullmatch(r'\s*([ro]\d+)(?:\.([xyzw]+))? = (.*);\s*', line)
            if not match:
                continue
            name, mask, expression = match.groups()
            mask = mask or 'xyzw'
            expression = re.sub(r'\((uint[1-4]?|int[1-4]?|float[1-4]?)\)([vr]\d+\.[xyzw]+)', r'\1(\2)', expression)
            try:
                result = evaluate(ast.parse(expression, mode='eval').body)
                if len(result) == 1:
                    result *= len(mask)
                if len(result) != len(mask):
                    raise ValueError('Assignment width mismatch')
            except (SyntaxError, ValueError, IndexError):
                result = (None,) * len(mask)
            previous = list(values.get(name, (None,) * 4))
            for component, item in zip(mask, result):
                previous['xyzw'.index(component)] = item
            values[name] = tuple(previous)
        result = values.get(position)
        if not result or any(item is None for item in result):
            raise ValueError('Position could not be resolved')
        return result
