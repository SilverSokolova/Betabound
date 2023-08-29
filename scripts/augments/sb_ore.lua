require "/scripts/augments/item.lua"

function apply(input)
  local ore = config.getParameter("durabilityRegen",0)
  local output = Item.new(input)
  local count = 1
  if ore then
    local type = root.itemConfig(output.name).config.sb_repairType or nil
    local canRepair = type == config.getParameter("sb_repairType",nil) -- == (ore < 0)
    if canRepair then
      local base = root.itemConfig(output.name).config.durability or 0
      if output:instanceValue("durabilityHit", nil) then
	if (ore > 0) and output:instanceValue("durabilityHit") <= 0 then output:setInstanceValue("durabilityHit",0) count = 0 end
	if (ore < 0) and output:instanceValue("durabilityHit") >= base then output:setInstanceValue("durabilityHit",base) count = 0 end
	if count == 1 then output:setInstanceValue("durabilityHit",output:instanceValue("durabilityHit") - ore) end
	if (ore > 0) and output:instanceValue("durabilityHit") <= 0 then output:setInstanceValue("durabilityHit",0) end
	if (ore < 0) and output:instanceValue("durabilityHit") >= base then output:setInstanceValue("durabilityHit",base) end
	return output:descriptor(), count
      end
    end
  end
end