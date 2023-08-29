require "/scripts/vec2.lua"
function init()
  active = false
  fireTimer = 0
  tech.setVisible(false)
  lastAction = {}
  flipped = false
  energyCostPerSecond = config.getParameter("energyCostPerSecond")
  mechCustomMovementParameters = config.getParameter("mechCustomMovementParameters")
  mechTransformPositionChange = config.getParameter("mechTransformPositionChange")
  polySize = #mechCustomMovementParameters.collisionPoly
  parentOffset = config.getParameter("parentOffset",{0,0})
  mechCollisionTest = config.getParameter("mechCollisionTest")
  mechAimLimit = config.getParameter("mechAimLimit") * math.pi / 180
  mechFrontRotationPoint = config.getParameter("mechFrontRotationPoint")
  mechFrontFirePosition = config.getParameter("mechFrontFirePosition")
  mechBackRotationPoint = config.getParameter("mechBackRotationPoint")
  mechBackFirePosition = config.getParameter("mechBackFirePosition")
  mechFireCycle = config.getParameter("mechFireCycle")
  mechProjectile = config.getParameter("mechProjectile")
  mechProjectile = type(mechProjectile) == "string" and {mechProjectile,mechProjectile} or mechProjectile
--mechProjectileIndex = 1
  mechProjectileConfig = config.getParameter("mechProjectileConfig",{})
  suppressTools = config.getParameter("suppressTools",false)
  mechBackGunAngle = config.getParameter("mechBackGunAngle")
  animator.setGlobalTag("mechType", config.getParameter("mechType",""))
  animator.setGlobalTag("mechGunType", config.getParameter("mechGunType",""))
--animator.translateTransformationGroup("guns",config.getParameter("mechArmOffset"))
  animator.setLightActive("headlightBeam",config.getParameter("lightActive"))
  stats = config.getParameter("mechStats")
  mechAction = config.getParameter("mechAction","mechFire")
  hasGuns = mechAction == "mechFire"
  walkTimer = 1
  walkOffset = config.getParameter("walkOffset",{{0, 0.375}, {0, 0.125}, {0, 0}, {0, 0.125}, {0, 0.25}, {0, 0.375}, {0, 0.125}, {0, 0}, {0, 0.125}, {0, 0.25}})
  baseOffset = {0,0}
  e = true
end

function uninit()
  if active then
    status.clearPersistentEffects("movementAbility")
    mcontroller.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
    tech.setParentOffset({0,0})
    active = false
    animator.playSound("warp")
    tech.setVisible(false)
    tech.setParentState()
    tech.setToolUsageSuppressed(false)
    walkTimer = 1
  end
  status.clearPersistentEffects("sb_mech")
end

function input(args)
  if args.moves["special1"] and not lastAction["special1"] then return active and "mechDeactivate" or "mechActivate"
    elseif args.moves["primaryFire"] then return mechAction end
  return nil
end

function flipMech()
  for i = 1, polySize do mechCustomMovementParameters.collisionPoly[i][1] = -mechCustomMovementParameters.collisionPoly[i][1] end
  mcontroller.controlParameters(mechCustomMovementParameters)
  flipped = not flipped
  animator.setFlipped(flipped)
  parentOffset[1] = -parentOffset[1]
  tech.setParentOffset(parentOffset)
end

function update(args)
  local currentInput = input(args)
  for i = 1, polySize do world.debugText("^shadow;"..i,{entity.position()[1]+mechCustomMovementParameters.collisionPoly[i][1],entity.position()[2]+mechCustomMovementParameters.collisionPoly[i][2]},"green") end
  if not active and not status.statPositive("activeMovementAbilities") and currentInput == "mechActivate" and not mcontroller.zeroG() then
    mechCollisionTest = config.getParameter("mechCollisionTest")
    local entityPosition = entity.position()
    mechCollisionTest[1] = mechCollisionTest[1] + entityPosition[1]
    mechCollisionTest[2] = mechCollisionTest[2] + entityPosition[2]
    mechCollisionTest[3] = mechCollisionTest[3] + entityPosition[1]
    mechCollisionTest[4] = mechCollisionTest[4] + entityPosition[2]
    if not world.rectCollision(mechCollisionTest) then
      animator.burstParticleEmitter("mechActivateParticles")
      mcontroller.translate(mechTransformPositionChange)
      animator.playSound("warp")
      tech.setVisible(true)
      tech.setParentState("sit")
      tech.setParentOffset(parentOffset)
      tech.setToolUsageSuppressed(suppressTools)
      active = true
      status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
      if stats then status.setPersistentEffects("sb_mech",stats) end
    else
--    animator.playSound("fail")
    end
  elseif active and (currentInput == "mechDeactivate") then
    uninit()
  end

  if active then
      local diff = world.distance(tech.aimPosition(), mcontroller.position())
      diff = flipped and diff or {-diff[1],-diff[2]}
      local aimAngle = math.atan(diff[2], diff[1])
      local flip = aimAngle > math.pi / 2 or aimAngle < -math.pi / 2
      if not flip then flipMech() end

      if hasGuns then
        if flipped then
  	  aimAngle = aimAngle > 0 and math.max(aimAngle, math.pi - mechAimLimit) or math.min(aimAngle, -math.pi + mechAimLimit)
          animator.rotateGroup("guns",math.pi - aimAngle)
        else
          aimAngle = -aimAngle
	  aimAngle = aimAngle > 0 and -math.max(aimAngle, math.pi - mechAimLimit) or -math.min(aimAngle, -math.pi + mechAimLimit)
          animator.rotateGroup("guns",math.pi + aimAngle)
        end
      end

    if currentInput == "mechFire" then
      local aimRotation = flipped and {math.cos(aimAngle), math.sin(aimAngle)} or vec2.rotate({math.cos(aimAngle), math.sin(aimAngle)},mechBackGunAngle)
      if fireTimer <= 0 then
        spawnProjectile(1,"front",aimRotation)
        fireTimer = fireTimer + mechFireCycle
      else
        local oldFireTimer = fireTimer
        fireTimer = fireTimer - args.dt
        if oldFireTimer > mechFireCycle / 2 and fireTimer <= mechFireCycle / 2 then
          spawnProjectile(1,"back",aimRotation)
        end
      end
    end

      animator.setParticleEmitterActive("mechNoEnergy",status.resourceLocked("energy"))
      local moving = ((mcontroller.walking() or mcontroller.running() or (math.floor(mcontroller.xVelocity()) < -1 or math.floor(mcontroller.xVelocity()) > 1)) and mcontroller.onGround())
      if not hasGuns then
        animator.setParticleEmitterActive("mechSmokeB",moving)
        animator.setParticleEmitterActive("mechSmokeF",moving)
      end
      if moving then status.overConsumeResource("energy",0.001) end

    mcontroller.controlParameters(mechCustomMovementParameters)
    mcontroller.controlFace(flipped and -1 or 1)

    if not mcontroller.onGround() then
      if mcontroller.jumping() then
        animator.setAnimationState("movement", "jump")
	--tech.setParentOffset(parentOffset["jump"] or {0,0})
      elseif mcontroller.falling() then
        animator.setAnimationState("movement", "fall")
	--tech.setParentOffset(parentOffset["fall"] or {0,0})
      end
    elseif mcontroller.walking() or mcontroller.running() then
      if flipped and mcontroller.movingDirection() == 1 or not flipped and mcontroller.movingDirection() == -1 then
        animator.setAnimationState("movement", "backWalk")
	--tech.setParentOffset(parentOffset["backWalk"] or {0,0})
      else
        animator.setAnimationState("movement", "walk")
	--tech.setParentOffset(vec2.add(parentOffset,walkOffset[math.floor(walkTimer)]))
	--animator.translateTransformationGroup("body",e and walkOffset[math.floor(walkTimer)] or {-walkOffset[math.floor(walkTimer)][1],-walkOffset[math.floor(walkTimer)][2]})
	--e = not e
	--walkTimer=walkTimer+0.11
	--if walkTimer > #walkOffset then walkTimer = 1 end
	--tech.setParentOffset(parentOffset["walk"] or {0,0})
      end
      if not mcontroller.movingDirection() then
	--walkTimer = 1
	--tech.setParentOffset(parentOffset)
      end
    else
      animator.setAnimationState("movement", "idle")
      --tech.setParentOffset(parentOffset["idle"] or {0,0}) --setting this every cycle doesn't seem that good of an idea!
    end
  end
  lastAction = args.moves
end

function spawnProjectile(projectile,gun,aimRotation)
  world.spawnProjectile(mechProjectile[projectile], vec2.add(animator.partPoint(gun.."Gun",gun.."GunFirePoint"),mcontroller.position()),entity.id(),aimRotation,false,sb.jsonMerge(mechProjectileConfig,{powerMultiplier=status.stat("powerMultiplier")}))
  animator.setAnimationState(gun.."Firing", "fire")
end