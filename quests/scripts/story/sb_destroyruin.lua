--TODO: remove self. and test
function init()
  self.sb_onInstanceWorld = player.worldId():find(config.getParameter("sb_instanceWorld"))
  
  if self.sb_onInstanceWorld then
    self.sb_radioMessages = config.getParameter("sb_radioMessages",{})
    self.sb_brainMessageHeight = config.getParameter("brainMessageHeight") - config.getParameter("sb_brainMessageHeightOffset")
    self.sb_brain2MessageHeight = config.getParameter("sb_brain2MessageHeight")
    self.sb_bossroom2MessageHeight = config.getParameter("sb_bossroom2MessageHeight")
    self.sb_questItemSpawnHeight = config.getParameter("sb_questItemSpawnHeight")
    self.sb_checkpointRange = config.getParameter("checkpointRange", 10)
    self.sb_currentRadioMessage = 1
    storage.sb_gotQuestItem = storage.sb_gotQuestItem or false
    sb_step = 1
  end

  init = nil
  require(config.getParameter("sb_script"))

  --These aren't local, so don't rename them to originalUpdate. We need prefixes here
  sb_update = update or function(...) end
  update = function(...) sb_update(...) sb_update2(...) end

  sb_questStart = questStart or function() end
  questStart = function(...) sb_questStart(...)
    player.addCurrency("sb_questActive:destroyruin", 1)
  end

  sb_questComplete = questComplete or function() end
  questComplete = function(...) sb_questComplete(...)
    player.consumeCurrency("sb_questActive:destroyruin", 1)
  end

  if init then
    init()
  end
end

--This whole 'step' thing is taunting me in some way, but corrotines refuse to work here
function sb_update2()
  if self.sb_onInstanceWorld then
    if sb_step == 1 then
      sb_radioMessage() --Esther
      sb_radioMessage() --Lana
      sb_step = sb_step + 1
    end

    local height = entity.position()[2]

    if sb_step == 2 then
      if height < self.sb_questItemSpawnHeight then
        if not storage.sb_gotQuestItem then
          storage.sb_gotQuestItem = true
          player.radioMessage("sb_tentaclemission-artifact")
          player.giveItem("sb_beamaxe2")
        end
        sb_step = sb_step + 1
      end
    end

    if sb_step == 3 then
      if height < self.sb_brainMessageHeight then
        sb_radioMessage() --Koichi
        sb_step = sb_step + 1
      end
    end

    if sb_step == 4 then
      if height < self.sb_brain2MessageHeight then
        sb_radioMessage() --Baron
        sb_step = sb_step + 1
      end
    end

    if sb_step == 5 then
      if height < self.sb_bossroom2MessageHeight then
        sb_radioMessage() --Tonauac
        sb_step = sb_step + 1
      end
    end
  end
end

function sb_radioMessage()
  if self.sb_radioMessages[self.sb_currentRadioMessage] then
    player.radioMessage(self.sb_radioMessages[self.sb_currentRadioMessage])
  end
  self.sb_currentRadioMessage = self.sb_currentRadioMessage + 1
end