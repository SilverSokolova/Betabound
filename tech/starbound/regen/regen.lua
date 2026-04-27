function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  regen = techConfig["regenRate"] or 50
  resource = techConfig["resource"] or "energy"
  glow = techConfig["glow"] and ("border=3;" .. techConfig["glow"] .. ";0000") or ""
  animator.setParticleEmitterOffsetRegion("regen", mcontroller.boundBox())
end

function update(dt)
  if not mcontroller.walking() and not mcontroller.running() and not mcontroller.falling() and not mcontroller.jumping() and status.resourcePercentage(resource) ~= 1 then
    effect.setParentDirectives(glow)
    animator.setParticleEmitterActive("regen", true)
    status.modifyResource(resource, regen * dt)
  else
    animator.setParticleEmitterActive("regen", false)
    effect.setParentDirectives()
  end
end