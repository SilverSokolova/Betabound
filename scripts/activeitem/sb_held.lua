local originalInit = init or function() end
local originalUpdate = update or function() end

function init()
  originalInit()
  activeItem.setArmAngle(config.getParameter("heldItemArmAngle", root.assetJson("/betabound.config:heldItemArmAngle")))
end

function update(...)
  originalUpdate(...)
  local _, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)
end