function init()
  status.applySelfDamageRequest({
  --damageType = "IgnoresDef",
  damage = effect.duration(),
  damageSourceKind = "impact",
  sourceEntityId = entity.id()
      })
  effect.expire()
  update=updat updat=nil
end
function updat() effect.expire() end
--world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashdamage", (knockbackSpeed/2) + status.stat("powerMultiplier")*2)