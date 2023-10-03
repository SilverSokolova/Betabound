function init()
  feed = config.getParameter("feedType","")
  range = config.getParameter("interactRadius", root.assetJson("/player.config:interactRadius"))
  promised = false
end

function activate()
  local target = world.monsterQuery(activeItem.ownerAimPosition(), 0)[1]
  if checkTargetRadius(target) then
    i = world.sendEntityMessage(target,"sb_feedFluffalo",feed)
    promised = true
  end
end

function update() if promised then if i:finished() and i:result() == true then item.consume(1) promised = false end end end

function checkTargetRadius(target)
  if target and world.entityExists(target) then
    local pos = mcontroller.position()
    local targetPosition = world.entityPosition(target)
    return (world.magnitude(pos, targetPosition) <= range and not world.lineCollision(pos, targetPosition))
  end
end