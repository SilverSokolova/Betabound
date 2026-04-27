local originalInit = init or function() end
local originalDoMultiJump = doMultiJump or function() end

function init(); originalInit()
  sb_energyUsage = config.getParameter("sb_energyUsage")
end

function doMultiJump(...)
  if status.overConsumeResource("energy", sb_energyUsage) then
    originalDoMultiJump(...)
  end
end
