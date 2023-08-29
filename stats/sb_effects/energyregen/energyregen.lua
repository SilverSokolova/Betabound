function init()
  local regenAmount = config.getParameter("regenAmount",5)
  if animator then
    animator.setParticleEmitterOffsetRegion("energy",mcontroller.boundBox())
    animator.setParticleEmitterEmissionRate("energy",config.getParameter("emissionRate",5)+regenAmount)
  end
  effect.addStatModifierGroup({{stat="energyRegenPercentageRate",amount=regenAmount}})
end