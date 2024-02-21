function init()
  animator.setAnimationState("teleport", "beamOut")
  effect.setParentDirectives("?multiply=fff0")
  animator.setGlobalTag("effectDirectives", status.statusProperty("effectDirectives", ""))

  local speciesTags = config.getParameter("speciesTags")
  if status.statusProperty("species") then
    animator.setGlobalTag("species", speciesTags[status.statusProperty("species")] or "")
  end

  triggerTimer = config.getParameter("triggerTime")
end

function update(dt)
  mcontroller.controlModifiers({movementSuppressed = true})
  mcontroller.setVelocity({0, 0})
  if triggerTimer > 0 then
    triggerTimer = triggerTimer - dt
    if triggerTimer <= 0 then
      trigger()
    end
  end
end

function trigger()
  mcontroller.setPosition({0, -99})
  status.setResource("health", 0)
end
