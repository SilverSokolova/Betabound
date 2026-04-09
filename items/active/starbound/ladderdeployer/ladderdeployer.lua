require "/scripts/rect.lua"
require "/scripts/vec2.lua"

function init()
  --Stuff related to how many ladders you're placing
  currentLadderCount = config.getParameter("ladderCount")
  maxLadderCount = config.getParameter("maxLadderCount")
  ladderHeightChangeCooldown = config.getParameter("ladderHeightChangeCooldown", 0.1)
  ladderHeightChangeCooldownTimer = 0

  --other
  ladderName, lastLadderName = "", ""
  placementRange = config.getParameter("placementRange")
  placementBounds = config.getParameter("placementBounds")
  previewOffset = config.getParameter("previewOffset", {1, 0})
  placementPreviewImage = config.getParameter("placementPreviewImage")
  activeItem.setScriptedAnimationParameter("previewImage", placementPreviewImage)
  activeItem.setScriptedAnimationParameter("ladderCount", currentLadderCount)
end

function activate(fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  if placementValid(placePos) then
    if world.placeObject(ladder.name, placePos, 1, {length = ladderCount - 1}) and not player.isAdmin() then
      player.consumeItem({name = ladder.name, count = ladderCount}, true)
    end
  end
end

function update(dt, fireMode, shiftHeld, args)
  --height control
  --BUG: You can increase the ladder count by 1 when you're already at max. It doesn't show if past the cap
  if ladderHeightChangeCooldownTimer == 0 then
    if shiftHeld then
      if args.up or args.down then
        local newLadderCount = math.min(math.max(2, ladderCount + (args.up and 1 or args.down and -1)), maxLadderCount)
        if newLadderCount ~= currentLadderCount then
          activeItem.setInstanceValue("ladderCount", newLadderCount)
          currentLadderCount = newLadderCount
          animator.playSound("ladderHeightChange")
          activeItem.setScriptedAnimationParameter("ladderCount", currentLadderCount)
          ladderHeightChangeCooldownTimer = ladderHeightChangeCooldown

          if player.say then
            player.say(string.format("^gray;(%s)", newLadderCount))
          end
        end
      end
    end
  else
    ladderHeightChangeCooldownTimer = math.max(0, ladderHeightChangeCooldownTimer - dt)
  end

  --preview and ladder type
  ladder = player.getItemWithParameter("animation", "ladder.animation") --TODO: maybe prefix animation?

  local admin = player.isAdmin()
  if not ladder and admin then
    ladder = {name = config.getParameter("adminLadder", "sb_medievalladder")}
  end

  ladderCount = ladder and math.min(admin and currentLadderCount or player.hasCountOfItem(ladder.name), currentLadderCount) or currentLadderCount
  activeItem.setScriptedAnimationParameter("ladderCount", ladderCount)

  if ladder then ladderName = ladder.name end

  if lastLadderName ~= ladderName then
    placementPreviewImage = root.itemConfig(ladderName); local directory = placementPreviewImage.directory
    placementPreviewImage = directory .. placementPreviewImage.config.animationParts.ladder
    activeItem.setScriptedAnimationParameter("previewImage", placementPreviewImage)
  end

  local placePos = activeItem.ownerAimPosition()
  activeItem.setScriptedAnimationParameter("previewPosition", vec2.add(placePos, previewOffset))
  activeItem.setScriptedAnimationParameter("previewValid", placementValid(placePos))

  local _, aimDirection = activeItem.aimAngleAndDirection(0, placePos); activeItem.setFacingDirection(aimDirection)

  lastLadderName = ladderName
end

function placementValid(pos)
  if world.isTileProtected(pos) or
    world.magnitude(mcontroller.position(), pos) > placementRange or
    world.lineCollision(mcontroller.position(), pos, {"Null", "Block", "Dynamic", "Slippery"}) --TODO:
  then
    return false
  end

--for i = 1, #placementBounds do placementBounds[i]=floor(placementBounds[i]) end
  local placementRect = rect.translate(placementBounds, pos)
  return
    ladder
    and not world.objectAt(pos) --TODO: this line not needed?
    and not world.rectCollision(placementRect, {"Null", "Block", "Dynamic", "Slippery"})
    --wide enough?
    and not world.tileIsOccupied(pos, true)
    and not world.tileIsOccupied({pos[1] + 1, pos[2]}, true)
    --has support under?
    and world.rectCollision({pos[1], pos[2] - 1, pos[1] + 1, pos[2] - 1}, {"Null", "Block", "Dynamic", "Slippery", "Platform"})
--  and world.tileIsOccupied({pos[1], pos[2] - 1}, true)
--  and world.tileIsOccupied({pos[1] + 1, pos[2] - 1}, true)
end