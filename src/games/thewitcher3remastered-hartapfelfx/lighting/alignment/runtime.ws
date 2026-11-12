// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// The generated map contains only verified flame-particle/spawner relationships.
// Resolve slots through the engine to include layer overrides and parent transforms.
@addField(CGameplayEntity)
private var hfLightAlignmentChecked : bool;

@addMethod(CGameplayEntity)
public function HFAlignLocalLights()
{
    var slots : array<name>;
    var offsets : array<Vector>;
    var positions : array<Vector>;
    var components : array<CComponent>;
    var light : CLightComponent;
    var slotMatrix : Matrix;
    var localToWorld : Matrix;
    var worldOrigin : Vector;
    var axisX : Vector;
    var axisY : Vector;
    var axisZ : Vector;
    var inverseX : Vector;
    var inverseY : Vector;
    var inverseZ : Vector;
    var delta : Vector;
    var determinant : float;
    var position : Vector;
    var nearest : Vector;
    var distance : float;
    var best : float;
    var maxDistance : float;
    var i : int;
    var j : int;

    if (hfLightAlignmentChecked || GetComponentsCountByClassName('CLightComponent') == 0)
        return;
    if (!HFAlignEmitterMap(this, slots, offsets, maxDistance))
    {
        hfLightAlignmentChecked = true;
        return;
    }
    for (i = 0; i < slots.Size(); i += 1)
    {
        if (CalcEntitySlotMatrix(slots[i], slotMatrix))
            positions.PushBack(VecTransform(slotMatrix, offsets[i]));
    }
    if (positions.Size() == 0)
        return;
    // Invert the full affine basis. MatrixGetInverted behaves as a rigid
    // inverse here and shrinks scaled shrine offsets by the scale squared.
    localToWorld = GetLocalToWorld();
    worldOrigin = MatrixGetTranslation(localToWorld);
    axisX = VecTransformDir(localToWorld, Vector(1.0, 0.0, 0.0, 0.0));
    axisY = VecTransformDir(localToWorld, Vector(0.0, 1.0, 0.0, 0.0));
    axisZ = VecTransformDir(localToWorld, Vector(0.0, 0.0, 1.0, 0.0));
    inverseX = VecCross(axisY, axisZ);
    inverseY = VecCross(axisZ, axisX);
    inverseZ = VecCross(axisX, axisY);
    determinant = VecDot(axisX, inverseX);
    if (AbsF(determinant) < 0.000001)
        return;
    components = GetComponentsByClassName('CLightComponent');
    for (i = 0; i < components.Size(); i += 1)
    {
        light = (CLightComponent)components[i];
        if (!light)
            continue;
        position = light.GetWorldPosition();
        best = maxDistance;
        for (j = 0; j < positions.Size(); j += 1)
        {
            distance = VecDistance(position, positions[j]);
            if (distance < best)
            {
                best = distance;
                nearest = positions[j];
            }
        }
        if (best > 0.001 && best < maxDistance)
        {
            delta = nearest - worldOrigin;
            light.SetPosition(Vector(VecDot(delta, inverseX) / determinant,
                                     VecDot(delta, inverseY) / determinant,
                                     VecDot(delta, inverseZ) / determinant, 1.0));
        }
    }
    hfLightAlignmentChecked = true;
}

// Newly streamed fixtures are handled as their native components become available.
@wrapMethod(CGameplayEntity)
function OnSpawned(spawnData : SEntitySpawnData)
{
    wrappedMethod(spawnData);
    HFAlignLocalLights();
}

// W3FireSource overrides OnSpawned without calling CGameplayEntity.OnSpawned.
// Cover streamed braziers even when the player is outside the fallback radius.
@wrapMethod(W3FireSource)
function OnSpawned(spawnData : SEntitySpawnData)
{
    wrappedMethod(spawnData);
    HFAlignLocalLights();
}

// Also cover restored fixtures and subclasses which do not call the base event.
// The per-entity flag prevents repeat slot resolution or transform writes.
@wrapMethod(W3PlayerWitcher)
function OnSpawned(spawnData : SEntitySpawnData)
{
    wrappedMethod(spawnData);
    AddTimer('HFAlignLightSweep', 5.0, true);
}

@addMethod(W3PlayerWitcher)
timer function HFAlignLightSweep(dt : float, id : int)
{
    var entities : array<CGameplayEntity>;
    var i : int;
    FindGameplayEntitiesInRange(entities, this, 60.0, 2048);
    for (i = 0; i < entities.Size(); i += 1)
    {
        if (entities[i])
            entities[i].HFAlignLocalLights();
    }
}

function HFAlignTemplateMatches(text : string, stem : string) : bool
{
    var index : int;
    var before : string;
    var after : string;
    index = StrFindFirst(text, stem);
    if (index == -1)
        return false;
    if (index > 0)
    {
        before = StrMid(text, index - 1, 1);
        if (StrFindFirst("abcdefghijklmnopqrstuvwxyz0123456789_", before) != -1)
            return false;
    }
    after = StrMid(text, index + StrLen(stem), 1);
    return after == "" || StrFindFirst("abcdefghijklmnopqrstuvwxyz0123456789_", after) == -1;
}
