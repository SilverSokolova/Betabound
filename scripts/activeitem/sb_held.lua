local ini = init or function() end
local updat = update or function() end

function init()
  ini()
  activeItem.setArmAngle(root.assetJson("/betabound.config:heldItemArmAngle"))
end

function update(...)
  updat(...)
  local _, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)
end