local ini = init or function() end
function init() ini()
  local a = storage.sb_frame or math.random(4)
  storage.sb_frame = a
  animator.setAnimationState("sb_flower",a)
end