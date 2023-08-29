require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  local exchange = 0
  local defaults = {"codex","sb_copybook",{}}
  local maxStack = output:instanceValue("maxStack",root.itemConfig(output.name).config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack"))
    local category = output:instanceValue("category","")
    if (string.lower(category) == config.getParameter("sb_copybookTypes",defaults)[1]) or output:instanceValue(config.getParameter("sb_copybooktypes",defaults)[2],false) or output.name == config.getParameter("sb_copybooktypes",defaults)[3] then
    if output.count < maxStack then exchange = 1 end
    output.count = output.count + exchange end
  return output:descriptor(), exchange
end