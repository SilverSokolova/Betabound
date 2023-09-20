require("/scripts/sb_assetmissing.lua")
function month(n) local a=(os.time()-os.time{year=2000,month=1,day=1})/31557600 return n==math.ceil((a-math.floor(a))*12) end
function init()
  local spawnNpc = world.spawnNpc
  if entity.entityType() ~= "player" and status.statusProperty("sb_outpostnpcspawner") ~= true then

  positions = {
    {412,614}, --excon
    {360,611}, --refugee
    {374,627}, --scientist
    {508,611}, --mechanic
    {508,611}, --promoter
    {416,611}, --warrior
    {404,611}, --hater (was 508,610)
    {412,614}, --mercenary (seed was 14)
    {377,614}, --forge
    {286,611}, --santa
    {356,641}, --garbage
    {200,616}  --kennel
  }

  if sb_itemExists("anom_outpostelliotassistant") then
    positions = {
      {412,614}, --excon
      {360,611}, --refugee
      {374,627}, --scientist
      {508,610}, --mechanic
      {508,610}, --promoter
      {416,611}, --warrior
      {710,611}, --hater
      {412,614}, --mercenary (seed was 14)
      {377,614}, --forge
      {286,611}, --santa
      {444,580}, --garbage
      {0,0}     --kennel
    }
  end


--could loop spawning of npcs or move to config file
	spawnNpc(positions[1],"human","outposthumanexcon",1,46)
	spawnNpc(positions[2],"avian","outpostavianrefugee",1,25)
	spawnNpc(positions[4],"apex","outpostapexscientist",1,7)
	spawnNpc(positions[5],"glitch","outpostglitchmechanic",1,28)
	spawnNpc(positions[5],"penguin","outpostpenguinpromoter",1,28)
	spawnNpc(positions[6],"hylotl","outposthylotlwarrior",1,9)
	spawnNpc(positions[7],"hylotl","sb_outposthylotlfloranhater",1,28) --was 508,610
	spawnNpc(positions[8],"glitch","outpostglitchmercenary",1,41) --was 14
	spawnNpc(entity.position(),"floran","sb_outpostfloranscholar",1,57)

	if month(2) then world.spawnItem("heartforge-recipe",positions[9]) elseif month(12) then world.spawnNpc(positions[10],"human","santa",100) end
	if world.objectAt(positions[11]) then
	  if world.containerAddItems(world.objectAt(positions[11]),"comedyscript") == {} then
	    world.spawnItem("comedyscript",positions[9])
	  end
	end

	status.setStatusProperty("sb_outpostnpcspawner",true) end
end

function update()
  if not world.universeFlagSet("sb_hylotlwarriorE2") then script.setUpdateDelta(0) return end
  if positions then if world.spawnVehicle("sb_kennel",positions[12]) then script.setUpdateDelta(0) return end end
end