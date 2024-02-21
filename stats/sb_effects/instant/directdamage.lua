--TODO: we need this instead of using groundsmashdamage. make this and that script load a universal instant damage script and pass arguments to it! also direct looks nicer than the impact star of ground smash
function init()
  status.applySelfDamageRequest({
--    damageType = "direct",
    damage = math.floor(effect.duration()),
    damageSourceKind = "direct",
    sourceEntityId = effect.sourceEntity()
  })
  effect.expire()
  update=updat updat=nil
end
function updat() effect.expire() end