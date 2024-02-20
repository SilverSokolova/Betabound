require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters)
  missingImage = "/interface/sb_tooltips/assetmissing.png"
  if parameters.techModule then parameters.techModule = getTech(parameters.techModule) end
  if parameters.techModules then
    parameters.techModules[1] = getTech(parameters.techModules[1])
    parameters.techModules[2] = getTech(parameters.techModules[2])
  end

  if parameters.techModule then
    if parameters.inventoryIcon then
      if type(parameters.inventoryIcon) == "table" then
        local newIcon = sb_assetmissing(root.hasTech(parameters.techModule) and root.techConfig(parameters.techModule).icon or missingImage, missingImage)
        parameters.inventoryIcon[2].image = sb_assetmissing(parameters.inventoryIcon[2].image, newIcon)
      end
    end
  end

  if parameters.techModules and parameters.tooltipFields then
    for i = 1, 2 do
      if parameters.tooltipFields then
        local newIcon = sb_assetmissing(root.hasTech(parameters.techModules[i]) and root.techConfig(parameters.techModules[i]).icon or missingImage, missingImage)
        local target = "object"..(i==1 and 'B' or 'C').."Image"
        parameters.tooltipFields[target] = sb_assetmissing(parameters.tooltipFields[target], newIcon)
      end
    end
  end

  return config, parameters
end

function getTech(a)
  return root.assetJson("/versioning/sb_tech.config")[a] or a or ""
end