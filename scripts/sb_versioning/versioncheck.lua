local originalInit = init or function() end
function init() originalInit()
  local t = player.equippedTech
  t = {t("head"),t("body"),t("legs")}
  for f = 1, 3 do if t[f] then if not root.hasTech(t[f]) then player.unequipTech(t[f]) end end end

  local currentVersion = 34
  if player.introComplete() then
    local playerVersion = player.getProperty("betabound", {}).version or status.statusProperty("xrc_0018z", 0)
    if playerVersion < currentVersion then
      sb.logInfo(string.format("[Betabound] Okay! Updating this character from %s to %s!", playerVersion, currentVersion))
      require("/scripts/sb_versioning/versioning.lua")
      sb_doVersioning(currentVersion, playerVersion)
      sb.logInfo(string.format("[Betabound] Done! Updated this character from %s to %s!", playerVersion, currentVersion))
    end
  end
end