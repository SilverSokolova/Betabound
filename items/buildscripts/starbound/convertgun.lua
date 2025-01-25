function build(_, c, p)
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

  c.itemName = c.convertTo or c.itemName:sub(4)
  return c, p
end