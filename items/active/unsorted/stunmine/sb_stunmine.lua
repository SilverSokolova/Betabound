local ini = init or function() end

function init()
  item.sb_consume = item.consume
  item.consume = function(count)
    storage.projectileId = false
    storage.launched = false
    storage.triggered = false
    activeItem.setInventoryIcon(self.icons.full)
    setStance("idle")
    return item.sb_consume(count)
  end
  ini()
end