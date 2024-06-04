require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  local definition = configParameter("definition",configParameter("sb_definition"))
  if definition then
    require "/items/buildscripts/starbound/definition.lua"
    config = applyDefinition(config, definition, configParameter("configOverrides"))
  end

  if parameters.crafted then
    parameters = util.mergeTable(configParameter("craftedParameters", {}), parameters)
    parameters.crafted = nil
  end

  if level and not configParameter("fixedLevel", false) then parameters.level = level end
  config.directives = parameters.directives or config.directives or ""
  config.sb_extraDirectives = parameters.sb_extraDirectives or config.sb_extraDirectives or ""
  if parameters.colorIndex then
    config.directives = "?replace"
    local selectedSwaps = config.colorOptions[parameters.colorIndex+1]
    for k, v in pairs(selectedSwaps) do
  config.directives = string.format("%s;%s=%s",config.directives,k,v)
    end
  end
  config.directives = config.directives..config.sb_extraDirectives
  replacePatternInData(config, nil, "<directives>", config.directives)

  setupAbility(config, parameters, "alt")
  setupAbility(config, parameters, "primary")

  --for some reason, unrand weapons just ignore this part of setupAbility so we have to do it here
  local rotate = parameters.allowRotate or root.assetJson("/items/active/weapons/melee/abilities/broadsword/broadswordcombo.weaponability").ability.stances.fire1.allowRotate or false
  if config.primaryAbility and config.primaryAbility.stances and rotate then
    for k, v in pairs(config.primaryAbility.stances) do
      if k == "idle" then
  config.primaryAbility.stances[k].aimAngle = 0
      else
  util.mergeTable(config.primaryAbility.stances[k], {allowRotate = true, allowFlip = true})
      end
    end
  end

  -- elemental type and config (for alt ability)
  local elementalType = configParameter("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  replacePatternInData(config, nil, "<elementalName>", elementalType:gsub("^%l", string.upper))
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(config.altAbility, config.altAbility.elementalConfig[elementalType])
  end
  if config.altAbility and config.altAbility.shieldHealth then
    config.altAbility.shieldHealth = config.altAbility.shieldHealth * root.evalFunction("sb_shieldLevelMultiplier", configParameter("level", 1))
  end

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- palette swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(util.absolutePath(directory, config.palette))
    local selectedSwaps = palette.swaps[configParameter("colorIndex", 1)]
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format("%s?replace=%s=%s", config.paletteSwaps, k, v)
    end
  end
  if type(config.inventoryIcon) == "string" then
    config.inventoryIcon = config.inventoryIcon .. config.directives
  else
    for i, drawable in ipairs(config.inventoryIcon) do
      if drawable.image then drawable.image = drawable.image .. config.directives end
    end
  end

  -- gun offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    if config.muzzleOffset then
      config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset)
    end
  end

  -- populate tooltip fields
  if config.tooltipKind ~= "base" then
    config.tooltipFields = config.tooltipFields or {}
    config.tooltipFields.dyeLabel = configParameter("sb_dyeable") and "^gray;(Dyeable)" or ""
    config.tooltipFields.levelLabel = "^shadow;Lvl "..string.format("%.0f",configParameter("level", 1))
    config.tooltipFields.level2Label = "Lvl "..string.format("%.0f",configParameter("level", 1))
    config.tooltipFields.dpsLabel = util.round((config.primaryAbility.baseDps or 0) * config.damageLevelMultiplier, 1)
    local fireTime = config.primaryAbility.fireTime or 1.0
    config.tooltipFields.speedLabel = util.round(1 / (fireTime), 1)
    config.tooltipFields.damagePerShotLabel = util.round((config.primaryAbility.baseDps or 0) * fireTime * config.damageLevelMultiplier, 1)
--  config.tooltipFields.energyPerShotLabel = util.round((config.primaryAbility.energyUsage or config.primaryAbility.energyPerShot or 0) * (config.primaryAbility.fireTime or 1.0), 1)
    config.tooltipFields.energyPerShotLabel = util.round(config.primaryAbility.energyPerShot or (config.primaryAbility.energyUsage or 0) * fireTime, 1)
    if config.tooltipKind == "sb_bow" then
      local bestDrawTime = (config.primaryAbility.powerProjectileTime[1] + config.primaryAbility.powerProjectileTime[2]) / 2
      local bestDrawMultiplier = root.evalFunction(config.primaryAbility.drawPowerMultiplier, bestDrawTime)
      config.tooltipFields.maxDamageLabel = util.round(config.primaryAbility.projectileParameters.power * config.damageLevelMultiplier * bestDrawMultiplier, 1)
    end
    if elementalType ~= "physical" and not config.tooltipFields.damageKindImage then
      config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
    end
    if config.primaryAbility then
      config.tooltipFields.primaryAbilityTitleLabel = "Primary:"
      config.tooltipFields.primaryAbilityLabel = config.primaryAbility.name or "unknown"
    end
    if config.altAbility then
      config.tooltipFields.altAbilityTitleLabel = "Special:"
      config.tooltipFields.altAbilityLabel = config.altAbility.name or "unknown"
    end
  end

  if not configParameter("fixedRarity") then
    local rarities = {"common","uncommon","rare","legendary","essential"}
    config.rarity = rarities[math.max(configParameter("minimumRarity",1),root.evalFunction("sb_rarity", math.floor(configParameter("level", 1))))] or config.rarity or "legendary"
  end
  if config.rarity == "essential" then config.tooltipFields.rarityLabel = "Epic" end

  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))
  if not parameters.customItem then
    if parameters.primaryAbilityType == "axecleave" then
      parameters.primaryAbilityType = "sb_axe"
    end

    if config.itemName == "sb_buster" and parameters.primaryAbilityType == "bowshot" then
      parameters.primaryAbilityType = config.primaryAbilityType
    end
  end

  if config.staffHasFullbright then
    config.animationParts.staffFullbright = "<staff>fb.png"
  end

  local tags = configParameter("tags")
  if tags then for k, v in pairs(tags) do replacePatternInData(config, nil, k, v) end end

  return config, parameters
end