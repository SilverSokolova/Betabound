function onInputNodeChange() processWireInput() end
function onNodeConnectionChange() processWireInput() end
function init()
	object.setInteractive(true)
	storage.color = storage.color or 1
	colors = config.getParameter("colors")
	toggle()
end

function onInteraction()
        storage.color = storage.color + 1
        if storage.color > #colors then storage.color = 1 end
	animator.playSound("interact")
	toggle()
end

function toggle()
	animator.setAnimationState("af",storage.color)
	animator.setAnimationState("lit",storage.color)
	animator.setLightColor("light",colors[storage.color])
end

function processWireInput()
  if object.getInputNodeLevel(0) then onInteraction() end
end