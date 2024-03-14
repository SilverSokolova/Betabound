function init()
  local immune = status.statPositive("sb_poisoncreepImmunity")
  local newEffect = config.getParameter(immune and "healEffect" or "poisonEffect")
  newEffect = immune and newEffect..(math.floor(effect.duration())) or newEffect
  status.addEphemeralEffect(newEffect)
  effect.expire()
end