require "/tech/doubletap.lua"

--These hooks are here for the waterball tech
local originalInit = init or function() end
local originalUpdate = update or function() end

function init(); originalInit()
  groundSmashing = false
  groundsmashActive = false
  
  lastVelocity = 0
  landingTimer = 0
  groundsmashSpeed = config.getParameter("groundsmashSpeed", 250)
  groundsmashControlForce = config.getParameter("groundsmashControlForce", 400)
  groundsmashCooldownTime = config.getParameter("groundsmashCooldown", 0.2) --To prevent bouncing so fast the ground check misses
  groundsmashCooldownTimer = 0
  knockbackSpeed = config.getParameter("knockbackSpeed", 50)
  knockbackRadius = config.getParameter("knockbackRadius", 5)
  maximumDoubleTapTime = config.getParameter("maximumDoubleTapTime", 0.2)
  energyUsage = config.getParameter("energyCostPerSmash", 0)
  knockbackOffset = config.getParameter("knockbackOffset", {0, -2})
  mustBeActiveToSmash = config.getParameter("mustBeActiveToSmash", false)
  damagingSmash = config.getParameter("damagingSmash", true)

  animator.setParticleEmitterOffsetRegion("landParticles", {0, -2, 0, -2}) --Dust cloud near feet

  doubleTap = DoubleTap:new({"down"}, maximumDoubleTapTime, function()
    tryGroundsmash()
  end)
end

function tryGroundsmash()
  --for waterball
  local mustBeActiveToSmashCheck = true
  if mustBeActiveToSmash then
    mustBeActiveToSmashCheck = active
  end

  groundSmashing = groundsmashCooldownTimer == 0 and mustBeActiveToSmashCheck and not mcontroller.onGround()
end

function update(args); originalUpdate(args); doubleTap:update(args.dt, args.moves)
  if groundSmashing
    and not groundsmashActive
    and not mcontroller.onGround()
    and not mcontroller.liquidMovement()
    and not mcontroller.flying()
    and not mcontroller.zeroG()
    and ((mustBeActiveToSmash and active) or not status.statPositive("activeMovementAbilities")) --Seems redundant but isn't
    and status.overConsumeResource("energy", energyUsage)
  then
    animator.playSound("falling")
    groundsmashActive = true
    groundsmashCooldownTimer = groundsmashCooldownTime
  else
    groundsmashCooldownTimer = math.max(0, groundsmashCooldownTimer - args.dt)
    groundSmashing = false
  end

  animator.setFlipped(mcontroller.facingDirection() < 0)
  if groundsmashActive and not mcontroller.onGround() then
    mcontroller.controlApproachYVelocity(-groundsmashSpeed, groundsmashControlForce)
    animator.setParticleEmitterActive("fallParticles", true)
    status.addEphemeralEffect("nofalldamage")
    status.addEphemeralEffect("sb_grit")
    local currentVelocity = mcontroller.yVelocity()

    if currentVelocity > lastVelocity or (mustBeActiveToSmash and not active) then
      groundsmashActive = false
      groundSmashing = false
    elseif currentVelocity < lastVelocity then
      lastVelocity = currentVelocity
    end
  elseif groundsmashActive or (groundsmashActive and (lastVelocity > mcontroller.yVelocity() - 30) and not mcontroller.isNullColliding()) then
    groundsmashActive = false
    groundSmashing = false
    lastVelocity = 0

    if damagingSmash then
      animator.playSound("landing")
      animator.burstParticleEmitter("landParticles", true)
      --CF TODO: Use force region here when/if we have radial ones. Is there a way for us to be immune to it?
      local position = vec2.add(mcontroller.position(), knockbackOffset)

      local nearEntities = world.entityQuery(position, knockbackRadius, {validTargetOf = entity.id(), includedTypes = {"monster", "npc", "player"}})
      for _, entityId in pairs(nearEntities) do
        local entityPosition = world.entityPosition(entityId)
        local toEntity = world.distance(entityPosition, position)
        local distance = world.magnitude(toEntity)
        if (distance < knockbackRadius and not world.lineTileCollision(position, entityPosition)) and world.entityCanDamage(entity.id(), entityId) then
          world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashknockbackX", vec2.mul(vec2.norm(toEntity), knockbackSpeed)[1])
          world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashknockbackY", vec2.mul(vec2.norm(toEntity), knockbackSpeed)[2])
          world.sendEntityMessage(entityId, "applyStatusEffect", "sb_groundsmashdamage", (knockbackSpeed / 2) * status.stat("powerMultiplier")) --TODO: entityid of player here
        end
      end
    end
  else
    animator.setParticleEmitterActive("fallParticles", false)
  end
  lastVelocity = mcontroller.velocity()[2]
end