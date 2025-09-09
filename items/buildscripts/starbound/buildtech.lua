require("/scripts/sb_assetmissing.lua")

function build(_, config, parameters, level); 
  sb_techType()
  level = math.max(math.floor(level or 1), 1)
  parameters.techModule = isTech(parameters.techModule or randomTech(level), level)
  local tech = root.techConfig(parameters.techModule)
  local inheritedParameters = config.inheritedParameters
  for i = 1, #inheritedParameters do
    if tech[inheritedParameters[i]] then
      config[inheritedParameters[i]] = tech[inheritedParameters[i]]
    end
  end
  if tech.shortDescription then
    config.shortdescription = tech.shortDescription --My beautiful loop, RUINED by this if statement, all because of this game's inconsistency!
  end
  if tech.sb_longDescription then
    config.description = config.description .. " " .. tech.sb_longDescription
  end

  config.inventoryIcon = jarray()
  config.tooltipFields.subtitle = string.format(config.subtitle, root.techType(tech.name))
  table.insert(config.inventoryIcon, {image = config.backingImage})
  table.insert(config.inventoryIcon, {image = sb_assetmissing(tech.icon)})
  return config, parameters
end

function isTech(tech, level)
  return root.hasTech(tech) and tech or root.assetJson("/versioning/sb_tech.config")[tech] or isTech(randomTech(level))
end


function randomTech(level)
  local tech = root.createTreasure("sb_tech", math.random(2) == 1 and math.random(math.max(level - 1, 1)) or level)[1]
  return tech.parameters and tech.parameters.techModule or randomTech(level)
end