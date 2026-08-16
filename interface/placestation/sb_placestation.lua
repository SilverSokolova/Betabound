local originalInit = init

function init(); originalInit()
  local sb_defaultWidgetTextValues = {}
  local playerStationParameters = root.assetJson("/system_objects.config:playerstation.parameters")
  sb_defaultWidgetTextValues["configure.name"] = playerStationParameters.displayName
  sb_defaultWidgetTextValues["configure.description"] = playerStationParameters.description

  widget.sb_getText = widget.getText
  widget.getText = function(widgetName)
    local widgetText = widget.sb_getText(widgetName)
    return widgetText == "" and sb_defaultWidgetTextValues[widgetName] or widgetText
  end
end