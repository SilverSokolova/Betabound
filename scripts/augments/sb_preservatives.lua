require "/scripts/augments/item.lua"
require "/scripts/sb_assetmissing.lua"

function apply(input)
  local output = Item.new(input)
  local item = root.itemConfig(output.name)
  local directory = item.directory
  item = item.config
  if item.itemAgingScripts and not output:instanceValue("sb_preserved2") then --I'd like to check for a rotTimeMultiplier in case some non-food items use a rotting script, but it defaults to 1 so not every item has it, and that's far more likely than someone implementing decaying isotopes in a popular mod
    local pp = config.getParameter("persistentParameters")
    for i = 1, #pp do
      output:setInstanceValue(pp[i], output:instanceValue(pp[i]))
    end
    output.name = "sb_preservedfood"

    local icon = output.parameters.inventoryIcon
    local fade = config.getParameter("fade","?fade=f9ed88;0.05")
    if icon then
      icon = type(icon) == "string" and sb_pathToImage(icon, directory)..fade or icon
      if type(icon) == "table" then
	for i = 1, #icon do
          icon[i].image = sb_pathToImage(icon[i].image, directory)..fade
        end
      end
    end
    output:setInstanceValue("inventoryIcon",icon)
    local category = item.category
    local newParams = config.getParameter("applyParameters",{})
    for k, v in pairs(newParams) do output:setInstanceValue(k,v) end
    newParams = config.getParameter(category.."ApplyParameters")
    if newParams then for k, v in pairs(newParams) do output:setInstanceValue(k,v) end end --fix for only items with a category parameter working 

    if item.foodValue then
      local foodValue = config.getParameter("foodValueReduction")
      foodValue = item.foodValue * foodValue
      output:setInstanceValue("foodValue", foodValue)

      local fields = output:instanceValue("tooltipFields",{})
      foodValue = "Food: "..math.floor(foodValue,1)
      fields.foodAmountLabel = foodValue
      fields.foodValueLabel = foodValue
      output:setInstanceValue("tooltipFields",fields)
    end

    output.parameters.maxStack = root.assetJson("/items/defaultParameters.config:defaultMaxStack")
    output.parameters.timeToRot = nil
    output.parameters.animation = nil
    output.parameters.scripts = nil

    return output:descriptor(), 1
  end
end