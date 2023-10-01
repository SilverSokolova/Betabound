require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  local item = root.itemConfig(output.name).config
  local itemAgingScripts = item.itemAgingScripts
  if itemAgingScripts and #itemAgingScripts ~= 0 then
    local timeToRot = root.assetJson("/items/rotting.config:baseTimeToRot") * (output.parameters.rottingMultiplier or output.config.rottingMultiplier or 1)
    if output.parameters.timeToRot < timeToRot then
      --Check if there are any other tooltipFields. If not, delete the whole thing so it stacks with items that havent generated theirs, otherwise just remove the rotTimeLabel
      local fields = 0
      for _, _ in pairs(output.parameters.tooltipFields) do
        fields = fields + 1
        if fields > 1 then break end
      end
      if fields > 1 then
        require(itemAgingScripts[1])
        rotTimeLabel = getRotTimeDescription(timeToRot) --If this causes issues, run ageItem
      end
      output.parameters.timeToRot = nil
      output.parameters.tooltipFields.rotTimeLabel = rotTimeLabel
      if not rotTimeLabel then
        output.parameters.tooltipFields = nil
      end
      return output:descriptor(), 1
    end
  end
end