function init()
  activationTime = config.getParameter("activationTime") or 600

  if storage.active == nil then
    toggle(true)
  else
    object.setSoundEffectEnabled(storage.active)
  end

  animator.setAnimationState("podState", storage.active and "active" or "expire")
end

function onInteraction(args)
  if storage.active then
    toggle(false)
    for i = 1, 3 do
      animator.playSound("sb_use"..i)
    end
    local statusOptions = config.getParameter("sb_statusOptions")
    world.sendEntityMessage(args.sourceId, "sb_randomfountain", statusOptions[math.random(#statusOptions)])
  end
end

function update(dt)
  if isTimeToActivate() then
    toggle(true)
  end
end

function isTimeToActivate()
  return storage.lastActive and world.time() - storage.lastActive > activationTime
end

function toggle(state)
  animator.setAnimationState("podState", state and "active" or "expire")
  storage.active = state
  object.setInteractive(state)
  object.setSoundEffectEnabled(state)

  if not state then
    storage.lastActive = world.time()
    object.setConfigParameter("smashOnBreak", true)
  else
    object.setConfigParameter("smashOnBreak", false)
  end
end