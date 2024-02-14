require "/scripts/activeitem/sb_cursors.lua"

function init()
  activeItem.setHoldingItem(false)
  sb_cursor("inspect")
  target, defaults, str, desc = nil, nil, {"...","..."}, ""
  c = {"",".^reset;"}

  nouns = config.getParameter("nouns")
  defaultPlayerDescription = config.getParameter("defaultPlayerDescription")
  defaultNpcDescription = config.getParameter("defaultNpcDescription")
  defaultPassiveMonsterDescription = config.getParameter("defaultPassiveMonsterDescription")
  defaultAggressiveMonsterDescription = config.getParameter("defaultAggressiveMonsterDescription")

  nothingThereText = root.assetJson("/items/tools/inspectiontool/inspectionmode.inspectiontool:nothingThereText")
  race = world.entitySpecies(activeItem.ownerEntityId()) or "default"
  prefix = config.getParameter(race.."Prefix","")
  local NTTR = nothingThereText[race]
  if not NTTR then race = "default" end
  nothingThereText = NTTR and NTTR or nothingThereText["default"]
  scannables = {"itemDrop","npc","monster","player"}
  scanKeys = {}
  for i = 1, #scannables do
    scanKeys[scannables[i]] = scannables[i]
  end
end

function update() target = world.entityQuery(activeItem.ownerAimPosition(), 0,{includedTypes=scannables})[1] end

function activate(fireMode)
  str = {"",""}
  local entityType = target and world.entityType(target) or ""
  if scanKeys[entityType] then scan[entityType]() else nothingThere() end
  activeItem.emote("blabbering")

  if player.say then
    player.say(desc)
  else
    --stupid stuff because world.spawnMonster doesn't return an entity ID here for some reason
    local pos = entity.position()
    local chatters = world.monsterQuery(pos,2)
    for _, v in pairs(chatters) do
      if world.entityTypeName(v) == "sb_speech" then world.sendEntityMessage(v,"despawn") end
    end
    world.spawnMonster("sb_speech",pos,{text=desc,owner=entity.id()})
  end
end

function getNouns(t,i)
  local a = world.entityGender(t)
  local b = nouns[a] or nouns["other"]
  return b[i]
end

scan={}
scan["itemDrop"] = function()
  defaults = root.itemConfig(world.entityName(target)).config
  local v = world.itemDropItem(target).parameters
  if v == nil then return end
  str[1] = c[1]..(v.shortdescription or defaults.shortdescription)..c[2]
  str[2] = prefix..(v.description or defaults.description)
  formatDesc()
end

scan["npc"] = function()
  if world.entityName(target) ~= nil then str[1] = c[1]..world.entityName(target)..c[2] end
  if world.entityTypeName(target) == "ignobletarget" and world.entityName(target) ~= root.npcConfig("ignobletarget").identity.name then str[1]=c[1]..root.npcConfig("ignobletarget").identity.name..c[2] end
  if world.entityDescription(target) ~= nil then str[2] = world.entityDescription(target) end
  if str[2] == "Some funny looking person" then str[2] = defaultNpcDescription end
  formatDesc()
end

scan["monster"] = function()
  if world.entityDescription(target) ~= nil then
    str[2] = world.entityDescription(target) or ""
      if str[2] == "Some indescribable horror" then
  if not world.entityAggressive(target) then
    str[2] = defaultPassiveMonsterDescription
  else str[2] = defaultAggressiveMonsterDescription end
      else str[2] = world.entityDescription(target)..""
    end
  end
  if world.entityName(target) == nil then str[1] = str[2] str[2] = "" else str[1] = c[1]..world.entityName(target)..c[2] end
  formatDesc()
end

scan["player"] = function()
  str[2] = string.format(defaultPlayerDescription,getNouns(target,1),getNouns(target,2))
  if world.entityName(target) ~= nil then str[1] = c[1]..world.entityName(target)..c[2] end
  if world.entityDescription(target) ~= nil then
    if world.entityDescription(target) ~= "This guy seems to have nothing to say for himself." then
      str[2] = world.entityDescription(target)
    end
  end
  formatDesc()
end

function nothingThere()
  desc = nothingThereText[math.random(#nothingThereText)]
end

function formatDesc()
  if str[1] == c[1]..c[2] then str[1] = "" end
  if str[1] == "" then str[1] = str[2] str[2] = "" end
  if str[1]..str[2] ~= "" then desc = str[1].." "..str[2] else nothingThere() end
end