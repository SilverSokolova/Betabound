function init()
  pos = entity.position()
  ladderName = object.name()
  length = config.getParameter("length", 0)
end

function update(dt)
  --TODO: Does this HAVE to be in update? init might work better
  if length and length > 0 then
    runLength()
  end

  local up, down = world.objectAt({pos[1], pos[2] + 1}), world.objectAt({pos[1], pos[2] - 1})

  up = up and world.entityName(up) or false
  down = down and world.entityName(down) or false

  if up or down then
    animator.setAnimationState("ladder", (up and down and "middle") or (up and "bottom") or "top")
  end
end

function runLength()
  if not world.placeObject(ladderName, {pos[1], pos[2] + 1}, object.direction(), {length = length - 1}) then
    world.spawnItem(ladderName, pos, length)
  end

  object.setConfigParameter("length", nil)
  length = nil
end