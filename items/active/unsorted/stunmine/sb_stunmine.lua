local originalInit = init or function() end
local originalUpdate = update or function() end

function init()
  item.sb_consume = item.consume
  item.consume = function(count)
    storage.projectileId = nil
    storage.launched = nil
    storage.triggered = nil
    activeItem.setInventoryIcon(self.icons.full)
    setStance("idle")
    return item.sb_consume(count)
  end
  originalInit()
end

function update(...)
  if storage.projectileId and world.entityType(storage.projectileId) ~= "projectile" then
    item.consume(0)
    return
  end
  originalUpdate(...)
end