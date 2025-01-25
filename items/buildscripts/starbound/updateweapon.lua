--[[
I'm not going to erase people's save data every time weapon changes
results in bricked characters, so this is what we're doing since we
also can't access item versioning scripts. Bah! I decided to do it
this way rather than implementing a 'version' parameter on weapons
because I can't hunt down every weapon and up their version, so
better to just do it automatically.
]]

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end

  if not parameters.customItem then
    if parameters.primaryAbilityType == "axecleave"
    or parameters.primaryAbilityType == "sb_starcleaver"
    or parameters.primaryAbilityType == "sb_meleeslash2"
    or parameters.animation == "/items/active/starbound/weapons/broadswords/starcleaversword.animation"
    or (config.itemName == "sb_buster" and parameters.primaryAbilityType == "bowshot")
    or (config.itemName == "sb_slimestaff" and parameters.altAbilityType == "elementbouncer")
    or (config.primaryAbilityType == "sb_shortswordcombo" and parameters.primaryAbilityType == "sb_meleeslash2")
    or (config.primaryAbilityType == "sb_meleeslash" and parameters.primaryAbilityType == "broadswordcombo")
    or (config.primaryAbilityType == "sb_hammer" and parameters.primaryAbilityType == "sb_meleeslash") --candy cane, broadsword to hammer
    then
      parameters.primaryAbilityType = config.primaryAbilityType
      parameters.primaryAbility = config.primaryAbility

      parameters.altAbilityType = config.altAbilityType
      parameters.altAbility = config.altAbility
      parameters.animation = nil
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