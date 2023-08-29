function build(_, c, p)
  c.rarity = "rare"
  local a = c.convertTo or "sb_blankblueprint"
  if a ~= "sb_blankblueprint" then
    if type(a) == "string" then a = {a} end
    p.items = a
    p.tooltipKind = "sb_tech"
    p.description = root.assetJson("/betabound.config:convert3description")
    p.maxStack = root.assetJson("/items/defaultParameters.config:defaultMaxStack")
    c.itemName = "sb_itembox"
  else
    c.itemName = a
  end
  return c, p
end