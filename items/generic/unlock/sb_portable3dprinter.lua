require "/scripts/sb_uimessage.lua"
require "/scripts/activeitem/sb_cursors.lua"
function init() sb_cursor("power") activeItem.setHoldingItem(false) end
function activate() if world.placeObject("sb_portable3dprinterobject",world.entityPosition(activeItem.ownerEntityId())) == false then
animator.playSound("error") sb_uiMessage(4) else animator.playSound("success") end end