require "/scripts/util.lua"
require("/scripts/sb_assetmissing.lua")

function init()
  sb_techType()
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
  player.setProperty("sb_techTier", tier)
  if not techTiers then techTiers = config.getParameter("techTiers") end
  local techs = techTiers[tier]
  local unownedTechs = {}
  for i = 1, #techs do
    if root.hasTech(techs[i]) and not ownsTech(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]
    end
  end

  if #unownedTechs ~= 0 and not skipMessage then
    sendRadioMessage(unownedTechs)
  end
end

function sendRadioMessage(techs)
  local radioMessage = root.assetJson(config.getParameter("radioMessages", radioMessages)[#techs == 1 and 1 or 2]).text --getParameter isn't returning the default for some reason
  local formattedTechList = ""

  for i = 1, #techs do
    formattedTechList = formattedTechList..root.techConfig(techs[i]).shortDescription..(i ~= #techs and ", " or ".")
  end

  player.radioMessage(
    {
      messageId = sb.makeUuid(),
      unique = false,
      text = string.format(radioMessage, formattedTechList)
    }
  )
end

function makeSuitAvailable(suit)
  local suits = player.getProperty("sb_availableBioimplants", {})
  if #suits == 0 then suits = {suit} else suits[#suits+1] = suit end
  player.setProperty("sb_availableBioimplants", suits)
end

function ownsTech(tech)
  local isSuit = root.techType(tech) == "Suit"
  local owned = isSuit
                and (contains(player.getProperty("sb_bioimplants", {}), tech) or contains(player.getProperty("sb_availableBioimplants") or {}, tech))
                or contains(player.availableTechs(), tech)

  if not owned then
    if isSuit then
      makeSuitAvailable(tech)
    else
      player.makeTechAvailable(tech)
    end
  end

  return owned
end