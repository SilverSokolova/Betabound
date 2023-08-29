function init()
  if animator then animator.setParticleEmitterActive("particles",true) end
  effect.addStatModifierGroup({{stat=config.getParameter("stat","protection"),amount=config.getParameter("amount",5)}})
end