require "/scripts/util.lua"
require("/scripts/sb_assetmissing.lua")
require("/scripts/player/sb_hasTech.lua")

function init()
  local questData = root.questConfig("sb_techunlocks")
  radioMessages = questData.scriptConfig.radioMessages
  delay = questData.scriptConfig.cinematicRadioMessageDelay
  storage.delayTimer = storage.delayTimer or 0
--require(questData.script) --commented out to prevent "quests is nil" issue. we only did this for one function anyway

  sb_techType()
  local techs = config.getParameter("techs")
  unownedTechs = {}
  for i = 1, #techs do
    if not sb_isTechAvailableOrEnabled(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]
      world.sendEntityMessage(player.id(), "sb_suitTech:makeAvailable", techs[i])
    end
  end

  if #unownedTechs ~= 0 then
    local sb_genderedCinematic = config.getParameter("sb_genderedCinematic")
    if sb_genderedCinematic then
      player.playCinematic(string.format(sb_genderedCinematic, player.gender() == "male" and "m" or "f")) --TODO: rename the cinematics to 'male' and 'female'?
    end
  end
end

function update(dt)
  if not unownedTechs then
    quest.fail() --By the way, this originally completed itself, so we'll need to do something (such as making the quest repeatable) if we ever change what the items unlock
  end

  storage.delayTimer = storage.delayTimer + dt
  if unownedTechs and storage.delayTimer > delay then
    sendRadioMessage(unownedTechs)
    unownedTechs = nil
  end
end

--Identical to the one in techunlocks
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