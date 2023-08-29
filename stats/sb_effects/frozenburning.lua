function init()
  id = entity.id()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterOffsetRegion("frozenfiretrail", mcontroller.boundBox())
  effect.setParentDirectives("fade=AC00BF=0.25")
  
  script.setUpdateDelta(5)

  tickDamagePercentage = 0.05
  tickTime = 1.0
  tickTimer = tickTime
end

function update(dt)
  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    effect.expire()
  end
  
  mcontroller.controlModifiers({
    groundMovementModifier = 0.3,
    speedModifier = 0.75,
    airJumpModifier = 0.75
  })

  tickTimer = tickTimer - dt
  if tickTimer <= 0 then
    tickTimer = tickTime
    status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = math.floor(status.resourceMax("health") * tickDamagePercentage) + 3,
      damageSourceKind = "sb_frozenburning_"..(math.random(2)==1 and "fire" or "ice"),
      sourceEntityId = id
    })
  end
end