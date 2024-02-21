function init()
  airDashing = false
  wasCrouching = false
  dashTimer = 0
  dashDirection = 0
  dashLastInput = 0
  dashTapLast = 0
  dashTapTimer = 0
  dashCooldown = 0
  dashCooldownTimer = 0
  rechargeEffectTimer = 0
  dashControlForce = config.getParameter("dashControlForce",5)
  dashSpeed = config.getParameter("dashSpeed",5)
  dashDuration = config.getParameter("dashDuration",0.5)
  dashCooldown = config.getParameter("dashCooldown",0)
  energyUsage = config.getParameter("energyUsage",0)
  groundOnly = config.getParameter("groundOnly",true)
  canCrouchDash = config.getParameter("canCrouchDash",false)
  rechargeDirectives = config.getParameter("rechargeDirectives","")
  rechargeEffectTime = config.getParameter("rechargeEffectTime",0.1)
end

function input(args)
  if dashTimer > 0 then
    return nil
  end

  local maximumDoubleTapTime = config.getParameter("maximumDoubleTapTime",0.2)

  if dashTapTimer > 0 then
    dashTapTimer = dashTapTimer - args.dt
  end

  if not status.statPositive("activeMovementAbilities") and args.moves["right"] then
    if dashLastInput ~= 1 then
      if dashTapLast == 1 and dashTapTimer > 0 then
        dashTapLast = 0
        dashTapTimer = 0
  if status.overConsumeResource("energy", energyUsage) then return 1 end
      else
        dashTapLast = 1
        dashTapTimer = maximumDoubleTapTime
      end
    end
    dashLastInput = 1
  elseif not status.statPositive("activeMovementAbilities") and args.moves["left"] then
    if dashLastInput ~= -1 then
      if dashTapLast == -1 and dashTapTimer > 0 then
        dashTapLast = 0
        dashTapTimer = 0
  if status.overConsumeResource("energy", energyUsage) then return -1 end
      else
        dashTapLast = -1
        dashTapTimer = maximumDoubleTapTime
      end
    end
    dashLastInput = -1
  else
    dashLastInput = 0
  end
  return nil
end

function update(args)
  local action = input(args)

  local groundValid = not groundOnly or mcontroller.onGround()

  if dashCooldownTimer > 0 then
    dashCooldownTimer = dashCooldownTimer - args.dt 
    if dashCooldownTimer <= 0 then
      rechargeEffectTimer = rechargeEffectTime
      tech.setParentDirectives(rechargeDirectives)
      animator.playSound("recharge")
    end
  end

  if rechargeEffectTimer > 0 then
    rechargeEffectTimer = math.max(0, rechargeEffectTimer - args.dt)
    if rechargeEffectTimer <= 0 then
      tech.setParentDirectives()
    end
  end

  if (action == 1 or action == -1) and groundValid and dashTimer <= 0 and dashCooldownTimer <= 0 then
    dashTimer = dashDuration
    dashDirection = action or input(args)
    airDashing = not mcontroller.onGround()
  end

  if dashTimer > 0 and dashDirection ~= nil then
    status.setPersistentEffects("movementAbility",{{stat="activeMovementAbilities",amount=1}})
    mcontroller.controlApproachXVelocity(dashSpeed * dashDirection, dashControlForce)

    if airDashing then
  mcontroller.setYVelocity(0)
    end
    mcontroller.controlFace(dashDirection)
    animator.setFlipped(mcontroller.facingDirection() == -1)
    animator.setAnimationState("dashing", "on")
    tech.setParentState(wasCrouching and "duck" or "run")
    animator.setParticleEmitterActive((wasCrouching and "crouch" or "").."dashParticles", true)
    animator.setParticleEmitterActive((wasCrouching and "dashParticles" or "crouchdashParticles"), false)
    dashCooldownTimer = dashCooldown
    dashTimer = dashTimer - args.dt

    if dashTimer <= 0 then
      dashCooldownTimer = dashCooldown
      if config.getParameter("stopAfterDash") then
        local movementParams = mcontroller.baseParameters()
        mcontroller.controlApproachXVelocity(dashDirection * movementParams.runSpeed, dashControlForce)
       end
    status.clearPersistentEffects("movementAbility")
    animator.setAnimationState("dashing", "off")
    tech.setParentState()
    animator.setParticleEmitterActive("dashParticles", false)
    animator.setParticleEmitterActive("crouchdashParticles", false)
    end
  end
  wasCrouching = canCrouchDash and mcontroller.crouching()
end

function uninit() status.clearPersistentEffects("movementAbility") end