local originalInit = init or function() end
function init() originalInit()
  local frame = storage.sb_frame or math.random(4)
  storage.sb_frame = frame
  animator.setAnimationState("sb_flower", frame)
end