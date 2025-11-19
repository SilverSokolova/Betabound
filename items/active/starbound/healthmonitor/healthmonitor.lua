function init()
  resources = config.getParameter("resources")

  if player.mode then
    resources["food"].visible = root.assetJson("/playermodes.config")[player.mode()].hunger
  else
    resources["food"].visible = true
  end
end

function update()
  --Breath is hidden when both immune and full, since oxygen replenishing items can work by providing temporary immunity
  resources["breath"].visible = not (status.statPositive("breathProtection") and status.resourcePercentage("breath") == 1)

  for k, _ in pairs(resources) do
    resources[k].currentValue = status.resource(k)
    resources[k].maxValue = status.resourceMax(k)
  end

  activeItem.setScriptedAnimationParameter("resources", resources)
end