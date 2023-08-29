function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  statModifierGroup = techConfig["statModifierGroup"]
  glow = techConfig["glow"] or "0000"; glow = "border=3;"..glow..";0000"
  animator.setParticleEmitterOffsetRegion("boost", mcontroller.boundBox())
  groupId = effect.addStatModifierGroup({})
  script.setUpdateDelta(techConfig["scriptDelta"])
end

function update(dt)
  if math.floor(mcontroller.velocity()[1]) == 0 and not mcontroller.falling() and not mcontroller.jumping() then
    effect.setParentDirectives(glow)
    animator.setParticleEmitterActive("boost",true)
    effect.setStatModifierGroup(groupId, statModifierGroup)
  else
    animator.setParticleEmitterActive("boost",false)
    effect.setParentDirectives()
    effect.setStatModifierGroup(groupId, {})
  end
end