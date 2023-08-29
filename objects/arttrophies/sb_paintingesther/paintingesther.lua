function init()
  updateActive()
  canBlink = true --not object.getInputNodeLevel(0) or true
  taunts = config.getParameter("chatOptions",{""})
end

function onInputNodeChange() updateActive() end
function onNodeConnectionChange() updateActive() end

function updateActive()
  local active = object.getInputNodeLevel(0)
  animator.setAnimationState("painting", active and "on" or "off")
  canBlink = not active
--  script.setUpdateDelta(active and 0 or 60)
end

function update(dt)
  if not canBlink then object.say(taunts[math.random(#taunts)]) end
  if canBlink and (math.random(666) > 66) and (math.random(666) < 66) then
    animator.setAnimationState("painting","blink")
  end
end