function init()
  active = false
  fireTimer = 0
  tech.setVisible(false)
 -- tech.rotateGroup("guns", 0, true)
  lastAction = {}
  flipped = false
  energyCostPerSecond = config.getParameter("energyCostPerSecond")
  mechCustomMovementParameters = config.getParameter("mechCustomMovementParameters")
  mechTransformPositionChange = config.getParameter("mechTransformPositionChange")
  polySize = #mechCustomMovementParameters.collisionPoly
--  parentOffset = config.getParameter("parentOffset",{})
  mechCollisionTest = config.getParameter("mechCollisionTest")
  mechAimLimit = config.getParameter("mechAimLimit") * math.pi / 180
  mechFrontRotationPoint = config.getParameter("mechFrontRotationPoint")
  mechFrontFirePosition = config.getParameter("mechFrontFirePosition")
  mechBackRotationPoint = config.getParameter("mechBackRotationPoint")
  mechBackFirePosition = config.getParameter("mechBackFirePosition")
  mechFireCycle = config.getParameter("mechFireCycle")
  mechProjectile = config.getParameter("mechProjectile")
  mechProjectileConfig = config.getParameter("mechProjectileConfig")
  supressTools = config.getParameter("supressTools",false)
end

function uninit()
  if active then
    status.clearPersistentEffects("movementAbility")
    mcontroller.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
    active = false
    animator.playSound("warp")
    tech.setVisible(false)
    tech.setParentState()
    tech.setToolUsageSuppressed(false)
  end
end

function input(args)
  if args.moves["special1"] and not lastAction["special1"] then
    if active then
--      animator.burstParticleEmitter("mechDeactivateParticles") --Okay, so, tech.setVisible hides everything, including the particles. I REALLY do not feel like adding an invisible state and adding a parameter for animation parts that exist, so for now...
      return "mechDeactivate"
    else
      return "mechActivate"
    end
  elseif args.moves["primaryFire"] then
    return "mechFire"
  end
  if args.moves["down"] and not lastAction["down"] then
    return "flip"
  end

  return nil
end

function update(args)
  local currentInput = input(args)
  for i = 1, polySize do world.debugText("^shadow;"..i,{entity.position()[1]+mechCustomMovementParameters.collisionPoly[i][1],entity.position()[2]+mechCustomMovementParameters.collisionPoly[i][2]},"green") end
  if not active and not status.statPositive("activeMovementAbilities") and currentInput == "mechActivate" and not mcontroller.zeroG() and not mcontroller.liquidMovement() then
    mechCollisionTest = config.getParameter("mechCollisionTest")
    mechCollisionTest[1] = mechCollisionTest[1] + entity.position()[1]
    mechCollisionTest[2] = mechCollisionTest[2] + entity.position()[2]
    mechCollisionTest[3] = mechCollisionTest[3] + entity.position()[1]
    mechCollisionTest[4] = mechCollisionTest[4] + entity.position()[2]
    if not world.rectCollision(mechCollisionTest) then
     animator.burstParticleEmitter("mechActivateParticles")
     mcontroller.translate(mechTransformPositionChange)
      animator.playSound("warp")
      tech.setVisible(true)
      tech.setParentState("sit")
      tech.setToolUsageSuppressed(supressTools)
      active = true
      status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
    else
--      animator.playSound("fail")
    end
  elseif active and (currentInput == "mechDeactivate") then
--or energyCostPerSecond * args.dt > status.overConsumeResource("energy",energyCostPerSecond)) then
    uninit()
  end

  if active and (currentInput == "flip") then
    for i = 1, polySize do mechCustomMovementParameters.collisionPoly[i][1] = -mechCustomMovementParameters.collisionPoly[i][1] end
    mcontroller.controlParameters(mechCustomMovementParameters)
    flipped = not flipped
    animator.setFlipped(flipped)
  end

  if active then
      animator.setParticleEmitterActive("mechNoEnergy",status.resourceLocked("energy"))
      local moving = ((mcontroller.walking() or mcontroller.running() or (math.floor(mcontroller.xVelocity()) < -1 or math.floor(mcontroller.xVelocity()) > 1)) and mcontroller.onGround())
      animator.setParticleEmitterActive("mechSmokeB",moving)
      animator.setParticleEmitterActive("mechSmokeF",moving)
      if moving then status.overConsumeResource("energy",0.001) end

    mcontroller.controlParameters(mechCustomMovementParameters)
    if flipped then
      mcontroller.controlFace(-1)
    else
      mcontroller.controlFace(1)
    end

    if not mcontroller.onGround() then
      if mcontroller.jumping() then
        animator.setAnimationState("movement", "jump")
	--tech.setParentOffset(parentOffset["jump"] or {0,0})
      elseif mcontroller.falling() then
        animator.setAnimationState("movement", "fall")
	--tech.setParentOffset(parentOffset["fall"] or {0,0})
      end
    elseif mcontroller.walking() or mcontroller.running() then
      if flipped and mcontroller.facingDirection() == 1 or not flipped and mcontroller.facingDirection() == -1 then
        animator.setAnimationState("movement", "backWalk")
	--tech.setParentOffset(parentOffset["backWalk"] or {0,0})
      else
        animator.setAnimationState("movement", "walk")
	--tech.setParentOffset(parentOffset["walk"] or {0,0})
      end
    else
      animator.setAnimationState("movement", "idle")
      --tech.setParentOffset(parentOffset["idle"] or {0,0}) --setting this every cycle doesn't seem that good of an idea!
    end
  end
  lastAction = args.moves
end