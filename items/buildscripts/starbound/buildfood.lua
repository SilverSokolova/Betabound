function build(directory, config, parameters)
  config.effects = parameters.effects or config.effects --fix for IFD only checking config for status effects
  require("/items/buildscripts/buildfood.lua")
  config, parameters = build(directory, config, parameters)
  local foodTooltip = root.assetJson("/interface/tooltips/food.tooltip")
  local fields = config.tooltipFields or {}
  if foodTooltip.effectLabel then --check for IFD
    config.tooltipKind = "sb_food"
  end
  if not (not not foodTooltip.foodAmountLabel or not not foodTooltip.foodValueLabel) then --check for other food label mods
    fields.foodValueLabel = ""
    foodTooltip.foodAmountLabel = ""
  else
    local foodValue = parameters.foodValue or config.foodValue
    if foodValue then
      fields.foodValueLabel = "Food: "..foodValue
      fields.foodAmountLabel = "Food: "..foodValue
    end
  end

  local subtitle = parameters.subtitle or config.subtitle
  if subtitle then
    local subtitles = root.assetJson("/items/categories.config:labels")
    fields.subtitle = subtitles[subtitle] or subtitles["other"]
  end
  parameters.tooltipFields = fields

  if not config.itemAgingScripts then
    fields.rotTimeLabel = ""
  elseif (root.assetJson("/betabound.config:rotFood") == false) or not config.itemAgingScripts then
    fields.rotTimeLabel = ""
    parameters.timeToRot = nil --root.assetJson("/items/rotting.config:baseTimeToRot")
  end

  return config, parameters
end