require "/tech/doubletap.lua"

function init()
  dashDirection = nil
  airDashing = false
  wasCrouching = false
  dashTimer = 0
  dashLastTechInput = 0
  dashCooldownTimer = 0
  rechargeEffectTimer = 0

  dashControlForce = config.getParameter("dashControlForce", 5)
  dashSpeed = config.getParameter("dashSpeed", 5)
  dashDuration = config.getParameter("dashDuration", 0.5)
  dashCooldown = config.getParameter("dashCooldown", 0)
  energyUsage = config.getParameter("energyUsage", 0)
  groundOnly = config.getParameter("groundOnly", true)
  canCrouchDash = config.getParameter("canCrouchDash", false)
  stopAfterDash = config.getParameter("stopAfterDash")
  hasRechargeAnimation = config.getParameter("hasRechargeAnimation")
  rechargeDirectives = config.getParameter("rechargeDirectives", "")
  rechargeEffectTime = config.getParameter("rechargeEffectTime", 0.1)
  maximumDoubleTapTime = config.getParameter("maximumDoubleTapTime", 0.2)

  doubleTap = DoubleTap:new({"left", "right"}, maximumDoubleTapTime, function(dir)
    if not status.statPositive("activeMovementAbilities") and dashTimer == 0 and dashCooldownTimer == 0 then
      local groundValid = not groundOnly or mcontroller.onGround()
      if groundValid and status.overConsumeResource("energy", energyUsage) then
        dashDirection = dir == "left" and -1 or 1
      end
    end
  end)
end


function update(args); doubleTap:update(args.dt, args.moves)
  --timers
  if dashCooldownTimer ~= 0 then
    dashCooldownTimer = math.max(0, dashCooldownTimer - args.dt)
    if dashCooldownTimer == 0 and hasRechargeAnimation then
      rechargeEffectTimer = rechargeEffectTime
      tech.setParentDirectives(rechargeDirectives)
      animator.playSound("recharge")
      animator.setAnimationState("recharge", "on")
    end
  end

  if rechargeEffectTimer ~= 0 then
    rechargeEffectTimer = math.max(0, rechargeEffectTimer - args.dt)
    if rechargeEffectTimer == 0 then
      tech.setParentDirectives()
    end
  end

  --dash
  if dashDirection and dashTimer == 0 and dashCooldownTimer == 0 then
    dashTimer = dashDuration
    airDashing = not mcontroller.onGround()
  end

  if dashTimer > 0 and dashDirection ~= nil then
    status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
    mcontroller.controlApproachXVelocity(dashSpeed * dashDirection, dashControlForce)

    if airDashing then
      mcontroller.setYVelocity(0)
    end

    mcontroller.controlFace(dashDirection)
    animator.setFlipped(mcontroller.facingDirection() == -1)
    animator.setAnimationState("dashing", "on")
    tech.setParentState(wasCrouching and "duck" or "run")
    animator.setParticleEmitterActive((wasCrouching and "crouch" or "") .. "dashParticles", true)
    animator.setParticleEmitterActive((wasCrouching and "dashParticles" or "crouchdashParticles"), false)
    dashCooldownTimer = dashCooldown
    dashTimer = math.max(0, dashTimer - args.dt)

    if dashTimer == 0 then
      dashCooldownTimer = dashCooldown
      if stopAfterDash then
        local movementParams = mcontroller.baseParameters()
        mcontroller.controlApproachXVelocity(dashDirection * movementParams.runSpeed, dashControlForce)
      end
      status.clearPersistentEffects("movementAbility")
      animator.setAnimationState("dashing", "off")
      tech.setParentState()
      animator.setParticleEmitterActive("dashParticles", false)
      animator.setParticleEmitterActive("crouchdashParticles", false)
      dashDirection = nil
    end
  end

  if canCrouchDash then
    wasCrouching = mcontroller.crouching()
  end
end

function uninit() status.clearPersistentEffects("movementAbility") end