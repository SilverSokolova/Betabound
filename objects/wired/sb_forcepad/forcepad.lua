function init()
  local directions = {"left","right","top","bottom"}
  for i = 1, 4 do physics.setForceEnabled("jumpForce_"..directions[i], false) end
  updateActive()
end

function onInputNodeChange() updateActive() end
function onNodeConnectionChange() updateActive() end

function updateActive()
  local active = not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
  physics.setForceEnabled("jumpForce_"..config.getParameter("anchors")[1], active)
  animator.setAnimationState("padState", active and "on" or "off")
  animator.setParticleEmitterActive(config.getParameter("anchors")[1], active and "on" or "off")
end
