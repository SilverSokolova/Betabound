function init()
  movementParams = mcontroller.baseParameters()
  newGravityMultiplier = config.getParameter("gravityModifier") * (movementParams.gravityMultiplier or 1)
end

function update(dt)
  mcontroller.controlParameters({gravityMultiplier = newGravityMultiplier})
end