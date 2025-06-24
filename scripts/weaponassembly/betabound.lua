local originalIsValidWeapon = isValidWeapon or function() end
local originalBuildShortDescription = buildShortDescription or function() return "Weapon" end

function isValidWeapon(weapon)
  if weapon then
    local sb_itemConfig = root.itemConfig(weapon).config
    if ((sb_itemConfig.builder == "/items/buildscripts/starbound/buildweapon.lua" or sb_itemConfig.sb_builder == "/items/buildscripts/buildweapon.lua") and not root.itemConfig(weapon).config.sb_waBan) or originalIsValidWeapon(weapon) then
      return true
    end
  end
  return originalIsValidWeapon(weapon)
end

function buildShortDescription(partName, weaponConfig) --I'm sure it's fine right now, but shouldn't we be making use of what we're replacing?
  local name = (weaponConfig.shortdescription or "")
  --local name = string.gsub(string.format("%s%s",weaponConfig.shortdescription,string.gsub(originalBuildShortDescription(partName, weaponConfig), "(%w+)","",1)),"  "," ")
  --surely there's a better way to do this. this loops i*3 times! (does it?)
  local rarities = {"Common","Uncommon","Rare","Legendary","Essential"}
  for i = 1, #rarities do name=name:gsub(rarities[i].." ","") end
  name=name.." "..partName:gsub(partName:sub(1,1),string.upper(partName:sub(1,1)))
  return name
end
--I am aware that you can dupe weapons with this but I want to sleep right now
--HOW CAN YOU DUPE WEAPONS WITH IT??
--ok so reload the game with the item in the interface. it's an issue on their end, not ours