require "/scripts/companions/util.lua"
require "/scripts/achievements.lua"
--require "/scripts/companions/capturable.lua"

-- Functions for entities that can be captured with a capturepod
betabound_capturable = {}

local ini = init or function () end
function init() ini()
	--if betabound_capturable.wasRelocated() then monster.setDisplayNametag(true) end
	self.killCount = status.stat("sb_killCount",0)
	sb_doLeveling = false --status.isResource("sb_killCount")
--	if sb_doLeveling then monster.setDisplayNametag(true) end
	self.petInflictedDamage = damageListener("inflictedDamage", petInflictedDamageCallback)

--  message.setHandler("betabound_pet.genname", function () return root.generateName("/celestial/anomalynames.config:nameGen",monster.seed()) --and planet name...
  --  end)

  message.setHandler("betabound_pet.attemptCapture", function (_, _, ...)
--      self.shouldDie = false
      return betabound_capturable.attemptCapture(...)
    end)

  message.setHandler("betabound_pet.attemptRelocate", function (_, _, ...)
      return betabound_capturable.attemptRelocate(...)
    end)

  message.setHandler("betabound_pet.returnToPod", function(_, _, ...)
      local status = betabound_capturable.captureStatus()
      betabound_capturable.recall()
      return status
    end)

  message.setHandler("betabound_pet.status", function(_, _, persistentEffects, damageTeam)
      if persistentEffects then
        status.setPersistentEffects("owner", persistentEffects)
      end
      if damageTeam then
        monster.setDamageTeam(damageTeam)
      end
      return { status = betabound_capturable.captureStatus() }
    end)

  local initialStatus = config.getParameter("initialStatus")

  if initialStatus then setCurrentStatus(initialStatus, "owner") end
  if betabound_capturable.podUuid() then betabound_capturable.startReleaseAnimation() end

  if betabound_capturable.wasRelocated() and not storage.spawned then
    status.addEphemeralEffect("monsterrelocatespawn")
    storage = config.getParameter("relocateStorage", {})
    storage.spawned = true
  end
end

function betabound_capturable.startReleaseAnimation()
  status.addEphemeralEffect("monsterrelease")
  animator.setAnimationState("releaseParticles", "on")
end

function betabound_capturable.update(dt)
  if sb_doLeveling then self.petInflictedDamage:update() end
  if betabound_capturable.ownerUuid() then
    if not betabound_capturable.optName() then
    --  monster.setName("Pet")
    end
  end

  if config.getParameter("uniqueId") then
    if entity.uniqueId() == nil then
      world.setUniqueId(entity.id(), config.getParameter("uniqueId"))
    else
      assert(entity.uniqueId() == config.getParameter("uniqueId"))
    end
  end

  if betabound_capturable.despawnTimer then
    betabound_capturable.despawnTimer = betabound_capturable.despawnTimer - dt
    if betabound_capturable.despawnTimer <= 0 then
      betabound_capturable.despawn()
    end
  else
    local spawner = betabound_capturable.tetherUniqueId() or betabound_capturable.ownerUuid()
    if spawner then
      if not world.entityExists(world.loadUniqueEntity(spawner)) then
        betabound_capturable.recall()
      end
    end
  end

  if betabound_capturable.confirmRelocate then
    if betabound_capturable.confirmRelocate:finished() then
      if betabound_capturable.confirmRelocate:result() then
        betabound_capturable.despawnTimer = 0.3
      else
        status.removeEphemeralEffect("monsterrelocate")
        status.addEphemeralEffect("monsterrelocatespawn")
      end
      betabound_capturable.confirmRelocate = nil
    end
  end
end

function betabound_capturable.die()
      monster.setDropPool(nil)
      monster.setDeathParticleBurst(nil)
      monster.setDeathSound(nil)
      self.deathBehavior = nil
      self.shouldDie = true
      status.addEphemeralEffect("monsterdespawn")
end

-- Extricate this pet from its pod until the next time the pod is 'healed'.
function betabound_capturable.disassociate()
  local podUuid = betabound_capturable.podUuid()
  if betabound_capturable.ownerUuid() and podUuid then
    betabound_capturable.messageOwner("pets.disassociatePet", podUuid, entity.uniqueId())
    betabound_capturable.disassociated = true
  end
end

-- Associate another monster with this monster's pod.
function betabound_capturable.associate(pet)
  assert(betabound_capturable.ownerUuid())
  local podUuid = config.getParameter("podUuid")
  betabound_capturable.messageOwner("pets.associatePet", podUuid, pet)
end

function betabound_capturable.tetherUniqueId() return config.getParameter("tetherUniqueId") end
function betabound_capturable.ownerUuid() return config.getParameter("ownerUuid") end
function betabound_capturable.podUuid() if betabound_capturable.disassociated then return nil end return config.getParameter("podUuid") end
function betabound_capturable.messageOwner(message, ...) world.sendEntityMessage(betabound_capturable.tetherUniqueId() or betabound_capturable.ownerUuid(), message, ...) end

function betabound_capturable.captureStatus()
  local currentStatus = getCurrentStatus()
  -- Compute some artificial stats for displaying in the inventory, next to the
  -- pet slot:
  local stats = currentStatus.stats
--sb.logInfo("\n\n%s",stats)
  stats.defense = stats.protection
  stats.attack = 0
  local touchDamageConfig = config.getParameter("touchDamage")
  if touchDamageConfig then
    stats.attack = touchDamageConfig.damage
    stats.attack = stats.attack * (config.getParameter("touchDamageMultiplier") or 1)
    stats.attack = stats.attack * root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    stats.attack = stats.attack * stats.powerMultiplier
  end

  return currentStatus
end

function betabound_capturable.recall()
  animator.burstParticleEmitter("captureParticles")
  status.addEphemeralEffect("monstercapture")
  --betabound_capturable.despawnTimer = 0.5
  betabound_capturable.die()
end

function betabound_capturable.despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)

  local projectileTarget = betabound_capturable.tetherUniqueId() or betabound_capturable.ownerUuid()
  if projectileTarget then
    projectileTarget = world.loadUniqueEntity(projectileTarget)
    if not projectileTarget or not world.entityExists(projectileTarget) then
      projectileTarget = nil
    end
  end
  if projectileTarget then
    local projectiles = 5
    for i = 1, projectiles do
      local angle = math.pi * 2 / projectiles * i
      local direction = { math.sin(angle), math.cos(angle) }
      world.spawnProjectile("monstercaptureenergy", entity.position(), entity.id(), direction, false, {
          target = projectileTarget
        })
    end
  end

  betabound_capturable.justCaptured = true
end

function betabound_capturable.attemptCapture(podOwner)
  -- Try to capture the monster. If successful, the monster is killed and the
  -- pet configuration is returned.
  if betabound_capturable.capturable() then
    local petInfo = betabound_capturable.generatePet()

    recordEvent(podOwner, "captureMonster", entityEventFields(entity.id()), worldEventFields(), {monsterLevel = monster.level()})

    betabound_capturable.recall()
    return petInfo
  end
  return nil
end

function betabound_capturable.wasRelocated()
  return config.getParameter("wasRelocated", false)
end

function betabound_capturable.attemptRelocate(sourceEntity)
  if config.getParameter("relocatable", false) and not betabound_capturable.confirmRelocate then
    --The point that the monster will scale toward
    local scaleOffsetPart = config.getParameter("scaleOffsetPart", "body")
    local attachPoint = vec2.div(animator.partPoint(scaleOffsetPart, "offset") or {0, 0}, 2) -- divide by two because partPoint adds offset to offset
    local petInfo = {
      monsterType = monster.type(),
      collisionPoly = mcontroller.collisionPoly(),
      parameters = monster.uniqueParameters(),
      attachPoint = attachPoint
    }
    for k,v in pairs(config.getParameter("relocateParameters", {})) do
      petInfo.parameters[k] = v
    end
    petInfo.parameters.relocateStorage = storage
    petInfo.parameters.seed = monster.seed()

    status.addEphemeralEffect("monsterrelocate")
    betabound_capturable.confirmRelocate = world.sendEntityMessage(sourceEntity, "confirmRelocate", entity.id(), petInfo)
    return true
  end
end

function betabound_capturable.capturable(capturer)
--sb.logInfo("[BETABOUND] If you're reading this, please let us know!") --watch it activate with vanilla pods...
  if betabound_capturable.ownerUuid() or storage.respawner then return false end
  if betabound_capturable.wasRelocated() then return true end
  local isCapturable = config.getParameter("capturable")
  if not isCapturable then return false end

  local captureHealthFraction = config.getParameter("captureHealthFraction", 0.5)
  local healthFraction = status.resource("health") / status.resourceMax("health")
  if healthFraction > captureHealthFraction then return root.assetJson("/betabound.config:healthyCapture") end

  return true
end

function betabound_capturable.optName()
  local name = world.entityName(entity.id())
  if name == "" then
    return nil
  end
  return name
end

function betabound_capturable.generatePet()
  local parameters = monster.uniqueParameters()
  parameters.aggressive = true
  parameters.wasRelocated = true

  parameters.seed = monster.seed()
--  parameters.level = sb_level or monster.level()
--  parameters.sb_killCount = self.killCount or 0

  local poly = mcontroller.collisionPoly()
  if #poly <= 0 then poly = nil end

  local monsterType = config.getParameter("capturedMonsterType", monster.type())
  local name = config.getParameter("capturedMonsterName", betabound_capturable.optName())
  local captureCollectables = config.getParameter("captureCollectables")
  local statusStats = betabound_capturable.captureStatus()
  statusStats.stats.sb_killCount = (status.stat("sb_killCount") or 0)


  return {
      name = name,
      description = world.entityDescription(entity.id()),
      portrait = world.entityPortrait(entity.id(), "full"),
      collisionPoly = poly,
      wasRelocated = true,
      status = statusStats,
      collectables = captureCollectables,
      config = {
        type = monsterType,
	level = monster.level() + (status.stat("sb_level") or 0),
        parameters = parameters
      }
    }
end

function betabound_capturable.capturable(n)
if config.getParameter("relocatable",false) or config.getParameter("capturable",false) then
return (betabound_capturable.wasRelocated() or ((status.resource("health") / status.resourceMax("health") <= n)))
end end


function betabound_capturable.attemptCapture(n)
  if betabound_capturable.capturable(n) then
    local petInfo = betabound_capturable.generatePet()
    betabound_capturable.recall()
    return petInfo
  end
  return nil
end

function petInflictedDamageCallback(notifications)
  for _,notification in ipairs(notifications) do
    if notification.hitType == "Kill" then
      if not world.entityExists(notification.targetEntityId) then
self.killCount = self.killCount + 1
--  monster.uniqueParameters().level = monster.level()
--  monster.uniqueParameters().killCount = self.killCount
if self.killCount >= 10 then sb_levelUp() end --CHANGE TO TEN
--sb.logInfo("CAPTURE POD: "..self.killCount.."/10 KILLS.\nGleapgreas is now level "..(monster.level()+1).."!")
--status.setStatusProperty("killCount",self.killCount)
--status.setResource("sb_killCount",self.killCount)
--sb.logInfo(sb.print(objectType))
        if entityType == "object" then
--sb.logInfo("object died")
        elseif entityType == "npc" or entityType == "monster" or entityType == "player" then
--sb.logInfo("player, monster, or npc died")
        end
    end
  end
end end

function sb_getLevel()
--sb.logWarn("\n\nSBGETLEVEL CALLED!!!!\n\n")
return sb_level or 1
end

function sb_levelUp()
--sb.logInfo("\n\nLEVELUP CALLED\n\n")
local ran = math.random(1,#sb_statBonuses[1])
sb_statBonuses[1][math.random(1,ran)] = sb_statBonuses[2][math.random(1,ran)]
  local parameters = monster.uniqueParameters()
  if status.isResource("health") then status.setResourcePercentage("health",1) end --sb.logInfo("FULLHEAL")
  status.addEphemeralEffect("sb_levelup")
--  parameters.level = monster.level()
--  sb_level = parameters.level
  self.killCount = 0
  parameters.steant = "AK"
--[[
parameters.status.stats.attack = stats.status.stats.attack + sb_statBonuses[1][1]
parameters.status.stats.powerMultiplier = stats.status.stats.powerMultiplier + sb_statBonuses[1][2]
parameters.status.stats.defense = stats.status.stats.defense + sb_statBonuses[1][3]
parameters.status.stats.protection = stats.status.stats.protection + sb_statBonuses[1][4]
parameters.status.stats.fireResistance = stats.status.stats.fireResistance + sb_statBonuses[1][5]
parameters.status.stats.iceResistance = stats.status.stats.iceResistance + sb_statBonuses[1][6]
parameters.status.stats.electricResistance = stats.status.stats.electricResistance + sb_statBonuses[1][7]
parameters.status.stats.poisonResistance = stats.status.stats.poisonResistance + sb_statBonuses[1][8]
parameters.status.stats.physicalResistance = stats.status.stats.physicalResistance + sb_statBonuses[1][9]
]]--
 --[[ local poly = mcontroller.collisionPoly()
  if #poly <= 0 then poly = nil end

  local monsterType = config.getParameter("capturedMonsterType", monster.type())
  local name = config.getParameter("capturedMonsterName", betabound_capturable.optName())
  local captureCollectables = config.getParameter("captureCollectables")

  return {
      name = name,
      description = world.entityDescription(entity.id()),
      portrait = world.entityPortrait(entity.id(), "full"),
      collisionPoly = poly,
      status = betabound_capturable.captureStatus(),
      collectables = captureCollectables,
      config = {
        type = monsterType,
        parameters = parameters
      }
    }]]--
end