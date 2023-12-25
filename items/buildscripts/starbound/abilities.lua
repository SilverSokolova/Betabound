require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

local abilityTablePath = "/items/buildscripts/weaponabilities.config"
local abilities = nil

function getAbilitySourceFromType(abilityType)
  if not abilityType then return nil end
  if not abilities then
    abilities = root.assetJson(abilityTablePath)
  end
  return abilities[abilityType]
end

function getAbilitySource(config, parameters, abilitySlot)
  local typeKey = abilitySlot .. "AbilityType"
  local abilityType = parameters[typeKey] or config[typeKey]

  return getAbilitySourceFromType(abilityType)
end

function addAbility(config, parameters, abilitySlot, abilitySource)
  if abilitySource then
    local abilityConfig = root.assetJson(abilitySource)

    local abilityType = abilityConfig.ability.type
    abilityConfig[abilitySlot .. "Ability"] = abilityConfig.ability
    abilityConfig.ability = nil

    local newConfig = util.mergeTable(abilityConfig, config)
    util.mergeTable(config, newConfig)

    if abilitySlot == "primary" then
      local rotate = parameters.allowRotate or root.assetJson("/items/active/weapons/melee/abilities/broadsword/broadswordcombo.weaponability").ability.stances.fire1.allowRotate or false
      if config.primaryAbility.stances and rotate then
        for k, v in pairs(config.primaryAbility.stances) do
          if k == "idle" then
            config.primaryAbility.stances[k].aimAngle = 0
          else
            util.mergeTable(config.primaryAbility.stances[k], {allowRotate = true, allowFlip = true})
          end
        end
      end
    end

    parameters[abilitySlot .. "AbilityType"] = abilityType
  end
end

function setupAbility(config, parameters, abilitySlot, builderConfig, seed, elementalType)
  seed = seed or parameters.seed or config.seed or 0

  local abilitySource = getAbilitySource(config, parameters, abilitySlot)
  if not abilitySource and builderConfig then
    local abilitiesKey = builderConfig[abilitySlot .. "Abilities_" .. elementalType] and (abilitySlot .. "Abilities_" .. elementalType) or abilitySlot .. "Abilities"
    if builderConfig[abilitiesKey] and #builderConfig[abilitiesKey] > 0 then
      local abilityType = randomFromList(builderConfig[abilitiesKey], seed, abilitySlot .. "AbilityType")
      abilitySource = getAbilitySourceFromType(abilityType)
    end
  end

  if abilitySource then
    addAbility(config, parameters, abilitySlot, abilitySource)
  end
end