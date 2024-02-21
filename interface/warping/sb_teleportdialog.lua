function init()
  local b = config.getParameter("")
  b.gui = nil
  b.scripts = nil
  player.interact("ScriptPane",sb.jsonMerge(root.assetJson("/interface/windowconfig/sb_teleportdialog.config"),b),player.id())
  pane.dismiss()
end