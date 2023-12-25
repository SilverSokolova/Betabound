function init()
  effect.addStatModifierGroup({
    {stat = "invulnerable", amount = 1},
    {stat = "powerMultiplier", effectiveMultiplier = -1}
  })

  status.addEphemeralEffects({
    {effect = "camouflage35", duration = 3},
    {effect = "ghostlyglow", duration = 3}
  })
end

function onExpire()
  status.setPersistentEffects("sb_minibossglow", {"minibossglow"})
end