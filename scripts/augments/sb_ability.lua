require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_builder", output:instanceValue("builder", "")):find("unrand")
    or output:instanceValue("sb_disallowAbilityMods", not output:instanceValue("twoHanded", true))
    or string.find(output:instanceValue("tooltipKind", "base"), "sup") --Supper's Combat Overhaul weapons tend to just eat the ability items. Possibly for the same reason as the Thorny Needler...?
  then return output:descriptor(), 0 end
  local slot = config.getParameter("slot", "alt").."AbilityType"
  local newAbility = config.getParameter("ability", "0")
  local currentAbility = output:instanceValue(slot, "1")
  local valid = false
  local category = string.gsub(output:instanceValue("category",""):lower(), " ", "")

  local weaponTypes = config.getParameter("weaponTypes", {category})
  for i = 1, #weaponTypes do
  --if string.find(name, weaponTypes[i]) or category == weaponTypes[i] then
    if string.find(category, weaponTypes[i]) then
      valid = true
      break
    end
  end

  local acceptedElements = config.getParameter("acceptedElements")
  if acceptedElements then
    isValidElement = false
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
--  if output:instanceValue("altAbility") then
--    otuput:setInstanceValue("altAbility", nil)
--  end
    return output:descriptor(), 1
  end
end