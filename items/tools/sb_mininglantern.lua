function init()
  animator.setLightColor("lantern", config.getParameter("lightColor"))
  active = true
  --somehow it preserves its state when you unequip it (TODO: USE STORAGE TO PREVENT THIS)
  animator.setLightActive("lantern", true)
  animator.setAnimationState("light", "on")
end

function update()
  local _, facing = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(facing)
end

function activate()
  active = not active
  local state = active and "on" or "off"
  animator.setLightActive("lantern", active)
  animator.setAnimationState("light", state)
  animator.playSound(state)
end