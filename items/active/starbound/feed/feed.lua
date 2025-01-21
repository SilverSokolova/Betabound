require "/scripts/activeitem/sb_swing.lua"
local updat = update
function init() swingInit()
  feed = config.getParameter("feedType", "")
  range = config.getParameter("interactRadius", root.assetJson("/player.config:interactRadius"))
end

function swingAction()
  local targets = world.monsterQuery(activeItem.ownerAimPosition(), 0)
  for j = 1, #targets do
    if checkTargetRadius(targets[j]) and world.entityTypeName(targets[j]):find("fluffalobaby") and not promised then
      i = world.sendEntityMessage(targets[j], "sb_feedFluffalo", feed)
      promised = true
      break
    end
  end
end

function update(dt, fireMode, shiftHeld) updat(dt, fireMode, shiftHeld)
  if promised then
    if i:finished() and i:result() == true then
      item.consume(1)
      animator.playSound("eat")
      promised = nil
      target = nil
    end
  end
end

function checkTargetRadius(target)
  if target and world.entityExists(target) then
    local pos = mcontroller.position()
    local targetPosition = world.entityPosition(target)
    return player.isAdmin() or (world.magnitude(pos, targetPosition) <= range and not world.lineCollision(pos, targetPosition))
  end
end