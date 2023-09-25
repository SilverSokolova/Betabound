require("/scripts/sb_assetmissing.lua")
function month(n) local a=(os.time()-os.time{year=2000,month=1,day=1})/31557600 return n==math.ceil((a-math.floor(a))*12) end
function init()
  if entity.entityType() ~= "player" and status.statusProperty("sb_outpostnpcspawner") ~= true then

  positions = config.getParameter("positions")
  positions = sb_itemExists("anom_outpostelliotassistant") and positions["anom"] or positions["default"]

  local npcs = config.getParameter("npcs")
  for i = 1, #npcs do
    local npc = npcs[i]
    world.spawnNpc(positions[i], npc[1], npc[2], 1, npc[3])
  end

	if month(2) then world.spawnItem("heartforge-recipe",positions[10]) elseif month(12) then world.spawnNpc(positions[11],"human","santa",100) end
	if world.objectAt(positions[12]) then
	  if world.containerAddItems(world.objectAt(positions[12]),"comedyscript") == {} then
	    world.spawnItem("comedyscript",positions[10])
	  end
	end

	status.setStatusProperty("sb_outpostnpcspawner",true) end
end

function update()
  if not world.universeFlagSet("sb_hylotlwarriorE2") then script.setUpdateDelta(0) return end
  if positions then if world.spawnVehicle("sb_kennel",positions[13]) then script.setUpdateDelta(0) return end end
end