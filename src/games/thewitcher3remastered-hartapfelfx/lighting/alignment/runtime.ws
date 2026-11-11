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
    var worldToLocal : Matrix;
    var position : Vector;
    var nearest : Vector;
    var distance : float;
    var best : float;
    var i : int;
    var j : int;

    if (hfLightAlignmentChecked || GetComponentsCountByClassName('CLightComponent') == 0)
        return;
    if (!HFAlignEmitterMap(this, slots, offsets))
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
    worldToLocal = MatrixGetInverted(GetLocalToWorld());
    components = GetComponentsByClassName('CLightComponent');
    for (i = 0; i < components.Size(); i += 1)
    {
        light = (CLightComponent)components[i];
        if (!light)
            continue;
        position = light.GetWorldPosition();
        best = 4.0;
        for (j = 0; j < positions.Size(); j += 1)
        {
            distance = VecDistance(position, positions[j]);
            if (distance < best)
            {
                best = distance;
                nearest = positions[j];
            }
        }
        if (best > 0.001 && best < 4.0)
            light.SetPosition(VecTransform(worldToLocal, nearest));
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
