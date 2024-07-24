local originalInit = init or function() end
function init() originalInit()
  local originalObjectSmash = object.smash
  object.smash = function() originalObjectSmash(true) end
end