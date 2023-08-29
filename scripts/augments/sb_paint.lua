require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if root.itemConfig(output.name).config.materialId then
    output:setInstanceValue("materialHueShift",config.getParameter("sb_paint",0))
    return output:descriptor(), 1
  end
end