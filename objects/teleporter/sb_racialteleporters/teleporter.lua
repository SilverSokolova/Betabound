function onInputNodeChange() processWireInput() end
function onNodeConnectionChange() processWireInput() end

function init()
  linkedTeleporter = config.getParameter("linkedTeleporter")
  active = config.getParameter("active", linkedTeleporter or false)
  object.setConfigParameter("active", active)
  object.setInteractive(active)
  local active = active and "on" or "off"
    animator.setAnimationState("light", active)
    animator.setAnimationState("teleporter", active)
    animator.setAnimationState("lit", active)
end

function processWireInput()
  linkedTeleporter = false
  if object.isInputNodeConnected(0) then
    local outputs = object.getOutputNodeIds(0)
    if outputs then
      for k, _ in pairs(outputs) do
        if k and world.getObjectParameter(k, "sb_wireableTeleporter") then
          linkedTeleporter = world.entityPosition(k)
          break
        end
      end
    end
  end

  object.setConfigParameter("linkedTeleporter", linkedTeleporter or false)
  object.setConfigParameter("active", linkedTeleporter)

  init()
end

function onInteraction(args)
  if linkedTeleporter then
    return {"message", {messageType = "sb_wiredteleporter", messageArgs = {linkedTeleporter[1], linkedTeleporter[2]}}}
  end
end