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
    if not ownsTech(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]
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
    quest.complete()
  end

  storage.delayTimer = storage.delayTimer + dt
  if unownedTechs and storage.delayTimer > delay then
    sendRadioMessage(unownedTechs)
    unownedTechs = nil
  end
end