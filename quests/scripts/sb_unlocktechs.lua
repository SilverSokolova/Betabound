function init()
  local questData = root.questConfig("sb_techunlocks")
  radioMessages = questData.scriptConfig.radioMessages
  require(questData.script)

  sb_techType()
  local techs = config.getParameter("techs")
  local unownedTechs = {}
  for i = 1, #techs do
    if not ownsTech(techs[i]) then
      unownedTechs[#unownedTechs + 1] = techs[i]
    end
  end

  if #unownedTechs ~= 0 then
    sendRadioMessage(unownedTechs)
  end

  local sb_genderedCinematic = config.getParameter("sb_genderedCinematic")
  if sb_genderedCinematic and #unownedTechs ~= 0 then
    player.playCinematic(string.format(sb_genderedCinematic, player.gender() == "male" and "m" or "f"))
  end

  quest.complete()
end