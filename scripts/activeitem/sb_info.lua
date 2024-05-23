local ini = init or function() end

function init()
  activeItem.setScriptedAnimationParameter("hand", activeItem.hand())
  ini()
end