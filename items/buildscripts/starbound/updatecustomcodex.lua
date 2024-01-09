require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  local icon = parameters.inventoryIcon or ""
  if icon:sub(1, 1) == "/" then
    if not root.nonEmptyRegion(icon) then
      parameters.codexIcon = root.assetJson("/items/buildscripts/starbound/customcodex.config")[icon]
      parameters.inventoryIcon = parameters.codexIcon
    end
  end

  return config, parameters
end