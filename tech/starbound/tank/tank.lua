function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  statModifierGroup = techConfig["statModifierGroup"]
  glow = "border=3;"..(techConfig["glow"] or "0000")..";0000"
  animator.setParticleEmitterOffsetRegion("boost", mcontroller.boundBox())
  groupId = effect.addStatModifierGroup({})
  script.setUpdateDelta(techConfig["scriptDelta"])
end

function update(dt)
  --TODO: How's it feel if we set it to not running and not walking rather than a velocity check, just in case someone uses a moving platform or is pushed? I don't thhink platforms affect what velocity checks return
  if math.floor(mcontroller.velocity()[1]) == 0 and not mcontroller.falling() and not mcontroller.jumping() then
    effect.setParentDirectives(glow)
    animator.setParticleEmitterActive("boost", true)
    effect.setStatModifierGroup(groupId, statModifierGroup)
  else
    animator.setParticleEmitterActive("boost", false)
    effect.setParentDirectives()
    effect.setStatModifierGroup(groupId, {})
  end
end