--As much as I don't want to do this... This is just slightly modified code from the original author. Gotta make Betabound weapons work with it (paletteSwap stuff)...
--If they didn't want me to hook like this, they shouldn't have put the entire mod into one function! If only they used functions instead of pasting the same code five times...
--Needless to say, the code below (sans the sb_doPaletteSwaps function) is from the original Item Frames mod!

function containerCallback()
  local item = world.containerItems(entity.id())[1]
  if type(item) ~= "table" then item = {""} end
  if table.tostring(item) == storage.heldItemString then return false end
  storage.heldItemString = table.tostring(item)
  if type(item) ~= "table" or not item.name then
    storage.iconString = "default.png"
    storage.drawableList = nil
    setDisplay()
    return nil
  end
  if item.name == "sapling" then
    storage.iconString = "default.png"
    storage.drawableList = {}
    for i, drawable in pairs(buildSapling(item.parameters)) do
      local drawPos = drawable.position or {0,0}
      local drawImage = drawable.image
      table.insert(storage.drawableList, {position = drawPos, image = drawImage, scale = drawable.scale, background = drawable.background})
    end
    storage.drawableList = shrinkWeapon(storage.drawableList)
    setDisplay()
    return nil
  end

  --if not item.name:find("sb_") then sb_containerCallback() setDisplay() return end --Shouldn't we check if it STARTS with sb_ instead of just HAVING it? ALSO IT DOESNT WORK
  --I tried it with and without setDisplay, but it only updates the frame if it's a Betabound item! What the hell!

  itemRoot = root.itemConfig(item.name)
  itemRootAgain = root.itemConfig(item.name)
  storage.drawableList = nil
  
  if (root.itemType(item.name) == "activeitem" and itemRoot.config.animation == "/items/active/weapons/bow/bow.animation" and peaslyDeepCompare(itemRoot.config, itemRootAgain.config)) then
    storage.iconString = "default.png"
    storage.drawableList = {}
    local newDrawables = {}
    for part,image in pairs(item.parameters.animationParts or itemRoot.config.animationParts) do      
      newDrawables[part] = {position = itemRoot.config.baseOffset or {0,0}, image = itemRoot.directory..image..":3"}
    end
    newDrawables["muzzleFlash"] = nil
    newDrawables = shrinkWeapon(newDrawables)
    for i, drawable in pairs(newDrawables) do
      local drawPos = drawable.position or {0,0}
      table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
    end
  elseif (root.itemType(item.name) == "activeitem" and item.parameters.animationParts) then
    storage.iconString = "default.png"
    storage.drawableList = {}
    if itemRoot.config.builderConfig then
      local palette = itemRoot.config.builderConfig[1].palette
      if palette then
        paletteSwaps = sb_doPaletteSwaps(item.parameters.seed, palette)
      else
        paletteSwaps = ""
      end
      local newDrawables = {}
      for part,image in pairs(item.parameters.animationParts) do
        if itemRoot.config.builderConfig[1].animationParts[part].paletteSwap then
          newDrawables[part] = {position = {0,0}, image = image..paletteSwaps}
        else
          newDrawables[part] = {position = {0,0}, image = image}
        end
        if part == "shield" and itemRoot.config.tooltipKind == "sb_shield" then
          newDrawables[part]["image"] = newDrawables[part]["image"]..":nearidle"
        end
      end
      if itemRoot.config.builderConfig[1].gunParts then
        local imageOffset = {0,0}
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          local imageSize = root.imageSize(newDrawables[part].image)
          imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
          newDrawables[part].position = copy(imageOffset)
          imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
        end
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          newDrawables[part].position = vec2.add(newDrawables[part].position, {-imageOffset[1]/2,0})
        end
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    else
      local palette = itemRoot.config.palette
      if palette then
        paletteSwaps = sb_doPaletteSwaps(item.parameters.seed, palette)
      else
        paletteSwaps = ""
      end
      local newDrawables = {}
      for part,image in pairs(item.parameters.animationParts) do
        local newImage = image
        if string.sub(image, 1, 1) ~= "/" then
          newImage = itemRoot.directory..image
        end
        newDrawables[part] = {position = itemRoot.config.baseOffset or {0,0}, image = newImage}
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    end
  elseif (root.itemType(item.name) == "activeitem" and item.parameters.animationPartVariants) then
    storage.iconString = "default.png"
    storage.drawableList = {}
    if itemRoot.config.builderConfig then
      local palette = itemRoot.config.builderConfig[1].palette
      if palette then
        paletteSwaps = sb_doPaletteSwaps(item.parameters.seed, palette)
      else
        paletteSwaps = ""
      end
      local newDrawables = {}
      for part,variant in pairs(item.parameters.animationPartVariants) do
        local pvImage = util.absolutePath(itemRoot.directory, string.gsub(itemRoot.config.builderConfig[1].animationParts[part].path,'[{<(]variant[}>)]', variant))
        if itemRoot.config.builderConfig[1].animationParts[part].paletteSwap then
          newDrawables[part] = {position = {0,0}, image = pvImage..paletteSwaps}
        else
          newDrawables[part] = {position = {0,0}, image = pvImage}
        end
      end
      if itemRoot.config.builderConfig[1].gunParts then
        local imageOffset = {0,0}
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          local imageSize = root.imageSize(newDrawables[part].image)
          imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
          newDrawables[part].position = copy(imageOffset)
          imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
        end
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          newDrawables[part].position = vec2.add(newDrawables[part].position, {-imageOffset[1]/2,0})
        end
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
--      if item.parameters.directives and type(item.parameters.directives) == "string" then
--        sb_directives = item.parameters.directives
--      else
--        sb_directives = ""
--      end
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    else
      local palette = itemRoot.config.palette
      if palette then
        paletteSwaps = sb_doPaletteSwaps(item.parameters.seed, palette)
      else
        paletteSwaps = ""
      end
      local newDrawables = {}
      for part,variant in pairs(item.parameters.animationPartVariants) do
        local pvImage = util.absolutePath(itemRoot.directory, string.gsub(itemRoot.config.builderConfig[1].animationParts[part].path,'[{<(]variant[}>)]', variant))
        local newImage = pvImage
        if string.sub(pvImage, 1, 1) ~= "/" then
          newImage = itemRoot.directory..pvImage
        end
        newDrawables[part] = {position = {0,0}, image = newImage}
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    end
  elseif (root.itemType(item.name) == "activeitem" and itemRoot.config.inventoryIcon and peaslyDeepCompare(itemRoot.config, itemRootAgain.config)) then
    if type(itemRoot.config.inventoryIcon) == "string" then
      storage.iconString = "default.png"
      storage.drawableList = {}
      local drawPos = {0,0}
      local drawImage = itemRoot.config.inventoryIcon
      if string.sub(drawImage, 1, 1) ~= "/" then
        drawImage = itemRoot.directory..drawImage
      end
      table.insert(storage.drawableList, {position = drawPos, image = drawImage})
      storage.drawableList = shrinkWeapon(storage.drawableList)
    elseif type(itemRoot.config.inventoryIcon) == "table" then
      storage.iconString = "default.png"
      storage.drawableList = {}
      for i, drawable in pairs(itemRoot.config.inventoryIcon) do
        local drawPos = drawable.position or {0,0}
        local drawImage = drawable.image
        if string.sub(drawImage, 1, 1) ~= "/" then
          drawImage = itemRoot.directory..drawImage
        end
        table.insert(storage.drawableList, {position = drawPos, image = drawImage, scale = drawable.scale, background = drawable.background})
      end
      storage.drawableList = shrinkWeapon(storage.drawableList)
    end
  elseif (root.itemType(item.name) == "activeitem" and itemRoot.config.animationParts) then
    storage.iconString = "default.png"
    storage.drawableList = {}
    if itemRoot.config.builderConfig then
      local palette = itemRoot.config.builderConfig[1].palette
      if palette then
        paletteSwaps = sb_doPaletteSwaps(item.parameters.seed, palette)
      else
        paletteSwaps = ""
      end
      local newDrawables = {}
      for part,rawImage in pairs(itemRoot.config.animationParts) do
        image = rawImage
        if string.sub(image, 1, 1) ~= "/" then
          image = itemRoot.directory..image
        end
        if not rawImage or not string.find(rawImage, ".png")then
        elseif itemRoot.config.builderConfig[1].animationParts and itemRoot.config.builderConfig[1].animationParts[part].paletteSwap then
          newDrawables[part] = {position = {0,0}, image = image..paletteSwaps}
        else
          newDrawables[part] = {position = {0,0}, image = image}
        end
      end
      if itemRoot.config.builderConfig[1].gunParts then
        local imageOffset = {0,0}
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          if newDrawables[part] then
            local imageSize = root.imageSize(newDrawables[part].image)
            imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
            newDrawables[part].position = copy(imageOffset)
            imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
          end
        end
        for _,part in pairs(itemRoot.config.builderConfig[1].gunParts) do
          if newDrawables[part] then
            newDrawables[part].position = vec2.add(newDrawables[part].position, {-imageOffset[1]/2,0})
          end
        end
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    else
      local newDrawables = {}
      for part,rawImage in pairs(itemRoot.config.animationParts) do
        image = rawImage
        if string.sub(image, 1, 1) ~= "/" then
          image = itemRoot.directory..image
        end
        if not rawImage or not string.find(rawImage, ".png")then
        else
          newDrawables[part] = {position = itemRoot.config.baseOffset or {0,0}, image = image}
        end
      end
      newDrawables["muzzleFlash"] = nil
      newDrawables = shrinkWeapon(newDrawables)
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    end
  elseif type(item.parameters.inventoryIcon) == "table" then
    storage.iconString = "default.png"
    storage.drawableList = {}
    local newDrawables = shrinkWeapon(item.parameters.inventoryIcon)
    for i, drawable in pairs(newDrawables) do
      local drawPos = drawable.position or {0,0}
      table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
    end
  elseif type(itemRoot.config.inventoryIcon) == "table" then
    storage.iconString = "default.png"
    storage.drawableList = {}
    local newDrawables = shrinkWeapon(itemRoot.config.inventoryIcon)
    for i, drawable in pairs(newDrawables) do
      local drawPos = drawable.position or {0,0}
      table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
    end
  else
    if type(item.parameters.inventoryIcon) == "string" and self.shouldShrink then
      storage.iconString = item.parameters.inventoryIcon
    elseif not self.shouldShrink then
      storage.iconString = itemRoot.config.image or itemRoot.config.inventoryIcon or itemRoot.config.codexIcon or "/objects/generic/sapling/saplingicon.png"
    else
      storage.iconString = itemRoot.config.inventoryIcon or itemRoot.config.image or itemRoot.config.codexIcon or "/objects/generic/sapling/saplingicon.png"
    end
    if string.sub(storage.iconString, 1, 1) ~= "/" then
      storage.iconString = itemRoot.directory..storage.iconString
    end
    if itemRoot.config.colorOptions then
      storage.iconString = storage.iconString.."?replace"
      for c1, c2 in pairs(itemRoot.config.colorOptions[(item.parameters.colorIndex or 0) + 1] or {["fff"]="fff"}) do
        storage.iconString = storage.iconString..";"..c1.."="..c2
      end
      storage.iconString = storage.iconString
    end
    if string.find(storage.iconString, '[:][{<(]frame[}>)]') then
      storage.iconString = string.gsub(storage.iconString, '[:][{<(]frame[}>)]', ":0")
    end
    local iconSize = root.imageSize(storage.iconString)
    if iconSize[1] > 16 or iconSize[2] > 16 then
      local newDrawables = shrinkWeapon({{image = storage.iconString, position = {0,0}}})    
      storage.drawableList = {}
      for i, drawable in pairs(newDrawables) do
        local drawPos = drawable.position or {0,0}
        table.insert(storage.drawableList, {position = drawPos, image = drawable.image, scale = drawable.scale, background = drawable.background})
      end
    end
  end
  setDisplay()
end

function sb_doPaletteSwaps(seed, palette)
  palette = root.assetJson(util.absolutePath(itemRoot.directory, palette))
  local paletteSwaps = "?replace"
  for k, v in pairs(palette) do
    if type(v) ~= "table" then break end --since weaponcolors have a name string for some odd reason
    local selectedSwaps = randomFromList(palette[k], seed, "paletteSwaps-"..k)
    for k2, v2 in pairs(selectedSwaps) do
      paletteSwaps = string.format("%s;%s=%s",paletteSwaps,k2,v2)
    end
  end
  return paletteSwaps
end