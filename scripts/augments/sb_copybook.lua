require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_uncopyable") or string.sub(output.name, -7) == "-recipe" then return output:descriptor(), 0 end --Blueprints aren't stackable nor do they have a maxStack value
  local count = 0
  local maxStack = output:instanceValue("maxStack", root.assetJson("/items/defaultParameters.config:defaultMaxStack"))
  local conditions = config.getParameter("sb_copybookConditions")
  if output.count < maxStack then
    if conditions then
      if hasValue(string.lower(output:instanceValue("category", "")), conditions.categories or {}) or hasValue(output.name, conditions.itemTags or {}, true) then
        count = 1
        output.count = output.count + 1
      end
    end
  end
  return output:descriptor(), count
end

function hasValue(target, values, checkTags)
  local valid = false
  for i = 1, #values do
    valid = checkTags and root.itemHasTag(target, values[i]) or (target == values[i])
    if valid then break end
  end
  return valid
end