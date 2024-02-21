require "/scripts/rect.lua"
require "/scripts/vec2.lua"

function init()
  maxLadderCount = config.getParameter("ladderCount")
  ladderName, lastLadderName = "", ""
  placementRange = config.getParameter("placementRange")
  placementBounds = config.getParameter("placementBounds")
  previewOffset = config.getParameter("previewOffset", {1, 0})
  placementPreviewImage = config.getParameter("placementPreviewImage")
  activeItem.setScriptedAnimationParameter("previewImage", placementPreviewImage)
  activeItem.setScriptedAnimationParameter("ladderCount", maxLadderCount)
end

function activate(fireMode)
  local placePos = activeItem.ownerAimPosition()
  if placementValid(placePos) then
    if world.placeObject(ladder.name, placePos, 1, {length=ladderCount-1}) and not player.isAdmin() then
      player.consumeItem({name=ladder.name,count=ladderCount},true)
    end
  end
end

function update(dt, fireMode, shiftHeld)
  ladder = player.getItemWithParameter("animation","ladder.animation")
  ladderCount = ladder and math.min(player.hasCountOfItem(ladder.name),maxLadderCount) or maxLadderCount
  activeItem.setScriptedAnimationParameter("ladderCount", ladderCount)
  if ladder then ladderName = ladder.name end
  if lastLadderName ~= ladderName then
    placementPreviewImage = root.itemConfig(ladderName); local directory = placementPreviewImage.directory
    placementPreviewImage = directory..placementPreviewImage.config.animationParts.ladder
    activeItem.setScriptedAnimationParameter("previewImage", placementPreviewImage)
  end
  local placePos = activeItem.ownerAimPosition()
  activeItem.setScriptedAnimationParameter("previewPosition", vec2.add(placePos, previewOffset))
  activeItem.setScriptedAnimationParameter("previewValid", placementValid(placePos))

  local _, aimDirection = activeItem.aimAngleAndDirection(0, placePos)
  activeItem.setFacingDirection(aimDirection)
  lastLadderName = ladderName
end

function placementValid(pos)
  if world.isTileProtected(pos) or
    world.magnitude(mcontroller.position(), pos) > placementRange or
    world.lineCollision(mcontroller.position(), pos, {"Null", "Block", "Dynamic", "Slippery"}) --TODO: actually check for blocks at the CURSOR
  then return false end

--for i = 1, #placementBounds do placementBounds[i]=floor(placementBounds[i]) end
  local placementRect = rect.translate(placementBounds, pos)
  return
    ladder
    and not world.objectAt(pos)
    and not world.rectCollision(placementRect, {"Null", "Block", "Dynamic", "Slippery"})
    and not world.tileIsOccupied(pos,true)
    and not world.tileIsOccupied({pos[1]+1,pos[2]},true)
    and world.tileIsOccupied({pos[1],pos[2]-1},true)
    and world.tileIsOccupied({pos[1]+1,pos[2]-1},true)
end