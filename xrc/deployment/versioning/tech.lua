local ini = init or function() end
function init() ini()
  local t = player.equippedTech
  t = {t("head"),t("body"),t("legs")}
  for f = 1, 3 do if t[f] then if not root.hasTech(t[f]) then player.unequipTech(t[f]) end end end
end