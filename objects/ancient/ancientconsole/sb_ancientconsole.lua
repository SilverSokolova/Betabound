local originalInit = init or function() end
local originalUpdate = update or function() end

function init() originalInit()
  sb_knownPlayers = {}
  sb_radioMessage = config.getParameter("sb_radioMessage")
end

function update(dt) originalUpdate(dt)
  if not self.isOutpostGate then
    local players = world.players()
    if #players > 0 then
      for i = 1, #players do
        if not sb_knownPlayers[players[i]] then
          world.sendEntityMessage(players[i], "queueRadioMessage", sb_radioMessage)
          sb_knownPlayers[players[i]] = true
        end
      end
    end
  end
end
