require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/activeitem/stances.lua"
require "/items/active/unsorted/stunmine/stunmine.lua"

function init()
  initStances()

  self.icons = config.getParameter("icons")

  if storage.triggered then
    item.consume(1)
  elseif storage.launched then
    activeItem.setInventoryIcon(self.icons.trigger)
    setStance("readyTrigger")
  else
    activeItem.setInventoryIcon(self.icons.full)
    setStance("idle")
  end
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

--[[  if storage.projectileId and world.entityType(storage.projectileId) ~= "projectile" then
    item.consume(1)
    return
  end]]--

  if fireMode == "primary" then
    if self.stanceName == "idle" then
      setStance("windup")
    elseif self.stanceName == "readyTrigger" then
      trigger()
    end
  end

  updateAim()
end

function triggerComplete()
  item.consume(1)
  activeItem.setInventoryIcon(self.icons.full)
end
