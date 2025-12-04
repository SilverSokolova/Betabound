function sb_isTechEnabled(tech); sb_setupTechType()
  local enabledTechs = root.techType(tech) == "Suit" and player.getProperty("sb_enabledSuitTechs") or player.enabledTechs()
  for i = 1, #enabledTechs do
    if enabledTechs[i] == tech then
      return true
    end
  end

  return false
end

function sb_isTechAvailable(tech); sb_setupTechType()
  local availableTechs = root.techType(tech) == "Suit" and player.getProperty("sb_availableSuitTechs") or player.availableTechs()
  for i = 1, #availableTechs do
    if availableTechs[i] == tech then
      return true
    end
  end

  return false
end

function sb_isTechAvailableOrEnabled(tech)
  return sb_isTechEnabled(tech) or sb_isTechAvailable(tech)
end

function sb_setupTechType()
  if not sb_techType then
    require("/scripts/sb_assetmissing.lua")
    sb_techType()
  end
end