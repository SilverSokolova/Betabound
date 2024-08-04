local originalInit = init or function() end

function init()
  originalInit()
  mcontroller.setRotation(45)
end