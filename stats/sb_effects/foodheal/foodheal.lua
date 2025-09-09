function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  script.setUpdateDelta(5)
  healingRate = config.getParameter("healAmount", 30) / (effect.duration() * 2)
end

function update(dt)
  status.modifyResource("health", healingRate * dt)
end