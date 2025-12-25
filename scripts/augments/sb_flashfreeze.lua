require "/scripts/augments/item.lua"
require "/scripts/sb_assetmissing.lua"

function apply(input)
  local output = Item.new(root.createItem(input))
  if output:instanceValue("sb_unfreezeable") then return output:descriptor(), 0 end
  local item = root.itemConfig(output.name)
  local directory = item.directory
  item = item.config

  if item.itemAgingScripts and not (output.name == "sb_preservedfood") then --I'd like to check for a rotTimeMultiplier in case some non-food items use a rotting script, but it defaults to 1 so not every item has it, and that's far more likely than someone implementing decaying isotopes in a popular mod
    local pp = config.getParameter("persistentParameters")
    for i = 1, #pp do
      output:setInstanceValue(pp[i], output:instanceValue(pp[i]))
    end
    output.parameters.originalItemName = output.name
    output.name = "sb_preservedfood"

    local icon = output.parameters.inventoryIcon
    local directives = config.getParameter("directives", "?fade=f9ed88;0.05")

    if icon then
      icon = type(icon) == "string" and sb_pathToImage(icon, directory)..directives or icon
      if type(icon) == "table" then
        for i = 1, #icon do
          icon[i].image = sb_pathToImage(icon[i].image, directory)..directives
        end
        if icon[2] and icon[3] then
          local foodRotBars = {"/interface/durability", "/interface/foodrotbar.png"}
          for i = 1, #foodRotBars do
            if icon[2].image:find(foodRotBars[i]) and icon[3].image:find(foodRotBars[i]) then
              icon[2] = nil
              icon[3] = nil
              local icons = 0
              for j = 1, #icon do
                icons = icons + 1
                if icons > 1 then
                  return
                end
              end
              if icons == 1 then
                icon = icon[1].image
              end
              break
            end
          end
        end
      end
    end
    output:setInstanceValue("inventoryIcon", icon)
    local newParams = config.getParameter("applyParameters",{})
    for k, v in pairs(newParams) do output:setInstanceValue(k,v) end
    newParams = config.getParameter("uniqueApplyParameters")[item.category or "other"]
    if newParams then for k, v in pairs(newParams) do output:setInstanceValue(k,v) end end --fix for only items with a category parameter (not config) working 

    if item.foodValue then
      local foodValue = config.getParameter("foodValueReduction")
      foodValue = math.floor(item.foodValue * foodValue)
      output:setInstanceValue("foodValue", foodValue)

      local fields = output:instanceValue("tooltipFields", {})
      foodValue = "Food: " .. math.floor(foodValue, 1)
      fields.foodAmountLabel = foodValue
      fields.foodValueLabel = foodValue
      fields.rotTimeLabel = ""
      fields.effectLabel = nil --New items have this as a parameter for a hot moment
      output:setInstanceValue("tooltipFields", fields)
    end

    local subtitles = root.assetJson("/items/categories.config:labels")
    local category = output:instanceValue("category", "other")
    local subtitle = output:instanceValue("subtitle")
    category = subtitle or category
    if category == "preparedFood" then category = "food" end
    category = string.gsub(category:gsub("sb_",""),"^%l", string.upper)
    output.parameters.subtitle = "sb_preserved"..category

    local maxStack = item.maxStack or 0
    if maxStack > root.assetJson("/items/defaultParameters.config:defaultMaxStack") then
      output.parameters.maxStack = maxStack
    end

    --Remove unwanted parameters and discard null parameters (including nested ones)
    local newParameters = {}
    local parametersToRemove, temp = {}, config.getParameter("parametersToRemove", {})
    for _, k in pairs(temp) do
      parametersToRemove[k] = true
    end
    temp = nil

    for k, v in pairs(output.parameters) do
      if (not parametersToRemove[k]) and output.parameters[k] ~= nil then
        if type(v) == "table" then
          local newV = {}
          for k2, v2 in pairs(v) do
            if v2 ~= nil then
              newV[k2] = v2
            end
          end
          v = newV
        end
        newParameters[k] = v
      end
    end
    
    output.parameters = newParameters

    return output:descriptor(), 1
  end
end