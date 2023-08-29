local ini = init or function() end
local updat = update or function() end

function init() ini()
  lastVelocity = 0
  doubleTapTimer = 0
  groundsmashActive = false
  inputDown = false
  landingTimer = 0
  groundsmashSpeed = config.getParameter("groundsmashSpeed",250)
  groundsmashControlForce = config.getParameter("groundsmashControlForce",400)
  knockbackSpeed = config.getParameter("knockbackSpeed",50)
  knockbackRadius = config.getParameter("knockbackRadius",5)
  maxDoubleTapTime = config.getParameter("maxDoubleTapTime",0.2)
  knockbackOffset = config.getParameter("knockbackOffset",{0,-2})
  energyUsage = config.getParameter("energyCostPerSmash",0)

  --script.setUpdateDelta(1)
  animator.setParticleEmitterOffsetRegion("landParticles", {0, -2, 0, -2}) --Dust cloud near feet
end

function input(args)
  doubleTapTimer = doubleTapTimer - args.dt
  if args.moves["down"] and not mcontroller.onGround() then
    if not inputDown then
      if doubleTapTimer > 0 then
        inputDown = true
        return "groundsmash"
      else
        doubleTapTimer = maxDoubleTapTime
      end
      inputDown = true
    end
  else
    inputDown = false
  end
end

function update(args) updat(args)
  if input(args) == "groundsmash"
      and not mcontroller.onGround()
      and not groundsmashActive
      and not mcontroller.liquidMovement()
      and not mcontroller.flying()
      and not mcontroller.zeroG()
      and status.overConsumeResource("energy",energyUsage) then

    animator.playSound("falling")
    groundsmashActive = true
  end

  animator.setFlipped(mcontroller.facingDirection() < 0)
  if groundsmashActive and not mcontroller.onGround() then
    mcontroller.controlApproachYVelocity(-groundsmashSpeed, groundsmashControlForce)
    animator.setParticleEmitterActive("fallParticles", true)
    status.addEphemeralEffect("nofalldamage")
    status.addEphemeralEffect("sb_grit")
      if mcontroller.yVelocity() < lastVelocity then lastVelocity = mcontroller.yVelocity() end
      if mcontroller.yVelocity() > lastVelocity then groundsmashActive = false end
  elseif groundsmashActive or (groundsmashActive and (lastVelocity+30 > mcontroller.yVelocity()) and not mcontroller.isNullColliding()) then
    animator.burstParticleEmitter("landParticles", true)
    animator.playSound("landing")
    groundsmashActive = false
    lastVelocity = 0
--mcontroller.addMomentum({0,-lastVelocity+groundsmashSpeed})

    --TODO: Use force region here when/if we have radial ones. Is there a way for us to be immune to it?
    local position = vec2.add(mcontroller.position(), knockbackOffset)

    local nearEntities = world.entityQuery(position, knockbackRadius, {validTargetOf = entity.id(), includedTypes = {"monster", "npc", "player"}})
  --  if mcontroller.velocity()[2] > lastVelocity then groundsmashActive = false end
    for _, entityId in pairs(nearEntities) do
      local entityPosition = world.entityPosition(entityId)
      local toEntity = world.distance(entityPosition, position)
      local distance = world.magnitude(toEntity)
      if (distance < knockbackRadius and not world.lineTileCollision(position, entityPosition)) and world.entityCanDamage(entity.id(), entityId) then
        world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashknockbackX", vec2.mul(vec2.norm(toEntity), knockbackSpeed)[1])
        world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashknockbackY", vec2.mul(vec2.norm(toEntity), knockbackSpeed)[2])
        world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashdamage", (knockbackSpeed/2) + status.stat("powerMultiplier")*3) --TODO: entityid of player here
      end
    end
  else
    animator.setParticleEmitterActive("fallParticles", false)
  end
  lastVelocity = mcontroller.velocity()[2]
end