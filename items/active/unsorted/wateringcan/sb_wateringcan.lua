local originalInit = init or function() end

function init()
  originalInit()
  mcontroller.sb_controlModifiers = mcontroller.controlModifiers
  mcontroller.controlModifiers = function(modifiers)
    if modifiers then
      for k, v in pairs(modifiers) do
        if k == "movementSuppressed" and v == true then
          modifiers.movementSuppressed = false
          modifiers.runningSuppressed = true
          break
        end
      end
    end
    return mcontroller.sb_controlModifiers(modifiers)
  end
end