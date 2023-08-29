require "/scripts/vec2.lua"

local ini = init or function() end
local updat = update or function() end

function init() ini()
  sb_knownPlayers = {}
end

function update(dt) updat(dt)
  if not self.isOutpostGate then
    local players = world.players()
    local radioMessage = config.getParameter("sb_radioMessage")
    if #players > 0 then
      for i = 1, #players do
	if not sb_knownPlayers[players[i]] then
	world.sendEntityMessage(players[i],"queueRadioMessage",radioMessage)
        sb_knownPlayers[players[i]] = true
        end
      end
    end
  end
end
