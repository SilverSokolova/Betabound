require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_builder", output:instanceValue("builder", "")):find("unrand")
    or output:instanceValue("sb_disallowAbilityMods", not output:instanceValue("twoHanded", true))
    or string.find(output:instanceValue("tooltipKind", "base"), "sup") --Supper's Combat Overhaul weapons tend to just eat the ability items. Possibly for the same reason as the Thorny Needler...?
  then return output:descriptor(), 0 end
  local slots = config.getParameter("slots")
  local quantity = 0
  for h = 1, #slots do
    local slot = slots[h].."AbilityType"
    slotName = slot:match("[a-z]+").."Abilities"
    local currentAbility = output:instanceValue(slot, "1")
    valid = false
    local itemName = output:instanceValue("itemName")

    for i = 1, 10 do
      newAbility = getRandomAbility(itemName)
      if newAbility and newAbility ~= currentAbility then
        break
      end
    end

    if newAbility then
      valid = true
      local elementalConfig = root.assetJson(root.assetJson("/items/buildscripts/weaponabilities.config")[newAbility]).ability.elementalConfig
      if elementalConfig then
        acceptedElements = {}
        for k, v in pairs(elementalConfig) do
          for _, _ in pairs(v) do --we have to do this because there's no table.size and one *elemental* vanilla ability has a blank elemental config for *physical*
            acceptedElements[#acceptedElements+1] = k
            break
          end
        end
      end
    end

    if acceptedElements then
      local isValidElement = false
      local element = output:instanceValue("elementalType", "physical")
      for i = 1, #acceptedElements do
        if element == acceptedElements[i] then
          isValidElement = true
          break
        end
      end
      if not isValidElement then valid = false end
    end

    if valid and newAbility ~= currentAbility then
      output:setInstanceValue(slot, newAbility)
      quantity = 1
    end
  end
  return output:descriptor(), quantity
end

function getRandomAbility(itemName)
  local abilities = false
  local builderConfig = root.itemConfig(itemName)
  builderConfig = builderConfig and builderConfig.config.builderConfig or nil
  if builderConfig then
    for i = 1, #builderConfig do
      local possibleAbilities = builderConfig[i][slotName]
      if possibleAbilities then
        abilities = possibleAbilities[math.random(#possibleAbilities)]
        break
      end
    end
  end
  return abilities
end