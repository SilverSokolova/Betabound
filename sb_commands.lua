local v = {}
local originalCommand = command or function() return nil end
local originalInit = init or function() end

function init() originalInit() require("/scripts/sb_assetmissing.lua") sb_techType() end
function command(a,b,d) if originalCommand then if originalCommand(a,b,d) ~= nil then return originalCommand(a,b,d) end end if v[a] then return v[a](b,d) else return string.format(root.assetJson("/sb_commands.config").noSuchCommand,a) end end

local function cutColors(text) return string.gsub(string.gsub(text, "(%^.-%;)", ""),("\n"),"") end

local function findPlayer(id)
  if universe.findNick(id) then return universe.findNick(id) else
    local n = universe.clientIds()
    for i = 1, #n do
      if cutColors(universe.clientNick(n[i])) == id then return universe.clientNick(n[i]) end
    end
  end
  return false
end

--[[function v.whisper(you,args) local text = root.assetJson("/sb_commands.config")
  local them, msg = args[1], "" args[1]=""
  for i,v in ipairs(args) do msg=msg..v.." " end
  if not msg or string.gsub(cutColors(msg)," ","")=="" then return string.format(text.lowArgs,"whisper") end
  nick = cutColors(them)
--  if nick==cutColors(universe.clientNick(you)) then universe.adminWhisper(you,string.format(text.whisper.you,nick,msg)) return "" end
  them = findPlayer(them)
  if not them then return string.format(text.noPlayer,nick) end
  local id = universe.findNick(them)
  universe.adminWhisper(id,string.format(text.whisper.them,cutColors(universe.clientNick(you)),msg))
  universe.adminWhisper(you,string.format(text.whisper.you,nick,msg))
  return ""
end]]--
--[[
function v.isPvp(you,them) local text = root.assetJson("/sb_commands.config")
  them = them==nil and you or them[1]
  if not findPlayer(them) then return string.format(text.noPlayer,them) end
  return string.format("%s %s %s %s.",cutColors(them), cutColors(them)==cutColors(universe.clientNick(you)) and "are" or "is", universe.isPvp(them) and "" or "not", "PVP.")
end
]]--
function v.itemid(_,i,d) return v.itemID(_,i,d) end
function v.sb_itemID(_,i,d) return v.itemID(_,i,d) end
function v.sb_itemid(_,i,d) return v.itemID(_,i,d) end
function v.itemID(_,it,detailed) local text = root.assetJson("/sb_commands.config")
  detailed=it[2] or false it=it[1] or "perfectlygenericitem"
  if not sb_itemExists(it) then return string.format(text.itemID.noItem,it) else
  local rarities = {common="f6f6f6",uncommon="77ee67",rare="6ba8ec",legendary="bb5beb",essential="c3c53e"}
  local item = root.itemConfig(it)
  if detailed then return sb.printJson(item,1) end
  --todo: loop with values in keys
    local out = string.format("\n^green;Directory:^reset; ^#fff;%s%s.%s^reset;\n^green;Rarity: ^#%s;%s^reset;\n^yellow;Name: ^reset;%s\n^yellow;Category: ^reset;%s\n^yellow;Description: ^reset;%s\n^yellow;Two-Handed: ^reset;%s\n^yellow;Type: ^reset;%s\n^green;Max Stack:^reset; %s\n^green;No. Recipes:^reset; %s\n^green;Tags:^reset; %s\n^green;Tooltip Kind:^reset; %s\n^green;Fields:^reset; %s\n^green;Scripts:^reset; %s",item.directory, item.config.itemName, text.itemTypes[root.itemType(it)] or root.itemType(it),rarities[string.lower(item.config.rarity)],item.config.rarity,item.config.shortdescription,item.config.category,item.config.description,item.config.twoHanded,root.itemType(it),item.config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack").." (default)",#root.recipesForItem(it),sb.printJson(root.itemTags(it)),item.config.tooltipKind,sb.printJson(item.config.tooltipFields),sb.printJson(item.config.scripts))
  return out
  end
end

function v.sb_foodweight(_,it) local text = root.assetJson("/sb_commands.config")
  s="^#ff0;"
  it=it or {"cookedalienmeat"}
  it=type(it)=="table" and it or {it}
  for i = 1, #it do
    if not sb_itemExists(it[i]) then s = s..string.format(text.itemID.noItem,it[i]).."\n^#ff0;" else
    local item = root.itemConfig(it[i]).config
    s = s..((item.shortdescription or "???").." weight: "..1-(item.foodValue or 100)/100).."\n^#ff0;"
    end
  end
  return s
end

function v.sb_foodsum(_,it) local text = root.assetJson("/sb_commands.config")
  dr=it[2] or 1; dr=tonumber(dr); if type(dr) ~= "number" then dr = 1 end
  it=it[1] or "carrotjuice"
  if not sb_itemExists(it) then return string.format(text.itemID.noItem,it) else
  local recipe = root.recipesForItem(it)
  it = root.itemConfig(it).config
  local quantity, r
  if recipe and recipe[1] and recipe[1].output then
    mr = #recipe
    r = math.min(mr,dr)
    quantity = recipe[r].output.count
    recipe = recipe[r].input
  else return end
  local sum, psum = 0, 0
  local mod = 1
  for i = 1, #recipe do
    sb.logInfo(sb.print(recipe[i]))
    mod = recipe[i].count or 1
    input = recipe[i].name
    sum = sum + ((text.foodSums[input] and text.foodSums[input][1] or root.itemConfig(input).config.foodValue or 5)*mod)
    psum = psum + ((text.foodSums[input] and text.foodSums[input][2] or root.itemConfig(input).config.price or 0)*mod)
  end
  local finalSum = sum/quantity
  return (it.shortdescription or it.itemName).." (x"..quantity..") ("..r.."/"..mr.."): "..(finalSum == it.foodValue and "^green;" or "^red;")..finalSum.."^reset; ("..((psum*1.25)/quantity)..")"
  end
end

function v.sb_rarity(_,it) local text = root.assetJson("/sb_commands.config")
  dr=it[2] or 1; dr=tonumber(dr); if type(dr) ~= "number" then dr = 1 end
  it=it[1] or "carrotjuice"
  if not sb_itemExists(it) then return string.format(text.itemID.noItem,it) end
  local recipe = root.recipesForItem(it)
  if not recipe then return end
  local mr = #recipe
  dr = math.min(dr, mr)
  recipe = recipe[dr].input
  
  local rarities = {
    common = 1,
    uncommon = 2,
    rare = 3,
    legendary = 4,
    essential = 5
  }
  
  local rarityNames = {
    "^#f6f6f6;Common",
    "^#77ee67;Uncommon",
    "^#6ba8ec;Rare",
    "^#bb5beb;Legendary",
    "^#c3c53e;Essential"
  }
  
  it = root.itemConfig(it).config
  rarity = 1
  for i = 1, #recipe do
    sb.logInfo(sb.print(recipe[i]))
    local input = root.itemConfig(recipe[i].name)
    local newRarity = rarities[(input.parameters and input.parameters.rarity or input.config.rarity):lower()]
    sb.logInfo(newRarity)
    if newRarity > rarity then
      rarity = newRarity
    end
  end
  return (it.shortdescription or it.itemName).." ("..dr.."/"..mr.."): "..rarityNames[rarity]..""
end

function v.sb_players() return v.players() end
function v.players()
  local clientIds = universe.clientIds()
  local players = ""
  local s = #clientIds ~= 1 and "s" or ""
  for i = 1, #clientIds do players = string.format("%s%s%s",players,universe.clientNick(clientIds[i]),"^reset;, ") end
  return string.format("%s player%s:\n%s",universe.numberOfClients(),s,players):sub(1,-3)
end
--[[
function v.sb_sipAbilityMods()
  local template = ',{"name":"sb_abilitymod","category":"sb_abilities","icon":"%s","shortdescription":"%s","rarity":"%s","parameters":{"ability":"%s"}}\n'
  local abilities = root.assetJson("/sb_abilitymods.config:abilities")

  local stringOutput = "\n"
  local tableOutput = {}

  for k, _ in pairs(abilities) do
    local item = root.itemConfig({"sb_abilitymod", 1, {ability = k}}).config
    tableOutput[#tableOutput + 1] = string.format(template, item.inventoryIcon[2].image, item.shortdescription, item.rarity, k):gsub("%^reset;", "")
  end

  table.sort(tableOutput, function(a, b)
    local aQueryStart = a:find("shortdescription") + 19
    local bQueryStart = b:find("shortdescription") + 19
    return cutColors(a:sub(aQueryStart, a:find("\"", aQueryStart) - 1)) < cutColors(b:sub(bQueryStart, b:find("\"", bQueryStart) - 1)) end
  )

  for i = 1, #tableOutput do
    stringOutput = stringOutput .. tableOutput[i]
  end

  sb.logInfo(stringOutput)
  return #tableOutput
end]]

function v.sb_sip(_, category); category = category[1]
  local templates = {
    ability = ',{"name":"sb_abilitymod","category":"sb_weaponmods","icon":"%s","shortdescription":"%s","rarity":"%s","parameters":{"ability":"%s"}}\n',
    ammo = ',{"name":"sb_ammo","category":"sb_ammo","icon":"%s","shortdescription":"%s","rarity":"%s","parameters":{"projectileType":"%s"}}\n',
    music = ',{"name":"sb_musicsheet","category":"sb_music","icon":"%s","shortdescription":"%s","rarity":"%s","parameters":{"music":"%s"}}\n'
  }

  if not templates[category] then
    local output = ""
    for k, _ in pairs(templates) do
      output = output .. k .. " | "
    end
    return "Invalid item type. Valid types are: " .. output
  end

  local stringOutput = "\n"
  local tableOutput = {}

  if category == "ability" then
    local abilities = root.assetJson("/sb_abilitymods.config:abilities")

    for k, _ in pairs(abilities) do
      local item = root.itemConfig({"sb_abilitymod", 1, {ability = k}}).config
      tableOutput[#tableOutput + 1] = string.format(templates[category], item.inventoryIcon[2].image, item.shortdescription, item.rarity, k):gsub("%^reset;", "")
    end
  elseif category == "ammo" then
    local ammo = root.assetJson("/sb_projectiles.config")

    for k, _ in pairs(ammo) do
      local item = root.itemConfig({"sb_ammo", 1, {projectileType = k}}).config
      tableOutput[#tableOutput + 1] = string.format(templates[category], item.inventoryIcon[2].image, item.shortdescription, item.rarity, k):gsub("%^reset;", "")
    end
  elseif category == "music" then
    local music = root.assetJson("/collections/sb_music.collection:collectables")

    for k, _ in pairs(music) do
      local item = root.itemConfig({"sb_musicsheet", 1, {music = k}}).config

      tableOutput[#tableOutput + 1] = string.format(templates[category], item.inventoryIcon:sub(1, 1) == "/" and item.inventoryIcon or ("/items/generic/unlock/" .. item.inventoryIcon), item.shortdescription, item.rarity, k)
    end
  end

  table.sort(tableOutput, function(a, b)
    local aQueryStart = a:find("shortdescription") + 19
    local bQueryStart = b:find("shortdescription") + 19
    return cutColors(a:sub(aQueryStart, a:find("\"", aQueryStart) - 1)) < cutColors(b:sub(bQueryStart, b:find("\"", bQueryStart) - 1)) end
  )

  for i = 1, #tableOutput do
    stringOutput = stringOutput .. tableOutput[i]
  end

  sb.logInfo(stringOutput)
  return #tableOutput
end