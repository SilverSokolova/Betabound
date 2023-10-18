require "/scripts/util.lua"

function init()
  skipMessage = config.getParameter("skipTechUnlockMessages", root.assetJson("/quests/story/apex_mission2.questtemplate:script") == "/quests/scripts/sdisabler_autocomplete.lua")
  local quests = config.getParameter("quests")
  for i = 1, #quests do
    if player.hasCompletedQuest(quests[i]) then unlockTech(i) end
  end

  message.setHandler("objectScanned", function(_, a, _, id)
    if a == false then return end
    if id == nil then return end
    local objectName = world.getObjectParameter(id, "sb_objectName")
    if objectName then player.addScannedObject(objectName) end
  end)
end

function unlockTech(tier)
  local techTier = player.getProperty("sb_techTier",0)
--if techTier >= tier then return end
  player.setProperty("sb_techTier",tier)
  if not techTiers then techTiers = config.getParameter("techTiers") end
  local techs, suits = techTiers[tier], 0
  techs, suits = techs[1], techs[2]
  local newTechs = {}
  local unlockMessage = config.getParameter("radioMessages")

  for i = 1, #techs do
    if root.hasTech(techs[i]) and not ownsTech(techs[i]) then newTechs[#newTechs+1] = techs[i] player.makeTechAvailable(techs[i]) end
  end
  for i = 1, #suits do
    if root.hasTech(suits[i]) and not ownsSuit(suits[i]) then newTechs[#newTechs+1] = suits[i] player_makeSuitAvailable(suits[i]) end
  end

  if skipMessage or #newTechs == 0 then return end
  local msg = #newTechs == 1 and 1 or 2
  local a = ""
  for i = 1, #newTechs do a = a..root.techConfig(newTechs[i]).shortDescription..(i~=#newTechs and ", " or ".") end
  newTechs = a
  player.radioMessage({messageId=sb.makeUuid(),unique=false,text=string.format(unlockMessage[msg],newTechs)})
end

function player_makeSuitAvailable(suit)
  suits = player.getProperty("sb_availableBioimplants")
  if #suits == 0 then suits = {suit} else suits[#suits+1] = suit end
  player.setProperty("sb_availableBioimplants",suits)
end

function ownsTech(tech) return contains(player.availableTechs(), tech) end
function ownsSuit(tech) return (contains(player.getProperty("sb_bioimplants",{}), tech) or contains(player.getProperty("sb_availableBioimplants",{}), tech)) end