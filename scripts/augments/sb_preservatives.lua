require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  if output:instanceValue("sb_unpreserveable") then return output:descriptor(), 0 end
  local item = root.itemConfig(output.name).config
  local itemAgingScripts = item.itemAgingScripts or {}
  if next(itemAgingScripts) then
    local timeToRot = root.assetJson("/items/rotting.config:baseTimeToRot") * (output.parameters.rottingMultiplier or output.config.rottingMultiplier or 1)
    if output.parameters.timeToRot < timeToRot then
      --Check if there are any other tooltipFields. If not, delete the whole thing so it stacks with items that havent generated theirs, otherwise just remove the rotTimeLabel
      local fields = 0
      if output.parameters.tooltipFields then --Oh, woe is me, for # cannot return the size of a table.
        for _, _ in pairs(output.parameters.tooltipFields) do
          fields = fields + 1
          if fields > 1 then break end
        end
        if fields > 1 then
          require(itemAgingScripts[1])
          if getRotTimeDescription then
            rotTimeLabel = getRotTimeDescription(timeToRot) --If this causes issues, run ageItem
          end
          output.parameters.tooltipFields.rotTimeLabel = rotTimeLabel --If we don't get a rotTimeLabel, does it really matter if we toss the old one out?
        end
      end
      output.parameters.timeToRot = nil
      if not rotTimeLabel then
        output.parameters.tooltipFields = nil
      end
      return output:descriptor(), 1
    end
  end
end