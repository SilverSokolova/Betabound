local ini = init or function() end
function init() ini()
  local currentVersion = 29
  if player.introComplete() then
    if status.statusProperty("xrc_0018z") == nil then status.setStatusProperty("xrc_0018z",0) end
    local yv = status.statusProperty("xrc_0018z")
    if yv < currentVersion then
      require("/xrc/deployment/versioning/0018z_2.lua")
      status.setStatusProperty("xrc_0018z",currentVersion)
      xrc0018z_2(currentVersion,yv)
    end
  end
end