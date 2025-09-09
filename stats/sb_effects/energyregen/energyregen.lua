function init()
  local regenAmount = config.getParameter("regenAmount", 5)
  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", amount = regenAmount}})

  if animator then
    animator.setParticleEmitterOffsetRegion("energy", mcontroller.boundBox())
    animator.setParticleEmitterEmissionRate("energy", config.getParameter("emissionRate", 5) + regenAmount)
  end
end