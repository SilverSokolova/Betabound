require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  mechArm = root.assetJson("/vehicles/modularmech/mechparts_arm.config")
  selfprojectile = {"standardbullet",{},0} containerCallback()
  selfdefaultProjectile = {"standardbullet",{},0}
  -- Positions and angles
  selfbaseOffset = config.getParameter("baseOffset")
  selfbasePosition = vec2.add(object.position(), selfbaseOffset)
  selftipOffset = config.getParameter("tipOffset") --This is offset from BASE position, not object origin

  selfrotationSpeed = util.toRadians(config.getParameter("rotationSpeed"))
  selfoffAngle = util.toRadians(config.getParameter("offAngle", -30))

  -- Targeting
  selftargetQueryRange = config.getParameter("targetQueryRange")
  selftargetMinRange = config.getParameter("targetMinRange")
  selftargetMaxRange = config.getParameter("targetMaxRange")
  selftargetAngleRange = util.toRadians(config.getParameter("targetAngleRange"))

  -- Energy
  storage.energy = storage.energy or 0
  selfregenBlockTimer = 0
  selfenergyRegen = config.getParameter("energyRegen")
  selfmaxEnergy = config.getParameter("maxEnergy")
  selfenergyRegenBlock = config.getParameter("energyRegenBlock")

  selfenergyBarOffset = config.getParameter("energyBarOffset")
  selfverticalScaling = config.getParameter("verticalScaling")
  animator.translateTransformationGroup("energy", selfenergyBarOffset)

  selfstate = FSM:new()
  selfstate:set(offState)
end

function update(dt)
  selfstate:update(dt)

  world.debugPoint(firePosition(), "green")

  if storage.energy == 0 then
    selfblockEnergyUsage = true
  elseif storage.energy == selfmaxEnergy then
    selfblockEnergyUsage = false
  end

  if selfregenBlockTimer > 0 then
    selfregenBlockTimer = math.max(0, selfregenBlockTimer - script.updateDt())
  else
    storage.energy = math.min(selfmaxEnergy, storage.energy + selfenergyRegen * script.updateDt())
  end

  local ratio = storage.energy / selfmaxEnergy
  local animationState = "full"

  if ratio <= 0.75 then animationState = "high" end
  if ratio <= 0.5 then animationState = "medium" end
  if ratio <= 0.25 then animationState = "low" end
  if ratio <= 0 then animationState = "none" end

  local scale = selfverticalScaling and {1, ratio * 11} or {ratio * 11, 1}

  animator.resetTransformationGroup("energy")
  animator.scaleTransformationGroup("energy", scale)
  animator.translateTransformationGroup("energy", selfenergyBarOffset)

  animator.setAnimationState("energy", animationState)
end

----------------------------------------------------------------------------------------------------------
-- States

function offState()
  animator.setAnimationState("attack", "dead")
  animator.playSound("powerDown")
  object.setAllOutputNodes(false)

  while true do
    animator.rotateGroup("gun", selfoffAngle)

    if active() then break end
    coroutine.yield()
  end

  animator.playSound("powerUp")

  selfstate:set(scanState)
end

function scanState()
  animator.setAnimationState("attack", "idle")
  util.wait(0.5)
  animator.playSound("scan")
  object.setAllOutputNodes(false)

  local timer = 0

  local scanInterval = config.getParameter("scanInterval")
  local scanAngle = util.toRadians(config.getParameter("scanAngle"))

  local scan = coroutine.wrap(function()
    while true do
      local target = findTarget()
      if target then return selfstate:set(fireState, target) end
      util.wait(1.0)
    end
  end)

  while true do
    timer = timer + script.updateDt() / scanInterval
    if timer > 1 then timer = 0 end
    animator.rotateGroup("gun", scanAngle * math.sin(timer * math.pi*2))

    scan()

    if not active() then break end
    coroutine.yield()
  end

  selfstate:set(offState)
end

function fireState(targetId)
  animator.setAnimationState("attack", "attack")
  animator.playSound("foundTarget")
  object.setAllOutputNodes(true)

  local maxFireAngle = util.toRadians(config.getParameter("maxFireAngle"))
  local fire = coroutine.wrap(autoFire)

  while true do
    if not active() then return selfstate:set(offState) end

    if not world.entityExists(targetId) then break end

    local targetPosition = world.entityPosition(targetId)
    local toTarget = world.distance(targetPosition, selfbasePosition)
    local targetDistance = world.magnitude(toTarget)
    local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])

    if targetDistance > selftargetMaxRange or targetDistance < selftargetMinRange or world.lineTileCollision(selfbasePosition, targetPosition) then break end
    if math.abs(targetAngle) > selftargetAngleRange then break end

    animator.rotateGroup("gun", targetAngle)

    local rotation = animator.currentRotationAngle("gun")
    if math.abs(util.angleDiff(targetAngle, rotation)) < maxFireAngle then
      fire()
    end
    coroutine.yield()
  end

  util.wait(1.0)

  selfstate:set(scanState)
end

----------------------------------------------------------------------------------------------------------
-- Helping functions, not states

function consumeEnergy(amount)
  if storage.energy <= 0 or selfblockEnergyUsage then return false end
  storage.energy = storage.energy - amount
  selfregenBlockTimer = selfenergyRegenBlock
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

function containerCallback()
  local level = math.max(1.0, world.threatLevel())
  local power = config.getParameter("power", 2)
  power = root.evalFunction("monsterLevelPowerMultiplier", level) * power
--power, firetime
  selfmisc = {power,config.getParameter("fireTime", 0.1),config.getParameter("energyUsage")}
  local contents = world.containerItems(entity.id())
  if contents ~= nil then
if contents[1] ~= nil then
    local projectile = {contents[1].parameters or {}, root.itemConfig(contents[1].name).config}
    if projectile[2].mechPart and projectile[2].mechPart[1] == "arm" then
local mechName = projectile[2].mechPart[2]
	local mechParams = mechArm[mechName].partParameters
	if mechParams.armClass == "GunArm" then selfprojectile = {mechParams.projectileType,mechParams.projectileParameters,0}
	return end
    end
    projectile[3] = projectile[2].ammoUsage or 0
    projectile[1].primaryAbility = projectile[1].primaryAbility or {} --selfprojectile[1]
    projectile[2].primaryAbility = projectile[2].primaryAbility or {} --selfprojectile[1]
    projectile[1].projectileType = projectile[1].projectileType or nil
    projectile[2].projectileType = projectile[2].projectileType or nil
    selfprojectile = {projectile[1].projectileType or
			projectile[2].projectileType or
			projectile[1].primaryAbility.projectileType or
			projectile[2].primaryAbility.projectileType or
			selfdefaultProjectile[1],projectile[1].primaryAbility.projectileParameters or
			projectile[2].primaryAbility.projectileParameters or
			projectile[1].projectileParameters or projectile[2].projectileParameters or {}}
    selfprojectile[3] = projectile[3] or 0
  local o = selfmisc
  --TODO: should probably do something about the bubble gun not working because the projectile speed is a range
  selfmisc[1] = projectile[1].primaryAbility.baseDamageFactor or projectile[2].primaryAbility.baseDamageFactor or selfmisc[1]
  --selfmisc[2] = projectile[1].primaryAbility.fireTimeFactor or projectile[2].primaryAbility.fireTimeFactor or selfmisc[2]
  selfmisc[3] = projectile[1].primaryAbility.energyUsageFactor or projectile[2].primaryAbility.energyUsageFactor or selfmisc[3]
  for i = 1, 3 do if selfmisc[i] ~= o[i] then selfmisc[i] = (root.evalFunction("monsterLevelPowerMultiplier", level) * power) * 90 end end

  else selfprojectile = selfdefaultProjectile end end
end

function getProjectiles(a)
if type(a) == "table" then return a[math.random(1,#a)] else return a end
end

-- Coroutine
function autoFire()
  selfprojectile[2].power = selfmisc[1]

  while true do
    while not consumeEnergy(selfmisc[3]) do coroutine.yield() end

    local rotation = animator.currentRotationAngle("gun")
    local aimVector = {object.direction() * math.cos(rotation), math.sin(rotation)}
    world.spawnProjectile(getProjectiles(selfprojectile[1]), firePosition(), entity.id(), aimVector, false, selfprojectile[2])
    if selfprojectile[3] > 0 then world.containerTakeNumItemsAt(entity.id(),0,selfprojectile[3]) end
    animator.playSound("fire")
    util.wait(selfmisc[2])
  end
end

-- Coroutine
function findTarget()
  local nearEntities = world.entityQuery(selfbasePosition, selftargetQueryRange, { includedTypes = { "monster", "npc", "player" } })
  return util.find(nearEntities,  function(entityId)
    local targetPosition = world.entityPosition(entityId)
    if not entity.isValidTarget(entityId) or world.lineTileCollision(selfbasePosition, targetPosition) then return false end

    local toTarget = world.distance(targetPosition, selfbasePosition)
    local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])
    return world.magnitude(toTarget) > selftargetMinRange and math.abs(targetAngle) < selftargetAngleRange
  end)
end
