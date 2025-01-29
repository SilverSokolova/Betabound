function build(_, c, p)
  c.rarity = "rare"

  local newItemName = c.newItemName or c.itemName:sub(4)
  if type(newItemName) == "string" then newItemName = {newItemName} end
  c.itemName = newItemName[math.random(#newItemName)]

  local persistentParameters = c.persistentParameters
  local newParameters = {}
  if persistentParameters then
    if #persistentParameters == 0 then
      newParameters = p
    else
      for i = 1, #persistentParameters do
        newParameters[persistentParameters[i]] = p[persistentParameters[i]]
      end
    end
  end

  if c.refund then
    newParameters.tooltipKind = "sb_tech"
    newParameters.maxStack = root.assetJson("/items/defaultParameters.config:defaultMaxStack")
    newParameters.description = root.assetJson("/betabound.config:removedItemRefundDescription")
    newParameters.items = c.refund
    c.itemName = "sb_itembox"
  elseif c.isOldWeapon then
    if p.primaryAbility then
      p.primaryAbility.projectileType = nil
    end

    if c.itemName:find("plasma") then
      p.altAbilityType = nil
      p.altAbility = nil
    end

    if p.elementalType then
      p.elementalType = nil
    end

    newParameters = p
  end

  return c, newParameters
end