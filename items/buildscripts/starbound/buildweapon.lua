require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/scripts/staticrandom.lua"
require "/items/buildscripts/starbound/abilities.lua"
require "/items/buildscripts/starbound/definition.lua"
require "/scripts/sb_assetmissing.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  local definition = configParameter("definition",configParameter("sb_definition"))
  if definition then
    config = applyDefinition(config, definition, configParameter("configOverrides"))
  end

  if level and not configParameter("fixedLevel", false) then parameters.level = level end

  -- initialize randomization
  if seed then
    parameters.seed = seed
  else
    seed = configParameter("seed")
    if not seed then
      math.randomseed(util.seedTime())
      seed = math.random(1, 4294967295)
      parameters.seed = seed
    end
  end

  -- select the generation profile to use
  local builderConfig = {}
  if config.builderConfig then
    builderConfig = randomFromList(config.builderConfig, seed, "builderConfig")
  end

  -- elemental type
  if not parameters.elementalType and builderConfig.elementalType then
    parameters.elementalType = randomFromList(builderConfig.elementalType, seed, "elementalType")
  end
  local elementalType = configParameter("elementalType", "physical")

  -- select, load and merge abilities
  setupAbility(config, parameters, "alt", builderConfig, seed, elementalType)
  setupAbility(config, parameters, "primary", builderConfig, seed, elementalType)

  -- elemental config
  if builderConfig.elementalConfig and builderConfig.elementalConfig[elementalType] then
    util.mergeTable(config, builderConfig.elementalConfig[elementalType])
  end
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(config.altAbility, config.altAbility.elementalConfig[elementalType])
  end
  if config.altAbility and config.altAbility.shieldHealth then
    config.altAbility.shieldHealth = config.altAbility.shieldHealth * root.evalFunction("sb_shieldLevelMultiplier", configParameter("level", 1))
  end

  -- elemental tag
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  replacePatternInData(config, nil, "<elementalName>", elementalType:gsub("^%l", string.upper))

  -- name
  if not parameters.shortdescription and builderConfig.nameGenerator then
    parameters.shortdescription = root.generateName(util.absolutePath(directory, builderConfig.nameGenerator), seed)
  end

  -- merge damage properties
  if builderConfig.damageConfig then
    util.mergeTable(config.damageConfig or {}, builderConfig.damageConfig)
  end


  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- preprocess shared primary attack config
  parameters.primaryAbility = parameters.primaryAbility or {}
  parameters.primaryAbility.fireTimeFactor = valueOrRandom(parameters.primaryAbility.fireTimeFactor, seed, "fireTimeFactor")
  parameters.primaryAbility.baseDpsFactor = valueOrRandom(parameters.primaryAbility.baseDpsFactor, seed, "baseDpsFactor")
  parameters.primaryAbility.energyUsageFactor = valueOrRandom(parameters.primaryAbility.energyUsageFactor, seed, "energyUsageFactor")

  config.primaryAbility.fireTime = scaleConfig(parameters.primaryAbility.fireTimeFactor, config.primaryAbility.fireTime)
  config.primaryAbility.baseDps = scaleConfig(parameters.primaryAbility.baseDpsFactor, config.primaryAbility.baseDps)
  config.primaryAbility.energyUsage = scaleConfig(parameters.primaryAbility.energyUsageFactor, config.primaryAbility.energyUsage) or 0
  if config.primaryAbility.energyUsage ~= 0 then
    config.primaryAbility.energyUsage = config.primaryAbility.energyUsage + config.damageLevelMultiplier
  end
  if type(config.primaryAbility.inaccuracy) == "table" then
    config.primaryAbility.inaccuracy = math.random(config.primaryAbility.inaccuracy[1], config.primaryAbility.inaccuracy[2])/150 or 0
  end

  -- preprocess melee primary attack config
  if not config.primaryAbility.projectileParameters then
    if config.primaryAbility.damageConfig and config.primaryAbility.damageConfig.knockbackRange then
      config.primaryAbility.damageConfig.knockback = scaleConfig(parameters.primaryAbility.fireTimeFactor, config.primaryAbility.damageConfig.knockbackRange)
    end
    if not configParameter("noCooldownTimer") then
      parameters.primaryAbility.cooldownTime = config.primaryAbility.fireTime
    end
    if config.primaryAbility.class == "MeleeSlash" then
      parameters.primaryAbility.projectileType = config.primaryAbility.projectileType or randomFromList(config.primaryAbility.projectileTypes, seed, "projectileTypes") or false
    else
      parameters.primaryAbility.projectileType = config.primaryAbility.projectileType or randomFromList(config.primaryAbility.projectileTypes, seed, "projectileTypes")
    end 

  -- preprocess ranged primary attack config
  else
    config.primaryAbility.projectileType = randomFromList(config.primaryAbility.projectileType, seed, "projectileType")
    parameters.primaryAbility.projectileType = config.primaryAbility.projectileType
    config.primaryAbility.projectileCount = randomIntInRange(config.primaryAbility.projectileCount, seed, "projectileCount") or 1
    config.primaryAbility.fireType = randomFromList(config.primaryAbility.fireType, seed, "fireType") or "auto"
    config.primaryAbility.burstCount = randomIntInRange(config.primaryAbility.burstCount, seed, "burstCount") or 1
    config.primaryAbility.burstTime = randomInRange(config.primaryAbility.burstTime, seed, "burstTime")

    --nerf for shotguns
    if config.primaryAbility.projectileCount > 1 then
      if config.primaryAbility.energyUsage > 0 then
        config.primaryAbility.energyUsage = config.primaryAbility.energyUsage+(config.primaryAbility.projectileCount*1.4)
      end
    end
    if config.primaryAbility.projectileParameters.knockbackRange then
      config.primaryAbility.projectileParameters.knockback = scaleConfig(parameters.primaryAbility.fireTimeFactor, config.primaryAbility.projectileParameters.knockbackRange)
    end
  end

  --remove stance durations if needed
  local primary = config.primaryAbility
  if primary and primary.class == "GunFire" then
    if primary.stances and primary.stances.cooldown and primary.stances.cooldown.duration then
      local fireTime = parameters.primaryAbility.fireTime or config.primaryAbility.fireTime or 1.0
      if primary.stances.cooldown.duration > fireTime then
        primary.stances.cooldown.duration = fireTime
        if config.primaryAbility.energyUsage then
          config.primaryAbility.energyUsage = config.primaryAbility.energyUsage * 3
        end
      end
    end
  end

  --build palette swap directives
  config.paletteSwaps = "?replace"
  if builderConfig.palette then
    local palette = root.assetJson(util.absolutePath(directory, builderConfig.palette))
    for k, v in pairs(palette) do
      if type(v) == "table" then --since weaponcolors have a name string for some odd reason
        local selectedSwaps = randomFromList(palette[k], seed, "paletteSwaps-"..k)
        for k2, v2 in pairs(selectedSwaps) do
          config.paletteSwaps = string.format("%s;%s=%s",config.paletteSwaps,k2,v2)
        end
      end
    end
  end

  config.directives = parameters.directives or config.directives or ""
  replacePatternInData(config, nil, "<directives>", config.directives..(builderConfig.palette and config.paletteSwaps or ""))
  if config.directives ~= "" then
    if parameters.colorIndex then
      config.directives = "?replace"
      local selectedSwaps = config.colorOptions[parameters.colorIndex+1]
      for k, v in pairs(selectedSwaps) do
        config.directives = string.format("%s;%s=%s",config.directives,k,v)
      end
    end
  end

  -- merge extra animationCustom
  if builderConfig.animationCustom then
    util.mergeTable(config.animationCustom or {}, builderConfig.animationCustom)
  end

  -- animation parts
  if builderConfig.animationParts then
    config.animationParts = config.animationParts or {}
    if parameters.animationPartVariants == nil then parameters.animationPartVariants = {} end
    for k, v in pairs(builderConfig.animationParts) do
      if type(v) == "table" then
        if v.variants and (not parameters.animationPartVariants[k] or parameters.animationPartVariants[k] > v.variants) then
          parameters.animationPartVariants[k] = randomIntInRange({1, v.variants}, seed, "animationPart"..k)
        end
        config.animationParts[k] = util.absolutePath(directory, string.gsub(v.path, "<variant>", parameters.animationPartVariants[k] or ""))
        if v.fullbrights then
          for i = 1, #v.fullbrights do
            if parameters.animationPartVariants[k] == v.fullbrights[i] then
              config.animationCustom.animatedParts.parts[k].properties.fullbright = true
              glows = true
            end
          end
        end
        if v.paletteSwap then
          config.animationParts[k] = config.animationParts[k] .. config.directives .. config.paletteSwaps
        end
      else
        config.animationParts[k] = v
      end
    end
  end

  -- glow color. default to red if no color change found
  if glows and config.paletteSwaps then
    local glow = config.paletteSwaps
    local colour = glow:find("F32200=")
    if colour then
      glow = glow:sub(colour+7, colour+12)
      local rgb = #glow < 6 and {1, 1, 2, 2, 3, 3} or {1, 2, 3, 4, 5, 6}
      colour = {tonumber("0x"..glow:sub(rgb[1], rgb[2])), tonumber("0x"..glow:sub(rgb[3], rgb[4])), tonumber("0x"..glow:sub(rgb[5], rgb[6]))}
    else
      colour = {243, 34, 0}
    end
    config.animationCustom.lights.glow.color = colour
  end

  -- set gun part offsets
  local partImagePositions = {}
  if builderConfig.gunParts then
    construct(config, "animationCustom", "animatedParts", "parts")
    local imageOffset = {0,0}
    local gunPartOffset = {0,0}
    for _,part in ipairs(builderConfig.gunParts) do
      config.animationParts[part] = config.animationParts[part]..config.directives .. config.paletteSwaps
      local imageSize = root.imageSize(config.animationParts[part])
      construct(config.animationCustom.animatedParts.parts, part, "properties")

      imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
      config.animationCustom.animatedParts.parts[part].properties.offset = {config.baseOffset[1] + imageOffset[1] / 8, config.baseOffset[2]}
      partImagePositions[part] = copy(imageOffset)
      imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
    end
    config.muzzleOffset = vec2.add(config.baseOffset, vec2.add(config.muzzleOffset or {0,0}, vec2.div(imageOffset, 8)))
  end

  -- elemental fire sounds
  if config.fireSounds then
    construct(config, "animationCustom", "sounds", "fire")
    local sound = randomFromList(config.fireSounds, seed, "fireSound")
    config.animationCustom.sounds.fire = type(sound) == "table" and sound or {sound}
  end

  -- build inventory icon
  if not config.inventoryIcon and config.animationParts then
    config.inventoryIcon = jarray()
    local parts = builderConfig.iconDrawables or {}
    for _,partName in pairs(parts) do
      local drawable = {
        image = config.animationParts[partName],
        position = partImagePositions[partName]
      }
      table.insert(config.inventoryIcon, drawable)
    end
  end

  -- populate tooltip fields
  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields.dyeLabel = configParameter("sb_dyeable") and "^gray;(Dyeable)" or ""
  config.tooltipFields.levelLabel = "^shadow;Lvl "..string.format("%.0f",configParameter("level", 1))
  config.tooltipFields.level2Label = "Lvl "..string.format("%.0f",configParameter("level", 1))
  local fireTime = parameters.primaryAbility.fireTime or config.primaryAbility.fireTime or 1.0
  local baseDps = parameters.primaryAbility.baseDps or config.primaryAbility.baseDps or 0
  local energyUsage = parameters.primaryAbility.energyUsage or config.primaryAbility.energyUsage or 0
--  config.tooltipFields.handednessLabel = (config.twoHanded and "2" or "1").."-Handed ("..math.floor(configParameter("level", 1))..")"
  config.tooltipFields.dpsLabel = util.round(baseDps * config.damageLevelMultiplier, 1) --* config.damageLevelMultiplier, 1
  config.tooltipFields.speedLabel = util.round(1 / fireTime, 1)
  config.tooltipFields.damagePerShotLabel = util.round(baseDps * fireTime * config.damageLevelMultiplier, 1)
  config.tooltipFields.energyPerShotLabel = util.round(energyUsage * fireTime, 1)

  --do this before projectiles
  if elementalType ~= "physical" then
    config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
  end

  if config.primaryAbility then
    config.tooltipFields.primaryAbilityTitleLabel = "Primary:"
    config.tooltipFields.primaryAbilityLabel = config.primaryAbility.name or "unknown"
    if parameters.primaryAbility.projectileType then
      if type(parameters.primaryAbility.projectileType) == "string" then
        config.tooltipFields.damageKindImage = sb_assetmissing("/interface/sb_tooltips/"..parameters.primaryAbility.projectileType..".png", "/interface/sb_tooltips/assetmissing.png")
      elseif type(parameters.primaryAbility.projectileType) == "table" then
        local projectiles = parameters.primaryAbility.projectileType
      --todo: loop
        if #projectiles >= 1 then config.tooltipFields.damageKindImage = sb_assetmissing("/interface/sb_tooltips/"..projectiles[1]..".png","/interface/sb_tooltips/assetmissing.png") end
        if #projectiles >= 2 then config.tooltipFields.damageKindBImage = sb_assetmissing("/interface/sb_tooltips/"..projectiles[2]..".png","/interface/sb_tooltips/assetmissing.png") end
        if #projectiles >= 3 then config.tooltipFields.damageKindCImage = sb_assetmissing("/interface/sb_tooltips/"..projectiles[3]..".png","/interface/sb_tooltips/assetmissing.png") end
        if #projectiles >= 4 then config.tooltipFields.damageKindDImage = sb_assetmissing("/interface/sb_tooltips/"..projectiles[4]..".png","/interface/sb_tooltips/assetmissing.png") end
      end
    end
  end
  if config.altAbility then
    config.tooltipFields.altAbilityTitleLabel = "Special:"
    config.tooltipFields.altAbilityLabel = config.altAbility.name or "unknown"
  end
  config.price = (config.price or 10) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))
  if not config.fixedRarity then
    local rarities = {"common","uncommon","rare","legendary","essential"}
    config.rarity = rarities[root.evalFunction("sb_rarity", math.floor(configParameter("level", 1)))] or config.rarity or "legendary"
  end
  if config.rarity == "essential" then config.tooltipFields.rarityLabel = "Epic" end

  --logic for outdated weapons
  if not parameters.customItem then
    if config.itemName == "sb_bonehammer" and parameters.primaryAbilityType == "axecleave" then
      parameters.primaryAbilityType = "sb_hammer"
    end

    if parameters.primaryAbilityType == "axecleave" then
      parameters.primaryAbilityType = "sb_axe"
    end

    if parameters.primaryAbilityType == "sb_starcleaver" then
      parameters.primaryAbilityType = "sb_meleeslash"
    end

    if parameters.animation == "/items/active/starbound/weapons/broadswords/starcleaversword.animation" then
      parameters.animation = "/items/active/starbound/weapons/broadsword.animation"
    end
  end

  local tags = configParameter("tags")
  if tags then for k, v in pairs(tags) do replacePatternInData(config, nil, k, v) end end

  return config, parameters
end

function scaleConfig(ratio, value)
  if type(value) == "table" then
    return util.lerp(ratio, value[1], value[2])
  else
    return value
  end
end