local originalIsValidWeapon = isValidWeapon or function() end

function isValidWeapon(weapon)
  if weapon then
    return (root.itemConfig(weapon).config.sb_builder or "") == "/items/buildscripts/buildweapon.lua" or originalIsValidWeapon(weapon)
  end
end