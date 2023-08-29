function build(directory, config, parameters)
  if parameters.sb_paintData then
    desc = root.itemConfig("sb_paint").config.shortdescription
    local itemC = root.itemConfig({name=parameters.sb_paintData[1]})
    parameters.sb_paint = parameters.sb_paintData[2]
    local inv = jarray()

    local img = itemC.directory..itemC.config.inventoryIcon
    parameters.tooltipFields = config.tooltipFields or {}
    parameters.tooltipFields.damageKindImage = img.."?hueshift="..parameters.sb_paint
    parameters.tooltipFields.damageKindBImage = img
  
    table.insert(inv,{image=cropImage(img).."?hueshift="..parameters.sb_paint})
    table.insert(inv,{image="paint.png"})
    if string.lower(itemC.config.rarity) ~= "common" then table.insert(inv,{image="lids.png:"..string.lower(itemC.config.rarity),position={0,4.5}}) end
    parameters.shortdescription = string.format(desc,itemC.config.materialId.."-"..parameters.sb_paint)
    parameters.rarity = itemC.config.rarity or "common"
    parameters.inventoryIcon = inv
    parameters.sb_paintData = nil
  end

  if parameters.sb_paint and not parameters.version then 
    local inv = jarray()
    table.insert(inv,parameters.inventoryIcon[1])
    table.insert(inv,{image="paint.png"})
    if string.lower(parameters.rarity) ~= "common" then table.insert(inv,{image="lids.png:"..string.lower(parameters.rarity),position={0,4.5}}) end
    parameters.inventoryIcon = inv
  end
  parameters.version = 1

  return config, parameters
end

function cropImage(a) if root.imageSize(a)[1]==16 and root.imageSize(a)[2]==16 then return a.."?crop=;4;4;12;16" else return a end end