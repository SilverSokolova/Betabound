function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  statModifierGroup = techConfig["statModifierGroup"]
  glow = techConfig["glow"] and ("border=3;" .. techConfig["glow"] .. ";0000") or ""
  animator.setParticleEmitterOffsetRegion("boost", mcontroller.boundBox())
  groupId = effect.addStatModifierGroup({})
  groundTime = 0
  maxGroundTime = techConfig["maxGroundTime"]
  maxYVelocity = techConfig["maxYVelocity"]
end

function update(dt)
  --What's weird is that I tried having a timer- increment while moving, decrement otherwise- instead of just increasing scriptDelta. That somehow messes with the 'not falling not jumping' check, allowing the tech to briefly activate during the peak of a jump??

  if mcontroller.yVelocity() > maxYVelocity then
    groundTime = math.min(groundTime + dt, maxGroundTime)
  else
    groundTime = math.max(groundTime - dt, 0)
  end
  --No 'not falling not jumping' check because knockback could activate it
  if not mcontroller.walking() and not mcontroller.running() and groundTime < maxGroundTime then
    effect.setParentDirectives(glow)
    animator.setParticleEmitterActive("boost", true)
    effect.setStatModifierGroup(groupId, statModifierGroup)
  else
    animator.setParticleEmitterActive("boost", false)
    effect.setParentDirectives()
    effect.setStatModifierGroup(groupId, {})
  end
end