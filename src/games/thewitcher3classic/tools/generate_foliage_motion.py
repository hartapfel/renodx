"""Generate reviewed Classic SpeedTree motion wrappers from native DevKit exports.

Native code is included twice with renamed prior-state constants. Only the prior
clip output is consumed, letting FXC eliminate prior shading/texture work. The
native body stays single-source. Validate with tests/foliage_motion.cpp before
linking; signature matching alone is not deformation equivalence.
"""
import argparse
from pathlib import Path
import re
import shutil
from audit_motion_cache import container, signature as native_signature

VS = ['0x1E1A9ECC','0x7EDF0F66','0x934C6523','0x7DB7776C','0x3672ACC1','0x134AA93D']
PS = ['0x602B6AA4','0x03EAC234','0xCEC6D9F4','0x5B57A747']

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('originals',type=Path)
    parser.add_argument('--test-originals',type=Path)
    args=parser.parse_args()
    folder=Path(__file__).resolve().parents[1]/'temporal'
    for h in VS+PS:
        source=(args.originals/(h+'.hlsl')).read_text(encoding='utf-8')
        assert 'Needs manual' not in source and 'No code' not in source
        if h in VS:
            # Drop only unwritten padding lanes that an entry-point decompilation
            # may declare as float4. Helpers require fully initialized outputs.
            for semantic, index, _, _, register, mask, _ in native_signature(container((args.originals/(h+'.cso')).read_bytes()), b'OSGN'):
                count=mask.bit_count()
                assert mask==(1<<count)-1
                source=re.sub(r'out float[1-4]? o'+str(register)+r' :', 'out float'+(str(count) if count>1 else '')+' o'+str(register)+' :',source)
            header, body=source.split('void main(',1)
            signature, body=body.split(')\n{',1)
            inputs=re.findall(r'  (float[1-4]?) (v\d+) : (\w+)',signature)
            outputs=re.findall(r'  out (float[1-4]?) (o\d+) : (\w+)',signature)
            assert outputs[0][2]=='SV_POSITION0'
            assert 'o0' not in header
            # Native resources are shared: only prior CBs are needed for motion.
            header=re.sub(r'^(Sampler\w*<[^>]+>.*|Sampler\w+ .*|Texture\w+<[^>]+>.*)$',r'#ifndef FOLIAGE_PREVIOUS_DECL\n\1\n#endif',header,flags=re.M)
            native=header+'void main('+signature+')\n{'+body
            (folder/(h+'.native.hlsli')).write_text(native,encoding='utf-8')
            symbols=set(re.findall(r'\bm_\w+\b',header))
            symbols.update(re.findall(r'cbuffer (\w+)',header))
            symbols.update(x for x in ['pigmentWorldAreaScaleBias','terrainNormalsAreaParams','terrainNormalsParams','alphaScalarMulParams'] if x in header)
            remap={'b0':'b4','b1':'b5','b2':'b6','b3':'b7','b11':'b9'}
            remap.update({s:'previous_'+s for s in sorted(symbols)})
            text='// Native SpeedTree deformation evaluated at current and previous state.\n'
            text+='#define main EvaluateFoliageCurrent\n#include "./'+h+'.native.hlsli"\n#undef main\n\n'
            text+='#define FOLIAGE_PREVIOUS_DECL\n#define main EvaluateFoliagePrevious\n'
            text+=''.join('#define '+a+' '+b+'\n' for a,b in remap.items())
            text+='#include "./'+h+'.native.hlsli"\n'
            text+=''.join('#undef '+a+'\n' for a in remap)
            text+='#undef main\n#undef FOLIAGE_PREVIOUS_DECL\n\n'
            text+='cbuffer FoliageHistory : register(b8) { uint foliage_history; }\n'
            text+='cbuffer FoliagePreviousFrame : register(b10) { float4 foliage_previous_frame[269]; }\n\n'
            text+='void main('+signature+',\n  out float4 previous_clip : TEXCOORD10,\n  out nointerpolation float motion_history : TEXCOORD11)\n{\n'
            names=[x[1] for x in inputs]
            text+='  EvaluateFoliageCurrent('+', '.join(names+[x[1] for x in outputs])+');\n'
            text+='  motion_history = foliage_history;\n  previous_clip = float4(0, 0, 0, -1);\n  if (foliage_history != 0) {\n'
            text+=''.join('    '+t+' previous_'+n+';\n' for t,n,_ in outputs)
            text+='    EvaluateFoliagePrevious('+', '.join(names+['previous_'+x[1] for x in outputs])+');\n'
            text+='    previous_clip = previous_o0;\n    previous_clip.xy -= foliage_previous_frame[15].xy * previous_clip.w;\n  }\n}\n'
            (folder/(h+'.vs_5_0.hlsl')).write_text(text,encoding='utf-8')
        else:
            assert 'screenDimensions : packoffset(c23)' in source and 'projectionMatrix : packoffset(c13)' in source
            signature=source.split('void main(',1)[1].split(')\n{',1)[0]
            position=re.search(r'float4 (v\d+) : SV_POSITION0',signature,re.I)
            assert position and source.count('  return;')==1
            source=source.replace('void main(', '#define WITCHER_MOTION_DIMENSIONS screenDimensions.xy\n#define WITCHER_MOTION_JITTER projectionMatrix._m20_m21\n#include "./object_pixel.hlsli"\n\nvoid main(',1)
            source=re.sub(r'  out float4 o0 : SV_TARGET0,','  float4 previous_clip : TEXCOORD10,\n  nointerpolation float motion_history : TEXCOORD11,\n  out float4 o0 : SV_Target0,',source,count=1,flags=re.I)
            source=re.sub(r'  out float4 o2 : SV_TARGET2\)', '  out float4 o2 : SV_Target2,\n  out float2 object_motion : SV_Target3,\n  out float object_depth : SV_Target4)',source,count=1,flags=re.I)
            assert 'object_motion : SV_Target3' in source
            source=source.replace('  return;',f'  WriteObjectMotion({position[1]}, previous_clip, motion_history, object_motion, object_depth);\n  return;',1)
            (folder/(h+'.ps_5_0.hlsl')).write_text(source,encoding='utf-8')
        if args.test_originals:
            target=args.test_originals/(h+'.cso')
            if target.exists():assert target.read_bytes()==(args.originals/(h+'.cso')).read_bytes()
            else:shutil.copyfile(args.originals/(h+'.cso'),target)

if __name__=='__main__':main()
