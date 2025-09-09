local originalInit = init or function() end
local originalUpdate = update or function() end
local originalDie = die or function() end

function init() originalInit() monster.setAggressive(true)
  sb_music = status.statusProperty("bossMusic","")
--  self.players = {} --???
  sb_noMusic = config.getParameter("podUuid")
  if sb_noMusic then monster.setDamageBar("Default") end
end

function update(dt) originalUpdate(dt)
--local nearPlayers = world.playerQuery(entity.position(),80)
  if not sb_noMusic then
    local players = world.players()
    for _,i in pairs(players) do
      if world.magnitude(entity.position(),world.entityPosition(i)) > 80 then --And if they're using a radio?
      --Okay so when they enter the radius remove them from messagedPlayers??
        world.sendEntityMessage(i,"stopAltMusic",1)
      else
        world.sendEntityMessage(i,"playAltMusic",{sb_music},1)
      end
    end
  end
end

function die() originalDie()
  local players = world.players()
  if not sb_noMusic then
    for _,i in pairs(players) do world.sendEntityMessage(i,"stopAltMusic",1) end
  end
end
--local players = world.players() for _,i in pairs(players) do world.sendEntityMessage(i,"stopAltMusic") end