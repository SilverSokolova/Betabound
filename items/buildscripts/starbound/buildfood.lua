function build(directory, config, parameters)
  config.effects = parameters.effects or config.effects --fix for IFD only checking config for status effects
  require("/items/buildscripts/buildfood.lua")
  config, parameters = build(directory, config, parameters)
  local foodTooltip = root.assetJson("/interface/tooltips/food.tooltip")
  local fields = config.tooltipFields or {}
  if foodTooltip.effectLabel then --check for IFD
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

  if not config.itemAgingScripts then
    fields.rotTimeLabel = ""
  elseif (root.assetJson("/betabound.config:rotFood") == false) or not config.itemAgingScripts then
    fields.rotTimeLabel = ""
    parameters.timeToRot = nil --root.assetJson("/items/rotting.config:baseTimeToRot")
  end

  local icon = parameters.inventoryIcon
  if icon and type(icon) == "string" and icon:sub(1, 1) == "/" and not root.nonEmptyRegion(icon) then
    local originalItemName = parameters.originalItemName
    local directives = icon:match(".*(%?.*)") or ""
    icon = icon:match("(.-)%?.*")
    if originalItemName then
      local newIcon = root.itemConfig(originalItemName); if not newIcon then return end
      local directory = newIcon.directory
      newIcon = newIcon.parameters.inventoryIcon or newIcon.config.inventoryIcon
      if type(newIcon) == "string" then
        if newIcon:sub(1, 1) ~= "/" then
          newIcon = directory..newIcon
        end
        newIcon = newIcon..directives
      end
      parameters.inventoryIcon = newIcon
    else
      local newParameters = root.itemConfig("cannedfood")
      local newIcon = newParameters.config.inventoryIcon
      parameters.inventoryIcon = (newIcon:sub(1, 1) == "/" and newIcon or newParameters.directory .. newIcon) .. directives
      parameters.shortdescription = newParameters.config.shortdescription
      parameters.description = newParameters.config.description
      parameters.tooltipKind = newParameters.config.tooltipKind
    end
  end

  return config, parameters
end