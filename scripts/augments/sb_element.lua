require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_builder", output:instanceValue("builder", "")):find("unrand")
    or output:instanceValue("sb_disallowElementMods", not output:instanceValue("twoHanded", true))
    or string.find(output:instanceValue("tooltipKind", "base"), "sup") --cant imagine supper's eating the element mods but who knows. test later TODO:
  then return output:descriptor(), 0 end
  local newElement = config.getParameter("element", "0")
  local currentElement = output:instanceValue("elementalType", "1")
  if newElement == currentElement then
    return
  end
  local valid = false

  local builderConfig = output:instanceValue("builderConfig")
  if builderConfig then
    builderConfig = builderConfig[math.random(#builderConfig)]
    canRerollAbility = builderConfig["altAbilities_"..newElement]
    local possibleElements = builderConfig.elementalType or {}
    for i = 1, #possibleElements do
      if possibleElements[i] == newElement then
        valid = true
        break
      end
    end
  end

  local altAbility = output:instanceValue("altAbilityType")
  if valid and altAbility then
    local validElements = {}
    local elementalConfig = root.assetJson(root.assetJson("/items/buildscripts/weaponabilities.config")[altAbility]).ability.elementalConfig
    if elementalConfig then
      for k, v in pairs(elementalConfig) do
        for _, _ in pairs(v) do --we have to do this because there's no table.size and one *elemental* vanilla ability has a blank elemental config for *physical*
          validElements[k] = 1
          break
        end
      end
      valid = validElements[newElement]
      if canRerollAbility then
        output:setInstanceValue("altAbilityType", canRerollAbility[math.random(#canRerollAbility)])
        valid = true
      end
    end
  end
  
  if valid then
    output:setInstanceValue("elementalType", newElement)
  end

  return output:descriptor(), valid and 1 or 0
end