require "/scripts/vec2.lua"

function init()
  pos = entity.position()
  ladderName = object.name()
  length = config.getParameter("length", 0)
  spaces = object.spaces()

  paintable = config.getParameter("paintable", false)
  colorLookup = {[0] = "default", "red", "blue", "green", "yellow", "orange", "magenta", "black", "white"}

  if paintable then
    local tiles = {}
    for _, tile in pairs(spaces) do table.insert(tiles, {tile, "sb_ladder_metamaterial"}) end
    object.setMaterialSpaces(tiles)

    paintData = config.getParameter("sb_paintData", {})
    paintableParts = {}
    for k, v in pairs(config.getParameter("paintableParts", {})) do
      local offsetKey = v[1] .. "|" .. v[2]
      paintableParts[offsetKey] = k
      animator.setPartTag(k, "paint", colorLookup[paintData[offsetKey]])
    end
  end

  -- To allow compatibility with older ladder format that only used 1 animator part
  local animationParts = config.getParameter("animationParts", {})
  if animationParts.ladder then
    animator.setPartTag("ladderL", "partImage", animationParts.ladder)
    animator.setPartTag("ladderR", "partImage", animationParts.ladder)
  end
end

function update(dt)
  if not initialized then postInit() end -- Due to Reasons™ some stuff needs to wait until first update to initialize properly

  local up, down = world.objectAt({pos[1], pos[2] + 1}), world.objectAt({pos[1], pos[2] - 1})
  up = up and world.entityName(up) == ladderName
  down = down and world.entityName(down) == ladderName

  if up or down then
    animator.setAnimationState("ladder", (up and down and "middle") or (up and "bottom") or "top")
  end

  if paintable then
    for _, tile in pairs(spaces) do
      local color = world.materialColor(object.toAbsolutePosition(tile), "foreground")
      if paintData[tile[1] .. "|" .. tile[2]] ~= color then setPaintColor(tile, color) end
    end
  end
end

function postInit()
  if length and length > 0 then runLength() end

  -- `object.setMaterialSpaces` uses the color of whatever block was there last, so we have to reset it manually
  for _, tile in pairs(spaces) do
    world.setMaterialColor(object.toAbsolutePosition(tile), "foreground", paintData[tile[1] .. "|" .. tile[2]] or 0)
  end

  initialized = true
end

function setPaintColor(offset, color)
  local offsetKey = offset[1] .. "|" .. offset[2]
  paintData[offsetKey] = color
  object.setConfigParameter("sb_paintData", paintData)
  animator.setPartTag(paintableParts[offsetKey], "paint", colorLookup[color]) -- I would call the tag <color> but the game overrides that
end

function runLength()
  if not world.placeObject(ladderName, {pos[1], pos[2] + 1}, object.direction(), {length = length - 1}) then
    world.spawnItem(ladderName, pos, length)
  end

  object.setConfigParameter("length", nil)
  length = nil
end