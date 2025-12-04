require "/scripts/util.lua"
require("/scripts/sb_assetmissing.lua")
require("/scripts/player/sb_hasTech.lua")

--Update instead of init because entity messages
function init(); sb_techType()
  if not player.getProperty("sb_enabledSuitTechs") then return end --Skip if the player hasn't been setup or 36-37 versioning ran late

  skipMessage = config.getParameter("skipTechUnlockMessages", sb_storyDisablerInstalled())
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

  update = nil
end

function unlockTech(tier)
  local techTier = player.getProperty("sb_techTier",0)
--if techTier >= tier then return end
  player.setProperty("sb_techTier", tier)
  if not techTiers then techTiers = config.getParameter("techTiers") end
  local techs = techTiers[tier]
  local unownedTechs = {}
  for i = 1, #techs do
    if root.hasTech(techs[i]) and not sb_isTechAvailable(techs[i]) and not sb_isTechEnabled(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]

      if root.techType(techs[i]) == "Suit" then
        player.interact("message", {messageType = "sb_suitTech:makeAvailable", messageArgs = {techs[i]}})
      else
        player.makeTechAvailable(techs[i])
      end
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

  if #techs > 0 then
    player.radioMessage(
      {
        messageId = sb.makeUuid(),
        unique = false,
        text = string.format(radioMessage, formattedTechList)
      }
    )
  end
end

function makeSuitAvailable(suit)
  world.sendEntityMessage(player.id(), "sb_suitTech:makeAvailable", suit)
end