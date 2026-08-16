require "/scripts/util.lua"
require("/scripts/sb_assetmissing.lua")
require("/scripts/player/sb_hasTech.lua")

--Here's an idea, shove this into the sb_main script instead of adding a whole quest for it. Why did we do it like this?

--Update instead of init because entity messages
function update(); sb_techType()
  if not player.getProperty("sb_enabledSuitTechs") then return end --Skip if the player hasn't been setup or 36-37 versioning ran late

  skipMessage = config.getParameter("skipTechUnlockMessages", sb_storyDisablerInstalled())
  local quests = config.getParameter("quests", {})
  for i = 1, #quests do
    if player.hasCompletedQuest(quests[i]) then unlockTech(i) end
  end

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
    if root.hasTech(techs[i]) and not sb_isTechAvailableOrEnabled(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]

      if root.techType(techs[i]) == "Suit" then
        world.sendEntityMessage(player.id(), "sb_suitTech:makeAvailable", techs[i])
      else
        player.makeTechAvailable(techs[i])
      end
    end
  end

  if #unownedTechs ~= 0 and not skipMessage then
    sendRadioMessage(unownedTechs)
  end
end

--Identical to the one in unlocktechs. TODO: rename and do what you need to for both scripts
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