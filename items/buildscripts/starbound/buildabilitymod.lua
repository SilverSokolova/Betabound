require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  abilities = root.assetJson("/sb_abilitymods.config")
  weaponNames = abilities.weaponNames
  abilities = abilities.abilities
  abilityList = config.abilityList or parameters.abilityList
  parameters.ability = parameters.ability or randomAbility()
  config = sb.jsonMerge(config, getAbilityConfig(parameters.ability))
  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "/interface/sb_backingicon.png"})
  --decided against `config.icon and (config.icon..".png") in order to support directives
  local icon = config.icon
  if icon then
    if icon:sub(0, 1) ~= "/" then icon = directory..icon end
  end
  table.insert(config.inventoryIcon, icon and {image = icon} or {image = sb_assetmissing(directory..parameters.ability..".png", "/interface/sb_tooltips/assetmissing.png")})
--table.insert(config.inventoryIcon, {image = "/interface/sb_tooltips/assetmissing.png"})
  abilityData = root.assetJson(root.assetJson("/items/buildscripts/weaponabilities.config")[parameters.ability]).ability

  local elementalConfig = abilityData.elementalConfig
  if elementalConfig then
    if config.rarity == "common" then config.rarity = "uncommon" end
    local acceptedElements = {}
    for k, v in pairs(elementalConfig) do
      for _, _ in pairs(v) do --we have to do this because there's no table.size and one *elemental* vanilla ability has a blank elemental config for *physical*
        acceptedElements[#acceptedElements+1] = k
        break
      end
    end
    config.acceptedElements = acceptedElements
  end
  config.shortdescription = string.gsub((config.rarity ~= "common" and "^yellow;" or "")..abilityData.name.."^reset;", "<elementalName>", config.elementalNameDescription)
  config.description = string.format(config.description, config[(config.slot and "primary" or "alt").."Description" or "???"])

  config.tooltipFields = parameters.tooltipFields or config.tooltipFields or {}
  local weaponName = (abilities[parameters.ability] or {}).weaponName
  if weaponName then
    weaponName = weaponNames[weaponName] or weaponName
    config.tooltipFields.subtitle = string.format(config.subtitle, weaponName:gsub("^%l", string.upper))
  end

  if parameters.level then
    parameters.level = nil
  end
  if parameters.abilityList then
    parameters.abilityList = nil
  end
  return config, parameters
end

function getAbilityConfig(ability)
  for k, _ in pairs(abilities) do
    if k == ability then return abilities[k] end
  end
end

function randomAbility()
  if not abilityList then
    abilityList = {}
    for k, _ in pairs(abilities) do
      abilityList[#abilityList+1] = k
    end
  end
  return abilityList[math.random(#abilityList)]
end