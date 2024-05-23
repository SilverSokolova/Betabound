function init()
  colors = config.getParameter("colors")
  showHunger = animationConfig.animationParameter("showHunger")
end

function update(dt)
  localAnimator.clearDrawables()
  local currentResources, maxResources = animationConfig.animationParameter("currentResources"), animationConfig.animationParameter("maxResources")
  if not showHunger then
    currentResources[3] = nil
    maxResources[3] = nil
  end

  for i = 1, #currentResources do
    currentResources[i] = tostring(math.floor(currentResources[i]))
    maxResources[i] = tostring(math.floor(maxResources[i]))
  end

  --Casual just sets food to max, so check for that. Sometimes it drops down by one though
  if #currentResources >= 3 and ((currentResources[3] == tostring(tonumber(maxResources[3])-1)) or (currentResources[3] == maxResources[3])) then
    currentResources[3] = maxResources[3]
  end

  local position = activeItemAnimation.ownerPosition()
  local textOffset = 1
  for i = 1, #currentResources do
    textOffset = addText(currentResources[i], position, string.format("?replace;fff=%s", colors[currentResources[i] == maxResources[i] and 1 or 2][i]), textOffset)
    if i ~= #currentResources then
      textOffset = addText(",", position, nil, textOffset)
    end
  end
end