--TODO: Why not move this to the `/scripts/objects/` folder?
require "/scripts/sb_assetmissing.lua"
function init()
  local modded = false
  if sb_itemExists("enhancedstoragematerial") then
    modded = true
    init = nil
    require("/scripts/enhancedstorage.lua")
    object.setConfigParameter("smashOnBreak", true)
    object.setConfigParameter("scripts", {"/scripts/enhancedstorage.lua"})
    init()
    return --Why return here but not for IC? They both overwrite and run init
  elseif root.assetJson("/interface/chests/chest9.config").gui.icRenameButton then
    modded = true
    init = nil
    require("/scripts/v6/improvedcontainer.lua")
    object.setConfigParameter("smashOnBreak", true)
    object.setConfigParameter("uiConfig", "/interface/chests/chest<slots>.config")
    init()
  end
  object.setConfigParameter("smashOnBreak", modded)
end