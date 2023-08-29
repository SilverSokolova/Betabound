local ini = init or function() end
local onInteractio = onInteraction or function() end

function init() ini()
  script.setUpdateDelta(0)
  object.setInteractive(true)
  smas = object.smash
  toAbsolutePositio = object.toAbsolutePosition
  object.smash = function() smas(true) end
  object.toAbsolutePosition = function(z) return toAbsolutePositio{z[1],z[2]+1} end
  world.isVisibleToPlayer = function() return false end
end

function onInteraction(args) onInteractio(args) update() end