require "/scripts/util.lua"

function init()
  basePosition = vec2.add(object.position(), config.getParameter("baseOffset"))
  offAngle = util.toRadians(config.getParameter("offAngle", -30))
  level = math.max(1, world.threatLevel())
  defaultPower = config.getParameter("power", 2)
  dialogue = config.getParameter("dialogue")

  --Targeting
  targetQueryRange = config.getParameter("targetQueryRange")
  targetMinRange = config.getParameter("targetMinRange")
  targetMaxRange = config.getParameter("targetMaxRange")
  targetAngleRange = util.toRadians(config.getParameter("targetAngleRange"))
  scanInterval = config.getParameter("scanInterval")
  scanAngle = util.toRadians(config.getParameter("scanAngle"))

  --Energy
  storage.energy = storage.energy or 0
  regenBlockTimer = 0
  energyRegen = config.getParameter("energyRegen")
  maxEnergy = config.getParameter("maxEnergy")
  energyRegenBlock = config.getParameter("energyRegenBlock")
  defaultEnergyUsage = config.getParameter("energyUsage")

  energyBarOffset = config.getParameter("energyBarOffset")
  verticalScaling = config.getParameter("verticalScaling")
  animator.translateTransformationGroup("energy", energyBarOffset)

  mechArm = root.assetJson("/vehicles/modularmech/mechparts_arm.config")
  resetProjectile()
  containerCallback()
  state = FSM:new()
  state:set(offState)
end

function update(dt)
  state:update(dt)

  world.debugPoint(firePosition(), "green")

  if storage.energy == 0 then
    blockEnergyUsage = true
  elseif storage.energy == maxEnergy then
    blockEnergyUsage = false
  end

  if regenBlockTimer > 0 then
    regenBlockTimer = math.max(0, regenBlockTimer - script.updateDt())
  else
    storage.energy = math.min(maxEnergy, storage.energy + energyRegen * script.updateDt())
  end

  local ratio = storage.energy / maxEnergy
  local animationState = "full"

  if ratio <= 0.75 then
    animationState = "high"
  elseif ratio <= 0.5 then
    animationState = "medium"
  elseif ratio <= 0.25 then
    animationState = "low"
  elseif ratio <= 0 then
    animationState = "none"
  end

  animator.resetTransformationGroup("energy")
  animator.scaleTransformationGroup("energy", verticalScaling and {1, ratio * 11} or {ratio * 11, 1})
  animator.translateTransformationGroup("energy", energyBarOffset)

  animator.setAnimationState("energy", animationState)
end

function offState()
  animator.setAnimationState("attack", "dead")
  animator.playSound("powerDown")
  object.setAllOutputNodes(false)

  while true do
    animator.rotateGroup("gun", offAngle)
    if active() then
      break
    end
    coroutine.yield()
  end

  animator.playSound("powerUp")
  state:set(scanState)
end

function scanState()
  animator.setAnimationState("attack", "idle")
  util.wait(0.5)
  animator.playSound("scan")
  object.setAllOutputNodes(false)

  local timer = 0

  local scan = coroutine.wrap(function()
    while true do
      local target = findTarget()
      if target then
        return state:set(fireState, target)
      end
      util.wait(1.0)
    end
  end)

  while true do
    timer = timer + script.updateDt() / scanInterval
    timer = timer > 1 and 0 or timer
    animator.rotateGroup("gun", scanAngle * math.sin(timer * math.pi * 2))
    scan()
    if not active() then
      break
    end
    coroutine.yield()
  end
  state:set(offState)
end

function fireState(targetId)
  animator.setAnimationState("attack", "attack")
  animator.playSound("foundTarget")
  object.setAllOutputNodes(true)

  local maxFireAngle = util.toRadians(config.getParameter("maxFireAngle"))
  local fire = coroutine.wrap(autoFire)

  while true do
    if not active() then
      return state:set(offState)
    end

    if not world.entityExists(targetId) then
      break
    end

    local targetPosition = world.entityPosition(targetId)
    local toTarget = world.distance(targetPosition, basePosition)
    local targetDistance = world.magnitude(toTarget)
    local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])

    if (targetDistance > targetMaxRange or targetDistance < targetMinRange or world.lineTileCollision(basePosition, targetPosition)) or math.abs(targetAngle) > targetAngleRange then
      break
    end

    animator.rotateGroup("gun", targetAngle)
    local rotation = animator.currentRotationAngle("gun")
    if math.abs(util.angleDiff(targetAngle, rotation)) < maxFireAngle then
      fire()
    end
    coroutine.yield()
  end

  util.wait(1)

  state:set(scanState)
end

function consumeEnergy(amount)
  if storage.energy <= 0 or blockEnergyUsage then
    return false
  end
  storage.energy = storage.energy - ((storage.ammoUsage > 0 and amount/2) or amount)
  regenBlockTimer = energyRegenBlock
  return true
end

function active()
  if object.isInputNodeConnected(0) then
    return object.getInputNodeLevel(0)
  end

  storage.active = storage.active ~= nil and storage.active or true
  return storage.active
end

function firePosition()
  local animationPosition = vec2.div(config.getParameter("animationPosition"), 8)
  local fireOffset = vec2.add(animationPosition, animator.partPoint("gun", "projectileSource"))
  return vec2.add(object.position(), fireOffset)
end

function resetProjectile()
  storage.projectileType = "standardbullet"
  storage.projectileParameters = {}
  storage.ammoUsage = 0
  storage.energyUsage = defaultEnergyUsage
  storage.power = root.evalFunction("monsterLevelPowerMultiplier", level) * defaultPower
end

function containerCallback()
  --Go on, guess which function runs before THE FUNCTION WHOSE SOLE PURPOSE IS TO BE THE FIRST FUNCTION TO RUN
  if not dialogue then return end
  validItem = false
  local contents = world.containerItems(entity.id())
  if contents and contents[1] then
    resetProjectile()
    local itemType = root.itemType(contents[1].name)
    local parameters = contents[1].parameters
    local cfg = contents[1].config or {}
    itemConfig = root.itemConfig(contents[1].name, parameters.level or cfg.level or 1, parameters.seed or cfg.seed or 1).config

    --mech arm. any item type can be a mech part, so don't discriminate
    if itemConfig.mechPart and itemConfig.mechPart[1] == "arm" then
      local mechParams = mechArm[itemConfig.mechPart[2]].partParameters
      if mechParams.armClass == "GunArm" then
        validItem = true
        storage.projectileType = mechParams.projectileType
        storage.projectileParameters = mechParams.projectileParameters or storage.projectileParameters
      end
    end

    --activeitem
    if itemType == "activeitem" then
      local configAbility = itemConfig.primaryAbility or {}
      local parameterAbility = contents.primaryAbility or {}

      local count = 0
      for _, v in pairs(configAbility) do count = count + 1 break end; for _, v in pairs(parameterAbility) do count = count + 1 break end --god forbid we have a built-in way to check size for these
      if itemConfig.projectileType then count = count + 1 end
      if count > 0 and (parameterAbility.projectileType or configAbility.projectileType or itemConfig.projectileType) then
        validItem = true
      end

      --checks without abilities are for boomerangs
      storage.projectileType = parameterAbility.projectileType or configAbility.projectileType or itemConfig.projectileType or storage.projectileType
      storage.projectileParameters = parameterAbility.projectileParameters or configAbility.projectileParameters or itemConfig.projectileParameters or storage.projectileParameters
      storage.ammoUsage = parameterAbility.ammoUsage or configAbility.ammoUsage or storage.ammoUsage

      defaultPower = parameterAbility.baseDpsFactor or configAbility.baseDpsFactor or 3
      if defaultPower < 5 then defaultPower = defaultPower * 5 end
      EUF = parameterAbility.energyUsageFactor or configAbility.energyUsageFactor

      if not storage.projectileParameters.power then
        storage.projectileParameters.power = storage.power
      end
      local speed = storage.projectileParameters.speed
      if speed and type(speed) ~= "number" then
        storage.projectileParameters.speed = (speed[1]+speed[2])/2 --bubblegun fix
      end
    end

    --throwable
    --TODO: maybe use ammo too? like the revolver ammo
    if itemType == "thrownitem" then
      validItem = true
      storage.projectileType = itemConfig.projectileType or contents.projectileType
      storage.projectileParameters = itemConfig.projectileConfig or contents.projectileConfig
      storage.ammoUsage = itemConfig.ammoUsage or contents.ammoUsage
    end
  else
    validItem = "maybe"
    resetProjectile()
  end

  if type(validItem) == "boolean" then
    storage.energyUsage = defaultEnergyUsage + (EUF or 0) + (storage.projectileParameters.power or root.projectileConfig(storage.projectileType).power or 5)/4
    EUF = nil
    object.say(dialogue[validItem and 1 or 2])
  end
end

function getProjectiles(a)
  return type(a) == "table" and a[math.random(#a)] or a
end

function autoFire()
  while true do
    while not consumeEnergy(storage.energyUsage) do
      coroutine.yield()
    end

    local rotation = animator.currentRotationAngle("gun")
    local aimVector = {object.direction() * math.cos(rotation), math.sin(rotation)}
    world.spawnProjectile(
      getProjectiles(storage.projectileType),
      firePosition(),
      entity.id(),
      aimVector,
      false,
      storage.projectileParameters
    )
    if storage.ammoUsage > 0 then
      world.containerTakeNumItemsAt(entity.id(), 0, storage.ammoUsage)
    end
    animator.playSound("fire")
    util.wait(0.25)
  end
end


function findTarget()
  local nearEntities = world.entityQuery(basePosition, targetQueryRange, {includedTypes = {"monster", "npc", "player"}})
  return util.find(nearEntities,
    function(entityId)
      local targetPosition = world.entityPosition(entityId)
      if not entity.isValidTarget(entityId) or world.lineTileCollision(basePosition, targetPosition) then
        return false
      end

      local toTarget = world.distance(targetPosition, basePosition)
      local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])
      return world.magnitude(toTarget) > targetMinRange and math.abs(targetAngle) < targetAngleRange
    end
  )
end
