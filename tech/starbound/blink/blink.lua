function init()
  mode = "none"
  timer = 0
  targetPosition = nil
  inputSpecial = false
  energyUsage = config.getParameter("energyUsage")
  maxEnergyUsage = config.getParameter("maxEnergyUsage", energyUsage) - energyUsage
  energyUsageType = config.getParameter("energyUsageType", "")
  energyEfficiency = config.getParameter("energyEfficiency", 1)
  blinkMode = config.getParameter("blinkMode")
  blinkOutTime = config.getParameter("blinkOutTime")
  blinkInTime = config.getParameter("blinkInTime")
  randomBlinkAvoidCollision = config.getParameter("randomBlinkAvoidCollision")
  randomBlinkAvoidMidair = config.getParameter("randomBlinkAvoidMidair")
  randomBlinkAvoidLiquid = config.getParameter("randomBlinkAvoidLiquid")
  blinkCollisionCheckDiameter = config.getParameter("blinkCollisionCheckDiameter")
  blinkVerticalGroundCheck = config.getParameter("blinkVerticalGroundCheck")
  blinkFootOffset = config.getParameter("blinkFootOffset")
  blinkHeadOffset = config.getParameter("blinkHeadOffset")
  randomBlinkTries = config.getParameter("randomBlinkTries")
  randomBlinkDiameter = config.getParameter("randomBlinkDiameter")

  if config.getParameter("energyUsageType", "") == "scaling" then
    consumeEnergy = function(blinkPosition)
      local current = mcontroller.position()
      local dest = blinkPosition
      local newEnergyUsage = energyUsage + math.min(math.sqrt(((dest[1] - current[1]) ^ 2) + ((dest[2] - current[2]) ^ 2)) / energyEfficiency, maxEnergyUsage)
      return status.overConsumeResource("energy", newEnergyUsage)
    end
  else
    consumeEnergy = function() return status.overConsumeResource("energy", energyUsage) end
  end
end

function blinkAdjust(position, doPathCheck, doCollisionCheck, doLiquidCheck, doStandCheck)
  if doPathCheck then
    local collisionBlocks = world.collisionBlocksAlongLine(mcontroller.position(), position, {"Null", "Block", "Dynamic"}, 1)
    if #collisionBlocks ~= 0 then
      local diff = world.distance(position, mcontroller.position())
      diff[1] = diff[1] > 0 and 1 or -1
      diff[2] = diff[2] > 0 and 1 or -1

      position = {collisionBlocks[1][1] - math.min(diff[1], 0), collisionBlocks[1][2] - math.min(diff[2], 0)}
    end
  end

  if doCollisionCheck then
    local diff = world.distance(position, mcontroller.position())
    local collisionPoly = mcontroller.collisionPoly()

    --Add foot offset if there is ground
    if diff[2] < 0 then
      local groundBlocks = world.collisionBlocksAlongLine(position, {position[1], position[2] + blinkFootOffset}, {"Null", "Block", "Dynamic"}, 1)
      if #groundBlocks > 0 then
        position[2] = groundBlocks[1][2] + 1 - blinkFootOffset
      end
    end

    --Add head offset if there is ceiling
    if diff[2] > 0 then
      local ceilingBlocks = world.collisionBlocksAlongLine(position, {position[1], position[2] + blinkHeadOffset}, {"Null", "Block", "Dynamic"}, 1)
      if #ceilingBlocks > 0 then
        position[2] = ceilingBlocks[1][2] - blinkHeadOffset
      end
    end

    --Resolve position
    position = world.resolvePolyCollision(collisionPoly, position, blinkCollisionCheckDiameter)

    if not position or world.lineTileCollision(mcontroller.position(), position, {"Null", "Block", "Dynamic"}) then
      return nil
    end
  end

  if doStandCheck then
    local groundFound = false 
    for i = 1, blinkVerticalGroundCheck * 2 do
      local checkPosition = {position[1], position[2] - i / 2}

      if world.pointTileCollision(checkPosition, {"Null", "Block", "Dynamic", "Platform"}) then
        groundFound = true
        position = {checkPosition[1], checkPosition[2] + 0.5 - blinkFootOffset}
        break
      end
    end

    if not groundFound then
      return nil
    end
  end

  if doLiquidCheck and (world.liquidAt(position) or world.liquidAt({position[1], position[2] + blinkFootOffset})) then
    return nil
  end

  return position
end

function findRandomBlinkLocation(doCollisionCheck, doLiquidCheck, doStandCheck)
  for i = 1, randomBlinkTries do
    local position = mcontroller.position()
    position[1] = position[1] + (math.random() * 2 - 1) * randomBlinkDiameter
    position[2] = position[2] + (math.random() * 2 - 1) * randomBlinkDiameter

    local position = blinkAdjust(position, false, doCollisionCheck, doLiquidCheck, doStandCheck)
    if position then
      return position
    end
  end

  return nil
end

function input(args)
  if args.moves["special1"] and not inputSpecial then
    inputSpecial = true
    return "blink"
  elseif not args.moves["special1"] then
    inputSpecial = false
  end

  return nil
end

function update(args)
  local action = input(args)

  if action == "blink" and not tech.parentLounging() and mode == "none" then
    local blinkPosition = nil
    if blinkMode == "random" then

      blinkPosition =
        findRandomBlinkLocation(randomBlinkAvoidCollision, randomBlinkAvoidMidair, randomBlinkAvoidLiquid) or
        findRandomBlinkLocation(randomBlinkAvoidCollision, randomBlinkAvoidMidair, false) or
        findRandomBlinkLocation(randomBlinkAvoidCollision, false, false)
    elseif blinkMode == "cursor" then
      blinkPosition = blinkAdjust(tech.aimPosition(), true, true, false, false)
    elseif blinkMode == "cursorPenetrate" then
      blinkPosition = blinkAdjust(tech.aimPosition(), false, true, false, false)
    end

    if not status.statPositive("activeMovementAbilities") then
      if blinkPosition and consumeEnergy(blinkPosition) then
        targetPosition = blinkPosition
        mode = "start"
      else
        animator.playSound("fail")
      end
      else
        animator.playSound("fail")
      end
    end

  if mode == "start" then
    status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
    mcontroller.setVelocity({0, 0})
    mode = "out"
    timer = 0
    animator.playSound("activate")
  elseif mode == "out" then
    tech.setParentDirectives("?multiply=0000")
    animator.setAnimationState("blinking", "out")
    mcontroller.setVelocity({0, 0})
    timer = timer + args.dt

    if timer > blinkOutTime then
      mcontroller.setPosition(targetPosition)
      mode = "in"
      timer = 0
    end
  elseif mode == "in" then
    tech.setParentDirectives()
    animator.setAnimationState("blinking", "in")
    mcontroller.setVelocity({0, 0})
    timer = timer + args.dt

    if timer > blinkInTime then
      status.clearPersistentEffects("movementAbility")
      mode = "none"
    end
  end
end

function uninit()
  tech.setParentDirectives()
  status.clearPersistentEffects("movementAbility")
end