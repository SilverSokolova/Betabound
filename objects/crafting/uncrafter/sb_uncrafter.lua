local originalInit = init or function() end

function init(args); originalInit(args)
  if weaponLevelKinds then
    --[[
      TODO: Do any of the uncrafter mods replace this object?
      If so, it might be risky to load after them all because
      someone may reverse engineer one of the faulty ones and
      we'd have to account for that, too.
      This directory is a good place to put a config file with
      whatever we'd put into the object, anyway.
    ]]

    --Move mostly everything up a tier, and add our own stuff
    sb_modifyWeaponLevelKinds(1, "tungstenbar", {"copperbar", "copperbar"}) --No more tier 1 tungsten
    sb_modifyWeaponLevelKinds(2, "titaniumbar", {"goldbar", "tungstenbar"})
    sb_modifyWeaponLevelKinds(3, "durasteelbar", {"platinumbar", "sb_steelbar"})
    weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "durasteelbar"
    weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "sb_refinedrubium"
    weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "sb_refinedrubium"
    weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_refinedrubium"
  --weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
  --weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
  --weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
  end
end

function sb_modifyWeaponLevelKinds(tier, itemName, newItems)
  for i = 1, #weaponLevelKinds[tier] do
    if weaponLevelKinds[tier][i] == itemName then
      weaponLevelKinds[tier][i] = newItems[1 + i % 2]
    end
  end
end