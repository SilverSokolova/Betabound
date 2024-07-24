local originalInit = init or function() end

function init()
  activeItem.setScriptedAnimationParameter("hand", activeItem.hand())
  originalInit()
end