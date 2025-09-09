local originalSweep = sweep or function() end
local originalActivate = activate or function() end
local originalUpdate = update or function() end

function activate(fireMode, shiftHeld)
  sb_fireMode = fireMode
  originalActivate(fireMode, shiftHeld)
end

function update(dt, fireMode, shiftHeld)
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)
  originalUpdate(dt, fireMode, shiftHeld)
end

function sweep() originalSweep()
  if not player then return end
  local pos = mcontroller.position()
  pos = {math.floor(pos[1]), math.floor(pos[2])}
  brushArea = { --3 tiles horizontally at the player's feet
    {pos[1] - 1, pos[2] - 3},
    {pos[1], pos[2] - 3},
    {pos[1] + 1, pos[2] - 3}
  }
  world.damageTiles(brushArea, sb_fireMode == "primary" and "foreground" or "background", pos, "tilling", 0.001, 99) --No owner ID because NPC's will accuse of theft
end