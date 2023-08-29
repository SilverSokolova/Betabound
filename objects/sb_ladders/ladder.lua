function init()
  p = entity.position()
  n = object.name()
  length = config.getParameter("length")
end

function update(dt)
  if length and length > 0 then runLength() end
  local up, down = world.objectAt({p[1],p[2]+1}), world.objectAt({p[1],p[2]-1})
  up = up and world.entityName(up) or false
  down = down and world.entityName(down) or false
  if up and down then animator.setAnimationState("ladder","middle") return end
  if up then animator.setAnimationState("ladder","bottom") return end
  if down then animator.setAnimationState("ladder","top") return end
end

function runLength()
  if not world.placeObject(n,{p[1],p[2]+1},object.direction(),{length=length-1}) then
    world.spawnItem(n,p,length)
  end
  object.setConfigParameter("length",nil)
  length = nil
end