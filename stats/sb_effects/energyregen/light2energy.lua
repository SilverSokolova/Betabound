function init()
  animator.setParticleEmitterOffsetRegion("energy", mcontroller.boundBox())
  animator.setParticleEmitterActive("energy", true)
  maxRegen = config.getParameter("maxRegenAmount", 5)
  maxEmission = config.getParameter("maxEmissionRate", maxRegen)
  group = effect.addStatModifierGroup({})
end

function update()
  local light = math.floor(world.lightLevel(mcontroller.position()) * 1000) * 0.01
  sb.setLogMap("^#ff0;sb_light", "%s/%s", light, maxRegen)
  effect.setStatModifierGroup(group, {{stat = "energyRegenPercentageRate", amount = math.max(0, math.min(light, maxRegen))}}) --I doubt this will ever be negative, but safety first!
  animator.setParticleEmitterEmissionRate("energy", 3 * math.min(light, maxEmission))
end