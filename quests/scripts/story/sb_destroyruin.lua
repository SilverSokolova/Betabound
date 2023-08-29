require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/quests/scripts/portraits.lua"
require "/quests/scripts/questutil.lua"

function init()
  if player.hasCompletedQuest(config.getParameter("completionQuest",quest.templateId())) then
    script.setUpdateDelta(0) return
  end
  self.messageTime = config.getParameter("messageTime",10)
  self.compassUpdate = config.getParameter("compassUpdate", 0.5)
  self.radioMessages = config.getParameter("radioMessages",{})
  self.skipRadioMessages = config.getParameter("skipRadioMessages",{})
  self.currentRadioMessage = 1
  self.instanceWorld = config.getParameter("instanceWorld")
  self.state = FSM:new()

  storage.gotQuestItem = storage.gotQuestItem or false
  storage.stage = storage.stage or 1
  self.stages = {
    destroyRuin,
    turnIn
  }
  self.state:set(self.stages[storage.stage])
  self.waitTime = self.messageTime
end

function update(dt)
  local s = player.worldId()
  if not s:find(self.instanceWorld) then
    script.setUpdateDelta(0)
  end
  if self.waitTime < 0 then
  self.state:update(dt)
  else
  self.waitTime = self.waitTime - dt
  end
end

function questStart()
  storage.stage = 1
  self.state:set(self.stages[storage.stage])
end

function destroyRuin()
  local findBoss = util.uniqueEntityTracker(config.getParameter("bossUid"), self.compassUpdate)
  while not findBoss() do
    coroutine.yield()
  end
  if player.hasQuest("destroyruin") and not storage.gotQuestItem then player.giveItem("sb_beamaxe2") storage.gotQuestItem = true end

  sb_radioMessage() --Esther
  sb_radioMessage() --Lana

  while entity.position()[2] > config.getParameter("brainMessageHeight",380) do
    coroutine.yield()
  end
  self.waitTime = self.messageTime
  sb_radioMessage() --Koichi

  while entity.position()[2] > config.getParameter("onBrainMessageHeight",267) do
    coroutine.yield()
  end
  sb_radioMessage() --Baron

  local foundCheckpoint = false
  local checkpointRange = config.getParameter("checkpointRange",10)
  local queryCheckpoints = util.interval(0.5, function()
    local nearObjects = world.entityQuery(entity.position(), checkpointRange, {includedTypes = {"object"}})
    if util.find(nearObjects, function(entityId) return world.entityName(entityId) == "checkpoint" end) then
      foundCheckpoint = true
    end
  end)
  while not foundCheckpoint do
    queryCheckpoints(script.updateDt())
    coroutine.yield()
  end

  sb_radioMessage() --Tonauac

  while storage.stage == 1 do
    coroutine.yield()
  end

--  self.state:set(self.stages[storage.stage])
end

function sb_radioMessage()
  if self.radioMessages[self.currentRadioMessage] and not self.skipRadioMessages[self.currentRadioMessage] then
    player.radioMessage(self.radioMessages[self.currentRadioMessage])
  end
  self.currentRadioMessage = self.currentRadioMessage + 1
end