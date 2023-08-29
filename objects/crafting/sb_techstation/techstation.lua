function onInputNodeChange() processWireInput() end
function onNodeConnectionChange() processWireInput() end
function init()
  if config.getParameter("reskin",false) then
    local s = config.getParameter("inventoryIcon")
    if not s then return end
    local i = string.find(s,".png:")
    object.setProcessingDirectives(s:sub(i*2))
  end
  active = config.getParameter("active",true)
  object.setConfigParameter("active",active)
  object.setInteractive(active)
  local active = active and "on" or "off"
    animator.setAnimationState("lit0", active)
    animator.setAnimationState("station0", active)
    animator.setAnimationState("station", active)
    animator.setAnimationState("lit", active)
end

function processWireInput()
  if not object.isInputNodeConnected(0) then else
  object.setConfigParameter("active",object.getInputNodeLevel(0))
  end init()
end

function onInteraction(args)
    return {config.getParameter("interactAction"),config.getParameter("interactData")}
end