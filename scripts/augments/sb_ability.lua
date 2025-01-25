require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_builder", output:instanceValue("builder", "")):find("unrand")
    or output:instanceValue("sb_disallowAbilityMods", not output:instanceValue("twoHanded", true))
    or string.find(output:instanceValue("tooltipKind", "base"), "sup") --Supper's Combat Overhaul weapons tend to just eat the ability items. Possibly for the same reason as the Thorny Needler...?
  then return output:descriptor(), 0 end
  local slot = config.getParameter("slot", "alt").."AbilityType"
  slotName = slot:match("[a-z]+").."Abilities"
  local currentAbility = output:instanceValue(slot, "1")
  newAbility = config.getParameter("ability", "0")
  element = output:instanceValue("elementalType", "physical")
  valid = false

  local rarities = {"common", "uncommon", "rare", "legendary", "essential"}
  local itemName = output:instanceValue("itemName")
  for i = 1, #rarities do
    if itemName:find(rarities[i]) then
      currentRarity = i
    end
  end

  for i = 1, currentRarity and #rarities or 1 do
    if valid then
      break
    end
    checkPossibleAbilities(currentRarity and itemName:gsub(rarities[currentRarity], rarities[i]) or itemName)
  end

  local acceptedElements = config.getParameter("acceptedElements")
  if acceptedElements then
    local isValidElement = false
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
--    if output:instanceValue("altAbility") then
--      output:setInstanceValue("altAbility", {name="test"})
--    end
    return output:descriptor(), 1
  end
end

function checkPossibleAbilities(itemName)
  local builderConfig = root.itemConfig(itemName)
  builderConfig = builderConfig and builderConfig.config.builderConfig or nil
  if builderConfig then
    for i = 1, #builderConfig do
      local possibleAbilities = builderConfig[i][slotName.."_"..element] or builderConfig[i][slotName]
      if possibleAbilities and #possibleAbilities > 0 then
        for j = 1, #possibleAbilities do
          if possibleAbilities[j] == newAbility then
            valid = true
            break
          end
        end
      end
    end
  end
end