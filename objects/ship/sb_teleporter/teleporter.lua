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
  if not object.isInputNodeConnected(0) then else
  object.setConfigParameter("active",object.getInputNodeLevel(0))
  end init()
end

function onInteraction(args)
    local interactData = root.assetJson(config.getParameter("interactData"))
    interactData.uniqueId = entity.uniqueId()
    return {config.getParameter("interactAction"),interactData}
end