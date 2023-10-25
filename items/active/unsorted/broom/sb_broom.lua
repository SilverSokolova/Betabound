local sb_sweep = sweep or function() end
local sb_activate = activate or function() end
local sb_update = update or function() end

function activate(fireMode, shiftHeld)
  sb_fireMode = fireMode
  sb_activate(fireMode, shiftHeld)
end

function update(dt, fireMode, shiftHeld)
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)
  sb_update(dt, fireMode, shiftHeld)
end

function sweep() sb_sweep()
  if not player then return end
  local pos = mcontroller.position()
  pos = {math.floor(pos[1]), math.floor(pos[2])}
  brushArea = {
    {pos[1], pos[2]-3},
    {pos[1]-1, pos[2]-3},
    {pos[1]+1, pos[2]-3}
  }
  world.damageTiles(brushArea, sb_fireMode == "primary" and "foreground" or "background", pos, "tilling", 0.001, 99, activeItem.ownerEntityId())
end