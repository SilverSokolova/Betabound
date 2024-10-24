require("/scripts/sb_assetmissing.lua")

function build(_, config, parameters); sb_techType()
  local missingImage = "/interface/sb_tooltips/assetmissing.png"

  --equipper
  if parameters.techModule then
    if not root.hasTech(parameters.techModule) then
      parameters.techModule = getTech(parameters.techModule)
    end

    if not parameters.inventoryIcon then
      parameters.inventoryIcon = config.inventoryIcon
    end
    parameters.inventoryIcon[2].image = sb_assetmissing(root.techConfig(parameters.techModule).icon or missingImage, missingImage)
  --swapper
  elseif parameters.techModules then
    for i = 1, 2 do
      if not root.hasTech(parameters.techModules[i]) then
        parameters.techModules[i] = getTech(parameters.techModules[i])
      end

      config.tooltipFields[string.format("object%sImage", i == 1 and "B" or "C")] = sb_assetmissing(root.techConfig(parameters.techModules[i]).icon or missingImage, missingImage)
    end
  end

  return config, parameters
end

function getTech(a)
  return root.assetJson("/versioning/sb_tech.config")[a] or "doublejump"
end