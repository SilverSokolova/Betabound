require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  elementName = root.assetJson("/sb_elementmods.config")
  parameters.element = parameters.element or randomElement(parameters.elementList or config.elementList)
  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "/items/generated/sb_mod.png"})
  table.insert(config.inventoryIcon, {image = sb_assetmissing(directory..parameters.element..".png")})
  config.shortdescription = string.format(config.shortdescription, string.gsub(elementName[parameters.element] or parameters.element, "^%l", string.upper))

  if parameters.level then
    parameters.level = nil
  end
  if parameters.elementList then
    parameters.elementList = nil
  end
  return config, parameters
end

function randomElement(elementList)
  return elementList[math.random(#elementList)]
end