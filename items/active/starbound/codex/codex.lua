require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() sb_cursor("chat") swingInit() end

function swingAction()
  local configData = root.assetJson("/interface/scripted/sb_codex/customcodex.config")
  configData.contentPages = config.getParameter("contentPages", {{}})
  configData.customData = {config.getParameter("shortdescription",""),config.getParameter("description","")}
  configData.miscData = {config.getParameter("tooltipFields",{}),config.getParameter("inventoryIcon",nil),config.getParameter("codexIcon",nil)}
  activeItem.interact("ScriptPane", configData)
  item.consume(1)
end