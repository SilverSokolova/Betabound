function build(_, c, p)
  c.rarity = "rare"
  local a = c.convertTo or c.itemName:sub(4)
  if type(a) == "string" then a = {a} end
  c.itemName = a[math.random(#a)]
  return c, p
end