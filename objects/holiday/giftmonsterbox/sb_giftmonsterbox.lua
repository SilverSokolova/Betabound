local ini = init or function() end
function init() ini()
  local smas = object.smash
  object.smash = function() smas(true) end
end