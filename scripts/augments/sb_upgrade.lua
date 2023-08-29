require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_unupgradeable") then return output:descriptor(), 0 end
  local newLevel = config.getParameter("newLevel",0)
  local level = output:instanceValue("level", 1)
  local upgradeable = false

  local tags = output:instanceValue("itemTags",{})
  for i = 1, #tags do
    if tags[i] == "weapon" then
      upgradeable = true
      break
    end
  end

--upgradeable = output:instanceValue("primaryAbility",upgradeable)

  if upgradeable and level < newLevel then
    output:setInstanceValue("level", newLevel)
    return output:descriptor(), 1
  end
end