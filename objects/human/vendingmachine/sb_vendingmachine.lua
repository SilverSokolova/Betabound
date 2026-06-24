local originalUpdate = update or function() end

function update(...); originalUpdate(...)
  storage = {}
  object.setConfigParameter("treasurePools", {"empty"})
  object.setInteractive(animator.animationState("light") == "on" or false)
end