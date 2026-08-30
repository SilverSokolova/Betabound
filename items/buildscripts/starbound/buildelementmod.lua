require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  parameters.element = parameters.element or randomFromList(parameters.elementList or config.elementList)
  elementName = root.assetJson("/items/augments/sb_elementmod/elementmods.config")[parameters.element]
  config.shortdescription = string.format(config.shortdescription, string.gsub(elementName or parameters.element, "^%l", string.upper))

  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "/items/generated/sb_mod.png"})
  table.insert(config.inventoryIcon, {image = sb_assetmissing(directory .. "icons/" .. parameters.element .. ".png")})


  if parameters.level then
    parameters.level = nil
  end

  if parameters.elementList then
    parameters.elementList = nil
  end
  return config, parameters
end

function randomFromList(list)
  return list[math.random(#list)]
end