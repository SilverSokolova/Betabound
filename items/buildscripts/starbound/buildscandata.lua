require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  recipeList = config.recipeList or parameters.recipeList
  parameters.recipe = parameters.recipe or (recipeList and recipeList[math.random(#recipeList)]) or "apexshiplight"
  itemConfig = root.itemConfig(parameters.recipe)
  if (not itemConfig) or (tostring(itemConfig.config.printable or false) == "false") then
    sb.logError("[Betabound] Tried to make scandata item with unprintable item: "..parameters.recipe)
    parameters.recipe = "apexshiplight"
    itemConfig = root.itemConfig(parameters.recipe)
  end
  directory = itemConfig.directory; itemConfig = itemConfig.config
  --I'd do something for sb_objectName here but I'll figure that out when it becomes relevant. Which is hopefully never.

  config.inventoryIcon = jarray()
  local icon = itemConfig.inventoryIcon or "/interface/sb_tooltips/assetmissing.png"
  if icon then
    if type(icon) == "table" then icon = icon[1].image end
    if icon:sub(0, 1) ~= "/" then icon = directory..icon end
  end
  table.insert(config.inventoryIcon, icon and {image = icon})
  table.insert(config.inventoryIcon, {image = "sb_scandata.png", position = {5.5, -3}})

  local shortdesc = itemConfig.shortdescription or "Unknown Item"
  config.shortdescription = string.format(config.shortdescription, shortdesc)
  config.description = string.format(config.description, shortdesc)
  config.rarity = itemConfig.rarity or config.rarity

  if parameters.level then
    parameters.level = nil
  end
  if parameters.recipeList then
    parameters.recipeList = nil
  end
  return config, parameters
end