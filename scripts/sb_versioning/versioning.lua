xrc0018 = {}
local function blue(a) if type(a)=="string" then a={a} end for i = 1, #a do player.giveBlueprint(a[i]) end end
local function quest(a,b) if type(b)=="string" then b={b} end if player.hasCompletedQuest(a) then for i = 1, #b do player.giveItem(b[i]) end end end
local function boxQuest(a,b) if player.hasCompletedQuest(a) then IB[#IB+1] = b end end
local function giveBox(desc, tooltipKind) if #IB > 0 then player.giveItem({"sb_itembox",1,{tooltipKind=tooltipKind,description=string.format(root.assetJson("/betabound.config")[desc], #IB),items=IB}}) end end
local function updateNote(a)
  local b = root.assetJson("/betabound.config")
  local i = root.assetJson("/scripts/sb_versioning/updateNote.json")
  i.parameters.description = b.updateNotes[a or "default"]
  player.giveItem(i)

  local audiodisc = root.itemConfig("audiodisc").config
  player.radioMessage({
    messageId = sb.makeUuid(),
    unique = false,
    text = b["developerMessage"].." "..i.parameters.description,
    portraitImage = audiodisc.defaultPortrait,
    portraitFrames = audiodisc.defaultPortraitFrames,
    senderName = "Betabound"
  })
end
local function reunlockRecipes(a)
  if type(a) == "string" then a = {a} end
  for i = 1, #a do
    if player.blueprintKnown(a[i]) then
      local recipes = root.recipesForItem(a[i][1])
      for j = 1, #recipes do
        player.giveBlueprint(recipes[j].output)
        sb.logInfo("Updated recipe for: "..a[i][1])
      end
    end
  end
--[[
  for k, v in pairs(a) do
    for k2, v2 in pairs(v) do
      sb.logInfo(sb.print(v2))
      if player.blueprintKnown(v2) then
        local recipes = root.recipesForItem(v2)
        for j = 1, #recipes do
          player.giveBlueprint(recipes[j])
        end
      end
    end
  end]]
end

xrc0018[1]=function() local b = root.assetJson("/betabound.config:defaultItems") for i = 1, #b do player.giveItem(b[i]) end end
xrc0018[4]=function() quest("sb_kelpquest.gearup","refinery") end
xrc0018[5]=function() quest("sb_kelpquest.gearup","sb_techconsole") end
xrc0018[8]=function()
  local a = status.statusProperty("sb_bioimplants")
  local b = root.assetJson("/versioning/sb_tech.config")
  local c = status.statusProperty("sb_bioimplant") or ""
  local e = {}
  if a then
    for i = 1, #a do
      sb.logInfo(a[i])
      sb.logInfo(b[a[i]] or "")
      if b[a[i]] then e[i]=b[a[i]] else e[i]=a[i] end
      if a[i] == c then
        status.clearPersistentEffects("sb_bioimplant")
        status.setStatusProperty("sb_bioimplant",e[i])
        local d = root.hasTech(c) and root.techConfig(c) or root.hasTech(e[i]) and root.techConfig(e[i]) or root.hasTech(b[e[i]]) and root.techConfig(b[e[i]])
        if d then status.setPersistentEffects("sb_bioimplant",{d.sb_effect}) end
      end
    end
    status.setStatusProperty("sb_bioimplants",e)
  end
end

xrc0018[13]=function() if player.blueprintKnown("sb_frostshield") then player.giveItem("sb_frostshield-recipe") player.addCurrency("money",5000) end end
xrc0018[14]=function()
  player.setProperty("betabound", sb.jsonMerge(status.statusProperty("betabound", {}), player.getProperty("betabound", {})))
  status.clearPersistentEffects("sb_entity")
  local p = {"sb_bioimplant","sb_bioimplants"}
  local d = {{},nil,{}}
  for i = 1, #p do player.setProperty(p[i],status.statusProperty(p[i],d[i])) status.setStatusProperty(p[i]) end
  if type(player.getProperty(p[1])) ~= "string" then player.setProperty(p[1],nil) end
end
xrc0018[15]=function() quest("destroyruin","sb_beamaxe2") end
xrc0018[17]=function() player.setProperty("sb_availableBioimplants",{}) if player.getProperty("sb_bioimplant","") == "sb_noprotection" then player.setProperty("sb_bioimplant") end end
xrc0018[18]=function()
  local a, b, e, f = player.getProperty("sb_bioimplants"), root.assetJson("/versioning/sb_tech.config"), {}, player.getProperty("sb_availableBioimplants")
  sb.logInfo("Owned Suits: "..sb.print(a or {}))
  sb.logInfo("Available Suits: "..sb.print(f or {}))
  local c = player.getProperty("sb_bioimplant") or ""
  if a then
    for i = 1, #a do
      sb.logInfo(string.format("Converting suit tech '%s' to '%s.'",a[i],b[a[i]] or a[i]))
      if b[a[i]] then e[i]=b[a[i]] else e[i]=a[i] end
      if a[i] == c then
        status.clearPersistentEffects("sb_bioimplant")
          player.setProperty("sb_bioimplant",e[i])
          local d = root.hasTech(c) and root.techConfig(c) or root.hasTech(e[i]) and root.techConfig(e[i]) or root.hasTech(b[e[i]]) and root.techConfig(b[e[i]])
          if d then status.setPersistentEffects("sb_bioimplant",type(d.sb_effect)=="string" and {d.sb_effect} or d.sb_effect) end
      end
    end
    player.setProperty("sb_bioimplants",e)
  end
  e = {}
  if f then
    for i = 1, #f do
      sb.logInfo(string.format("Converting possibly unpurchased suit tech '%s' to '%s.'",f[i],b[f[i]] or f[i]))
      if b[f[i]] then e[i]=b[f[i]] else e[i]=f[i] end
    end
    player.setProperty("sb_availableBioimplants",e)
  end
  IB = {}
  boxQuest("sb_bountyhunter1.gearup",{"sb_uncommonbroadsword",1,{level=2}})
  boxQuest("sb_bountyhunter3.gearup",{"sb_uncommonshotgun",1,{level=4}})
  boxQuest("sb_floranhunter4.gearup",{"sb_uncommonspear",1,{level=5}})
  boxQuest("sb_humanexcon4.gearup",{"sb_uncommonaxe",1,{level=5}})
  giveBox("changedQuestRewards")
end
--[[
xrc0018[19]=function()
  if newPlayer then return end
  local r = {"floran","hylotl","avian","apex","glitch"}
  local q = {}
  for i = 1, 2 do
    for j = 1, #r do
      q[#q+1] = r[j].."_mission"..i
    end
  end
  IB = {}
  local t = {2,3,4,5,6} for i = 1, #t do t[#t+1]=t[i] end
  boxQuest("destroyruin",{"superrewardbag",1,{treasure={level=6}}})
  for i = 1, #q do
    boxQuest(q[i],{"rewardbag",1,{treasure={level=t[i]}}})
  end
  q = {
    {"sb_outpost0","sb_outpost1","sb_outpost2","sb_humanscientist1","sb_floranfan1"},
    {"sb_outpostSkin","sb_coffee2","sb_bountyhunter1"},
    {"sb_kelpquest","sb_bountyhunter2","sb_humanexcon2","sb_humansurvivor2"},
    {"sb_glitchsilenttype3","sb_avianexplorer3","sb_bountyhunter3"},
    {"sb_humanexcon4","sb_avianexplorer4","sb_avianmercenary4","sb_apexrefugee4","sb_floranhunter4","sb_bountyhunter4"},
    {"sb_avianrefugeeE1","sb_humanscientistE1","sb_avianrefugeeE2","sb_hylotlwarriorE2","sb_hylotlwarriorE1","sb_penguinpromoterE1"}
  }
  for i = 1, #q do for j = 1, #q[i] do boxQuest(q[i][j]..".gearup",{"rewardbag",1,{treasure={level=i}}}) end end
  giveBox("changedQuestRewards")
end
]]
xrc0018[20]=function()
  local q = {"sb_floranfan1","sb_hylotlwarriorE2"}
  for i = 1, #q do
    if player.hasCompletedQuest(q[i]..".gearup") then
      player.setUniverseFlag(q[i])
    end
  end
end

--21, 6/OCT/2022: Phase out redundant Betabound crafting stations
xrc0018[21]=function()
  if player.blueprintKnown("sb_steelbar") then
    updateNote("090")
  end
end

xrc0018[23]=function()
  local a = player.getProperty("eesTransmutations")
  if a and a.EES_farmemc then
    local b = {EES_farmemc={}}
    local c = {"sb_avesmingo","sb_banana","sb_beakseed","sb_boltbulb","sb_coffeebeans","sb_pearlpea","sb_pussplum"}
    for k, v in pairs(a.EES_farmemc) do
      local keep = true
      for i = 1, #c do
        if (k == c[i]) then
          keep = false
          break
        end
      end
      if keep then
        b.EES_farmemc[k] = v
      end
    end
    player.setProperty("eesTransmutations", b)
  end
end
xrc0018[25]=function()
  if player.blueprintKnown("sb_frostshield") then player.giveItem("frostshield-recipe") end
  if player.blueprintKnown("sb_mushroomshield") then player.giveItem("mushroomshield-recipe") end
end
xrc0018[26]=function()
  local a = root.assetJson("/species/sb_recipes.config")
  local b = a.species
  local c = false
  for i = 1, #b do
    if player.species() == b[i] then
      c = true
    end
  end
  if c == false then
    b = a.unknownSpeciesRecipes
    local d = a.weaponTiers
    local e = a.weapons
    local f = a.branchingWeaponTiers
    local g = {"a","m","s"}
    for m = 1, #e do
      for i = d[1], d[2] do
        player.giveBlueprint(string.format(e[m],b,i))
      end
    end
    for i = 1, f do
      for m = 1, #e do
        for j = 1, #g do
          player.giveBlueprint(string.format(e[m],b,i+d[2]..g[j]))
        end
      end
    end
  end
end

--27: The tech binding stations no longer allow players to equip techs. Give them a techconsole so they have one
--Give players an ammo guide if they missed it (returning player)
--We use to have two scripts like this. One was shitty, so I'm ditching it completely now. If there are returning players from when that script was still used, run its code before deleting the version tracker
xrc0018[27]=function()
  quest("sb_outpostSkin.gearup","techconsole")
  if not newPlayer then player.giveItem("sb_gunguide-codex") end
  local a = status.statusProperty("xrc_0018")
  if a then
    if pv == 0 then player.giveItem("sb_inspect") player.giveItem("sb_survivalguide-codex") elseif
      pv == 1 and player.hasActiveQuest("sb_avianrefugeeE2.gearup") then player.giveBlueprint("paperwingsback") player.giveItem("voxel5k") elseif
      pv == 2 and #player.shipUpgrades().capabilities > 0 then require("/scripts/sb_assetmissing.lua") local i = "sb_"..(player.species()=="novakid" and "nova" or player.species()).."starter" if sb_itemExists(i) then player.giveItem(i) end elseif
      pv == 3 and #player.shipUpgrades().capabilities > 0 then require("/scripts/sb_assetmissing.lua") local i = "sb_"..player.species().."tier0shortsword" if sb_itemExists(i) then player.giveItem(i) end
    end
    status.setStatusProperty("xrc_0018",nil)
  end
end
xrc0018[28]=function()
  if player.hasCompletedQuest("floranarena3") then
    player.giveItem({"sb_musicsheet",1,{music="impact-event"}})
  end
end
xrc0018[30]=function()
  if type(player.getProperty("sb_bioimplants")) ~= "table" then
    player.setProperty("sb_bioimplants", {})
  end
end
--32: Merge Betabound status properties to a single player property
xrc0018[32]=function()
  if not newPlayer then
    status.setStatusProperty("xrc_0018z", nil)
  end
  local ship = player.getProperty("sb_shipUpgrades")
  if type(ship) ~= "nil" then
    local betaboundStorage = player.getProperty("betabound", {})
    betaboundStorage.shipUpgrades = ship
    sb.logInfo(sb.printJson(betaboundStorage))
    player.setProperty("betabound", betaboundStorage)
    player.setProperty("sb_shipUpgrades", nil)
  end
  if player.hasCompletedQuest("destroyruin") then
    player.consumeCurrency("sb_questActive:destroyruin", 1)
  end
  player.startQuest("sb_techunlocks")
end

--31: Convert parametered weapon recipes to new format
--33: Convert harpoon gun
xrc0018[33]=function()
  reunlockRecipes(root.assetJson("/scripts/sb_versioning/procgenWeaponRecipes.json"))
end

--34: Chopped off the ".gearup" part of our quests, so check if the player completed those. If so, complete the quests under the new name.
xrc0018[34]=function()
  IB = {}
  local quests = root.assetJson("/scripts/sb_versioning/changedQuestIds.json")
  for v, k in pairs(quests) do
    if player.hasCompletedQuest(v..".gearup") then
      sb.logInfo(string.format("Player has done %s.gearup, giving required items for %s", v, k))
      local questItems = root.questConfig(type(k) == "string" and k or v).scriptConfig
      if questItems then
        questItems = questItems.conditions
        if questItems then
          for i = 1, #questItems do
            if questItems[i].itemName then
              IB[#IB+1] = {questItems[i].itemName, questItems[i].count or 1}
            end
          end
        end
      end
    end
  end
  giveBox("changedQuestIds", "sb_tech")
end

--35, 6/FEB/2025: Changed repair tool names
xrc0018[35]=function()
  updateNote()
end

function sb_doVersioning(cv,yv)
  newPlayer = yv == 0
  --player.getProperty doesn't return the default if the saved value exists as nil, so set it so the tech unlock quest doesnt break
  local betaboundStorage = player.getProperty("betabound")
  if type(betaboundStorage) == "nil" then
    player.setProperty("betabound", {})
  end

  for i = yv, cv-1 do
    if xrc0018[i+1] then
      xrc0018[i+1]()
    end
  end
  player.setProperty("betabound", sb.jsonMerge(player.getProperty("betabound", {}), {version = cv}))
end