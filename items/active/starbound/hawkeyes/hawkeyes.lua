function init()
  id = nil
  r = config.getParameter("range")
end

function uninit()
  activeItem.setCameraFocusEntity()
  if id then world.sendEntityMessage(id,"kill") end
end

function activate()
  if not id then
    id = world.spawnProjectile("sb_hawkeyes",entity.position(),entity.id(),{0,0},false,{processing="?multiply=0000"})
    activeItem.setCameraFocusEntity(id)
  else
    world.sendEntityMessage(id,"kill")
    id = nil
  end
end

function update(dt)
  activeItem.setCursor(string.format("/cursors/charge%s.cursor",id and "invalid" or "ready"))
  if id and world.entityExists(id) then
    local pos = withinBounds(activeItem.ownerAimPosition())
    world.sendEntityMessage(id, "setTargetPosition", pos)
    lastPos = pos
  end
end

function withinBounds(pos)
  local playerPos = entity.position()
  local newPos = {}
  lastPos = lastPos or pos
  for i = 1, 2 do
    local testedPos = pos[i]
    if testedPos < playerPos[i] - r then
      pos[i] = lastPos[i]
    elseif testedPos > playerPos[i] + r then
      pos[i] = lastPos[i]
    end
  end
  return pos
end