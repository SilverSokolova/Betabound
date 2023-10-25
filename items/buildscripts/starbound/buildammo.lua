require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  parameters.projectileType = parameters.projectileType or randomProjectile(config.projectileTypes)
  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "sb_ammo.png"})
  table.insert(config.inventoryIcon, {image = sb_assetmissing("/interface/sb_tooltips/"..parameters.projectileType..".png", "/interface/sb_tooltips/assetmissing.png")})
  if root.assetJson("/items/defaultParameters.config:defaultMaxStack") < 9999 then config.maxStack = 9999 end
  config = sb.jsonMerge(config,getDescriptor(parameters.projectileType))
  if parameters.level then
    parameters.level = nil
  end
  return config, parameters
end

function randomProjectile(a)
  return a[math.random(#a)]
end

function getDescriptor(a)
  local descriptor = root.assetJson("/sb_projectiles.config")[a] or nil
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