function init()
  activeItem.setHoldingItem(false)
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
  if world.magnitude(entity.position(),activeItem.ownerAimPosition()) < r then
    activeItem.setCursor(string.format("/cursors/charge%s.cursor",id and "invalid" or "ready"))
    if id and world.entityExists(id) then
     world.sendEntityMessage(id,"updateProjectile",activeItem.ownerAimPosition())
    end
  else
    activeItem.setCursor("/cursors/chargeidle.cursor")
  end
end