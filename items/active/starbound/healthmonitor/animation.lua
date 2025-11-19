function init()
  lastHunger = -1
  resourceOrder = config.getParameter("resourceOrder")
--Commented out because having a resource with the same order would overwrite it, and changing the index if it overlaps would result in an inconsistent order( wasnt it that they were in the wrong order, not an inconsistent one?)
--for k, v in pairs(config.getParameter("resources")) do
--  resourceOrder[v.order] = k
--end
end

function update(dt)
  localAnimator.clearDrawables()
  local resources = animationConfig.animationParameter("resources")
  local position = activeItemAnimation.ownerPosition()
  local textOffset = 1

  for i = 1, #resourceOrder do
    local v = resources[resourceOrder[i]]
    v.currentValue = math.ceil(v.currentValue)
    if v and v.currentValue and (v.visible ~= false) then
      if i ~= 1 then
        textOffset = addText(",", position, nil, textOffset)
      end

      textOffset = addText(tostring(v.currentValue), position, string.format("?replace;fff=%s", v.colors[v.currentValue >= v.maxValue and 1 or 2]), textOffset)
    end
  end
end