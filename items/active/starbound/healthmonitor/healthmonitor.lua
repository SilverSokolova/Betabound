function init()
  resources = config.getParameter("resources")
  local showHunger = true
  if player.mode then
    showHunger = root.assetJson("/playermodes.config")[player.mode()].hunger
  end
  activeItem.setScriptedAnimationParameter("showHunger", showHunger)
end

function update()
  local currentResources, maxResources = {}, {}
  for i = 1, #resources do
    local target = resources[i]
    currentResources[i] = status.resource(target)
    maxResources[i] = status.resourceMax(target)
  end
  activeItem.setScriptedAnimationParameter("currentResources", currentResources)
  activeItem.setScriptedAnimationParameter("maxResources", maxResources)
end