function init()
  direction = object.direction() < 0 and "right" or "left"
  animator.setAnimationState("shop", direction)
  employee = config.getParameter("animationParts.employee", "human"):gsub("%.png.*$", "")
  deathDirection = config.getParameter("smashAnimationOffset", {9, 5})
end

function die()
  local position = object.position()
  position[1] = position[1] + (deathDirection[direction == "right" and 1 or 2])
  position[2] = position[2] + 2.5
  world.spawnNpc(position, employee, "sb_beamoutanddie", 0)
end