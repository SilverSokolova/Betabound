local originalInit = init or function() end
local originalUpdate = update or function() end

function init() originalInit()
  sb_entityId = entity.id()
  effect.setParentDirectives("fade=0072ff=0.1")
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.1}
  })
end

function update(dt) originalUpdate(dt)
  if math.random(25) == 1 then
    world.spawnProjectile("sb_wet", mcontroller.position(), sb_entityId)
  end
  mcontroller.controlModifiers({
      speedModifier = 0.9,
      airJumpModifier = 0.9
    })
end