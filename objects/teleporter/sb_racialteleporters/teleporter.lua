function onInputNodeChange() processWireInput() end
function onNodeConnectionChange() processWireInput() end
function init()
  active = config.getParameter("active",true)
  object.setConfigParameter("active",active)
  object.setInteractive(active)
  local active = active and "on" or "off"
    animator.setAnimationState("light", active)
    animator.setAnimationState("teleporter", active)
    animator.setAnimationState("lit", active)
end

function processWireInput()
  if object.isInputNodeConnected(0) then 
    object.setConfigParameter("active", object.getInputNodeLevel(0))
  end
  init()
end

function onInteraction(args)
  return {config.getParameter("interactAction"), config.getParameter("interactData")}
end