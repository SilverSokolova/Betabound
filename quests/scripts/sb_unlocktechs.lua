function init()
  local questData = root.questConfig("sb_techunlocks")
  radioMessages = questData.scriptConfig.radioMessages
  delay = questData.scriptConfig.cinematicRadioMessageDelay
  storage.delayTimer = storage.delayTimer or 0
  require(questData.script)

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
      player.playCinematic(string.format(sb_genderedCinematic, player.gender() == "male" and "m" or "f"))
    end
  end
end

function update(dt)
  if not unownedTechs then
    quest.fail() --By the way, this originally completed itself, so we'll need to do something if we ever change what the items unlock
  end

  storage.delayTimer = storage.delayTimer + dt
  if unownedTechs and storage.delayTimer > delay then
    sendRadioMessage(unownedTechs)
    unownedTechs = nil
  end
end