require "/scripts/sb_uimessage.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit()
  sb_cursor("power")
end

function swingAction()
  local pos = world.entityPosition(activeItem.ownerEntityId())
  if world.isTileProtected(pos) then
    sb_uiMessage("areaProtected")
    animator.playSound("error")
    return
  end
  if world.placeObject("sb_portable3dprinterobject", pos) then
    animator.playSound("success")
  else
    animator.playSound("error")
    sb_uiMessage("noSpaceForObject")
  end
end