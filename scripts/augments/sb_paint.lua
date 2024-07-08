require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if root.itemConfig(output.name).config.materialId then
    local newHueshift = config.getParameter("sb_paint", 0)
    local oldHueshift = output:instanceValue("materialHueShift", 1)
    if newHueshift ~= oldHueshift then
      output:setInstanceValue("materialHueShift", newHueshift)
      return output:descriptor(), 1
    end
  end
end