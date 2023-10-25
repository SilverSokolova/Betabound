require "/scripts/augments/item.lua"
--TODO: check the item type instead of having different tools. activeitems are reversed
--Maybe we could make them repair percentages instead
function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_unrepairable") then return output:descriptor(), 0 end
  local durabilityRegen = config.getParameter("durabilityRegen", 0)
  local count = 1
  if durabilityRegen then
    if (root.itemConfig(output.name).config.sb_repairType or nil) == config.getParameter("sb_repairType", nil) then --We could have it check primaryAbility.class for BeamMine if other mods add laser miners...
      local baseDurability = root.itemConfig(output.name).config.durability or 0
      if output:instanceValue("durabilityHit", nil) then
        if (durabilityRegen > 0) and output:instanceValue("durabilityHit") <= 0 then output:setInstanceValue("durabilityHit",0) count = 0 end
        if (durabilityRegen < 0) and output:instanceValue("durabilityHit") >= baseDurability then output:setInstanceValue("durabilityHit",baseDurability) count = 0 end
        if count == 1 then output:setInstanceValue("durabilityHit", output:instanceValue("durabilityHit") - durabilityRegen) end
        if (durabilityRegen > 0) and output:instanceValue("durabilityHit") <= 0 then output:setInstanceValue("durabilityHit",0) end
        if (durabilityRegen < 0) and output:instanceValue("durabilityHit") >= baseDurability then output:setInstanceValue("durabilityHit",baseDurability) end
        return output:descriptor(), count
      end
    end
  end
end