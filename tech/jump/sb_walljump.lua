local originalInit = init or function() end
local originalGrabWall = grabWall or function(...) end

function init()
  originalInit()
  sb_wallGrabRefreshesJump = config.getParameter("sb_wallGrabRefreshesJump")
end

function grabWall(...)
  if sb_wallGrabRefreshesJump then
    refreshJumps()
  end

  originalGrabWall(...)
end