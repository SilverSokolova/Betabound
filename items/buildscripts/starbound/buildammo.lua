require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  parameters.projectileType = parameters.projectileType or randomProjectile(config.projectileTypes)
  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "ammo.png"})
  table.insert(config.inventoryIcon, {image = sb_assetmissing("/items/generic/sb_ammo/icons/"..parameters.projectileType..".png")})

  if root.assetJson("/items/defaultParameters.config:defaultMaxStack") < 9999 then
    config.maxStack = 9999
  else
    config.maxStack = nil
  end

  config = sb.jsonMerge(config, getDescriptor(parameters.projectileType) or {})

  if parameters.level then
    parameters.level = nil
  end

  return config, parameters
end

function randomProjectile(a)
  return a[math.random(#a)]
end

function getDescriptor(a)
  local descriptor = root.assetJson("/items/generic/sb_ammo/ammo.config")[a]
  if descriptor then
    if type(descriptor) == "string" then
      return {shortdescription=descriptor}
    else
      local name = descriptor[1]
      descriptor = descriptor[2]
      descriptor.shortdescription = name
      return descriptor
    end
  end
end