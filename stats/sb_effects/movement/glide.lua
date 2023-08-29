function init()
  p = {gravityMultiplier = config.getParameter("gravityModifier") * (mcontroller.baseParameters().gravityMultiplier or 1)}
end

function update(dt)
  if mcontroller.falling() then mcontroller.controlParameters(p) end
end