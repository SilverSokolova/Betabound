function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  regen = techConfig["regenRate"] or 50
  resource = techConfig["resource"] or "energy"
  glow = "border=3;"..(techConfig["glow"] or "0000")..";0000"
  animator.setParticleEmitterOffsetRegion("regen", mcontroller.boundBox())
end

function update(dt)
  local v = mcontroller.velocity()[1]
  if math.floor(v) == 0 and not mcontroller.falling() and not mcontroller.jumping() and status.resourcePercentage(resource) ~= 1 then
    effect.setParentDirectives(glow)
    animator.setParticleEmitterActive("regen", true)
    status.modifyResource(resource, regen * dt)
  else
    animator.setParticleEmitterActive("regen", false)
    effect.setParentDirectives()
  end
end