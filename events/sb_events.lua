--NOTE: The 'no events' patch replaces this file completely
require "/scripts/util.lua"
require "/scripts/rect.lua"
--require "/interface/cockpit/cockpitutil.lua"

local BiomeMicrodungeonId = 65533
local FirstMetaDungeonId = 65520

function init()
  self.config = root.assetJson("/events/sb_events.config")
  if not world.terrestrial() or contains(self.config.invalidWorldTypes, world.type()) then invalidLocation = true end
  self.tileListeners = {}
  message.setHandler("listenTileBroken", function(_, _, entityId)
      table.insert(self.tileListeners, entityId)
    end)
  self.tileEntityListeners = {}
  message.setHandler("listenTileEntityBroken", function(_, _, entityId)
      table.insert(self.tileEntityListeners, entityId)
    end)

  message.setHandler("tileBroken", function(_, _, position, layer, materialId, dungeonId, harvested)
      if dungeonId == BiomeMicrodungeonId or dungeonId < FirstMetaDungeonId then
        messageStagehands(position, "tileBroken")
      end
      for _, listener in ipairs(self.tileListeners) do
        world.sendEntityMessage(listener, "playerTileBroken", position, layer, materialId, dungeonId)
      end
    end)
  message.setHandler("tileEntityBroken", function(_, _, position, entityType, objectName)
      if entityType == "object" then
        messageStagehands(position, "objectBroken")
      end
      for _, listener in ipairs(self.tileEntityListeners) do
        world.sendEntityMessage(listener, "playerTileEntityBroken", position, entityType, objectName)
      end
    end)

  storage.wantedLevel = storage.wantedLevel or 0
  message.setHandler("raiseWantedLevel", function(_, _, newLevel)
      if storage.wantedLevel < newLevel and newLevel >= 3 then
        storage.eventCooldown = 0.0
      end
      storage.wantedLevel = math.max(storage.wantedLevel, newLevel)
    end)

  message.setHandler("setBountyName", function(_, _, bounty)
      self.bounty = bounty
    end)

  self.pendingConfirmations = {}

  message.setHandler("sb_confirm", function(_, _, dialogConfig)
      local uuid = sb.makeUuid()
      dialogConfig.paneLayout = "/interface/windowconfig/simpleconfirmation.config:paneLayout"
      self.pendingConfirmations[uuid] = player.confirm(dialogConfig)
      return uuid
    end)

  -- nil for unfinished, false for declined, true for accepted
  message.setHandler("sb_confirmResult", function(_, _, uuid)
      local promise = self.pendingConfirmations[uuid]
      if not promise then
        return false
      end
      if promise:finished() then
        return promise:result()
      end
      return nil
    end)

  --storage.eventCooldown = 5
  storage.eventCooldown = storage.eventCooldown or math.random(self.config.eventCooldown[1], self.config.eventCooldown[2])
  storage.lastEvent = storage.lastEvent or ""
  self.cooldownTick = 0
  self.spawner = nil
  
  self.lastPosition = mcontroller.position()
--if worldIdCoordinate(player.worldId()) ~= nil then
--  invalidLocation = true
--end
end

function update(dt)
  if invalidLocation then
--  script.setUpdateDelta(0)
    return
  end

  sb.setLogMap("New event cooldown", storage.eventCooldown)
  sb.setLogMap("Last event", storage.lastEvent)
  self.tileListeners = util.filter(self.tileListeners, world.entityExists)
  self.tileEntityListeners = util.filter(self.tileEntityListeners, world.entityExists)

  if self.spawner then
    local status, res = coroutine.resume(self.spawner, dt)
    if not status then
      error(res)
    end
  else
    -- pause events while the player is in a dungeon or village
    local dungeonId = world.dungeonId(mcontroller.position())
    local maxDungeonId = 100 -- dungeon/village dungeon IDs start at 0, planets have less than 100 dungeons
    if dungeonId < maxDungeonId then
      self.lastPosition = mcontroller.position()
    else
      self.cooldownTick = self.cooldownTick + dt
    end

    if world.magnitude(mcontroller.position(), self.lastPosition) > 50 then
      self.lastPosition = mcontroller.position()

      storage.eventCooldown = storage.eventCooldown - self.cooldownTick
      self.cooldownTick = 0
      if storage.eventCooldown < 0.0 then
        local pool
        if storage.wantedLevel > 0 then
          pool = self.config.generic
         -- pool = self.config.wanted[storage.wantedLevel]
        elseif self.bounty then
          pool = self.config.generic
         -- pool = self.config.bounty
        else
          pool = self.config.generic
        end
        self.spawner = coroutine.create(function()
          if triggerEvent(pool) then
            storage.eventCooldown = math.random(self.config.eventCooldown[1], self.config.eventCooldown[2])
          end
          self.spawner = nil
        end)
      end
    end
  end
--[[
  local wantedEffects = {
    "wanted1",
    "wanted2",
    "wanted3",
    "wanted4"
  }
  for i = 1, 4 do
    local effect = wantedEffects[i]
    if i == storage.wantedLevel then
      status.addEphemeralEffect(effect)
    else
      status.removeEphemeralEffect(effect)
    end
  end]]--
end

function uninit()
  if status.resource("health") <= 0 then
    storage.wantedLevel = 0
  end
end

-- yields on-screen quest location regions
function questLocationRegions()
  local clientWindow = world.clientWindow()
  local stagehands = world.entityQuery(rect.ll(clientWindow), rect.ur(clientWindow), { includedTypes = {"stagehand"} })
  local questLocations = util.filter(stagehands, function(entityId) return world.entityName(entityId) == "questlocation" end)
  for _, stagehandId in ipairs(questLocations) do
    local region = rect.translate(world.entityMetaBoundBox(stagehandId), world.entityPosition(stagehandId))
    coroutine.yield(region)
  end
end

-- yields nearby surface regions given a range and bounds
function surfaceRegions(range, bounds)
  self.debug = true
  for dir in ipairs({-1, 1}) do
    local start = mcontroller.position()
    for x = range[1], range[2] do
      local surfaceRegion = rect.translate(bounds, vec2.add(start, {x, 0}))
      local airRegion = {surfaceRegion[1], surfaceRegion[4], surfaceRegion[3], surfaceRegion[4] + 30}
      util.debugRect(surfaceRegion, "green")
      util.debugRect(airRegion, "blue")
      if world.rectTileCollision(surfaceRegion) and not world.rectTileCollision(airRegion) then
        coroutine.yield(surfaceRegion)
      end
    end
  end
end

function airRegions(bounds)
  local region = rect.translate(bounds, mcontroller.position())
  if not world.rectTileCollision(region) then
    coroutine.yield(region)
  end
end

function screenRegions(bounds, anchor)
  local w = world.clientWindow()
  local anchorPosition
  if anchor == "top" then
    anchorPosition = {(w[1] + w[3]) / 2, w[4]}
  elseif anchor == "bottom" then
    anchorPosition = {(w[1] + w[3]) / 2, w[2]}
  elseif anchor == "left" then
    anchorPosition = {w[1], (w[2] + w[4]) / 2}
  elseif anchor == "right" then
    anchorPosition = {w[3], (w[2] + w[4]) / 2}
  end
  local region = rect.translate(bounds, anchorPosition)
  if not world.rectTileCollision(region) then
    coroutine.yield(region)
  end
end

-- iterates through possible regions to spawn an event
function eventRegions(event)
  if event.location == "questLocation" then
    return coroutine.wrap(questLocationRegions)
  elseif event.location == "surface" then
    return coroutine.wrap(function() surfaceRegions(event.range, event.bounds) end)
  elseif event.location == "screen" then
    return coroutine.wrap(function() screenRegions(event.bounds, event.anchor) end)
  else
    error(string.format("Unsupported event location type %s", event.location))
  end
end

function spawnEventStagehand(stagehand, region)
  if world.getProperty("sb_events", true) ~= false then
    local position = rect.center(region)
    if world.inSurfaceLayer(position) then
      local bounds = rect.translate(region, {-position[1], -position[2]})
      world.spawnStagehand(position, stagehand, {
        broadcastArea = bounds,
        eventSource = player.id(),
        bounty = self.bounty
      })
    end
  end
end

-- yields until an event has been triggered
function triggerEvent(eventPool)
  while true do
    local validEvents = {}
    for _, eventName in ipairs(eventPool) do
      local event = self.config.events[eventName]
      if storage.lastEvent and storage.lastEvent ~= eventName then
        for region in eventRegions(event) do
          if event.exclusiveQuest and player.hasCompletedQuest(event.exclusiveQuest) then
            return
          end
          table.insert(validEvents, {event, region, eventName, event.skipChance or -1})
        end
      end
    end

    if #validEvents > 0 then
      local spawn = util.randomFromList(validEvents)
      local event, region = spawn[1], spawn[2]
      if spawn[4] < math.random(0, 10) then
        spawnEventStagehand(event.stagehand, region)
        sb.logInfo("Spawn event stagehand %s at %s", event.stagehand, rect.center(region))
        storage.lastEvent = spawn[3]
      else
        sb.logInfo("Skipped event stagehand %s", event.stagehand)
      end
      return true
    end

    coroutine.yield()
  end
end

function messageStagehands(position, messageType)
  local area = rect.withCenter(position, {2, 2})
  local stagehands = world.entityQuery(rect.ll(area), rect.ur(area), {
      includedTypes = {"stagehand"},
      boundMode = "MetaBoundBox"
    })
  stagehands = util.filter(stagehands, function(entityId)
      return world.entityName(entityId) == "objecttracker"
    end)
  for _, entityId in ipairs(stagehands) do
    world.sendEntityMessage(entityId, messageType, player.id(), position)
  end
end