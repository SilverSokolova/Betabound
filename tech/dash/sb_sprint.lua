local ini = init or function() end

function init()
  status.sb_setPersistentEffects = status.setPersistentEffects
  status.setPersistentEffects = function(effectCategory, effects)
    if effectCategory == "movementAbility" then return end
    return status.sb_setPersistentEffects(effectCategory, effects)
  end
  ini()
end