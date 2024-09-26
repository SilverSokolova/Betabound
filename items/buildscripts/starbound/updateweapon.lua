function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end

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

    if config.animation == "/items/active/starbound/weapons/comboshortsword.animation" and parameters.primaryAbilityType == "sb_meleeslash2" then
      parameters.primaryAbilityType = "sb_shortswordcombo"
    end

    if config.itemName == "sb_flamethrower" then
      if not parameters.elementalType then
        if config.itemName == "sb_flamethrower" then
          local projectile = parameters.primaryAbility and parameters.primaryAbility.projectileType
          if type(projectile) == "string" then
            local projectileMap = {
              flamethrower = "fire",
              icethrower = "ice",
              poisonthrower = "poison",
              lightningthrower = "electric"
            }
            parameters.elementalType = projectileMap[projectile]
          end
        end
      end
    end
  end

  return config, parameters
end