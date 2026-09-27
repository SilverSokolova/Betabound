function build(directory, config, parameters)
  --Fix for IDF and IDF & FU, respectively, only checking for config values
  config.effects = parameters.effects or config.effects
  config.foodValue = parameters.foodValue or config.foodValue

  require("/items/buildscripts/buildfood.lua")
  config, parameters = build(directory, config, parameters)

  local fields = config.tooltipFields or {}
  if config.itemName ~= "sb_preservedfood" and root.assetJson("/interface/tooltips/food.tooltip").effectLabel then --check for IFD
    config.tooltipKind = "sb_food"
  end

  local subtitle = parameters.subtitle or config.subtitle
  if subtitle then
    --[[
      Flashfreeze wants to keep the subtitle as a parameter,
      which causes the old parameter subtitle to show
      instead of the new config subtitle. So we discard
      the parameter so the config can show. Custom items
      can get around this by setting the subtitle
      parameter to `false`
    ]]
    if parameters.tooltipFields and parameters.tooltipFields.subtitle then
      local newTooltipFields = {}
      for k, v in pairs(parameters.tooltipFields) do
        if k ~= "subtitle" then
          newTooltipFields[k] = v
        end
      end
      parameters.tooltipFields = newTooltipFields
    end

    local subtitles = root.assetJson("/items/categories.config:labels")
    fields.subtitle = subtitles[subtitle] or subtitles["other"]
  end
  config.tooltipFields = fields

  if not config.itemAgingScripts or (root.assetJson("/betabound.config:rotFood") == false) then
    fields.rotTimeLabel = ""
    parameters.timeToRot = nil --root.assetJson("/items/rotting.config:baseTimeToRot")
  end

  return config, parameters
end