local ini = init or function() end
function init() ini()
if not status.statusProperty("xrc_0018") then status.setStatusProperty("xrc_0018",0) end
local cv, pv = 4, status.statusProperty("xrc_0018")
  if player.introComplete() and cv > pv then
	if pv == 0 then player.giveItem("sb_inspect") player.giveItem("sb_survivalguide-codex") elseif
	   pv == 1 and player.hasActiveQuest("sb_avianrefugeeE2.gearup") then player.giveBlueprint("paperwingsback") player.giveItem("voxel5k") elseif
	   pv == 2 and #player.shipUpgrades().capabilities > 0 then require("/scripts/sb_assetmissing.lua") local i = "sb_"..(player.species()=="novakid" and "nova" or player.species()).."starter" if sb_itemExists(i) then player.giveItem(i) end elseif
	   pv == 3 and #player.shipUpgrades().capabilities > 0 then require("/scripts/sb_assetmissing.lua") local i = "sb_"..player.species().."tier0shortsword" if sb_itemExists(i) then player.giveItem(i) end
	end
    status.setStatusProperty("xrc_0018",cv)
  end
end