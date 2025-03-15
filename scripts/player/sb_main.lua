function init()
  math.betabound_player = _ENV.player
  mcontroller = math.betabound_mcontroller

--  if not entity then status.addPersistentEffect("sb_entity","sb_entity") end
--  entity = math.betabound_entity

  --Suit tech. TODO: clean this up. give names to variables
  message.setHandler("sb_implant_unequip", function(_, fromSelf)
    if fromSelf == false then return end
    status.clearPersistentEffects("sb_bioimplant")
    player.setProperty("sb_bioimplant")
  end)

  message.setHandler("sb_implant", function(_, fromSelf, b)
    if fromSelf == false then return end
    if b == nil then return end
    if type(b) == "string" then b = {b,root.techConfig(b).sb_effect} end
    if type(b[2]) == "string" then b[2] = {b[2]} end
    status.clearPersistentEffects("sb_bioimplant")
    player.setProperty("sb_bioimplant",b[1])
    if b[2] ~= nil then status.setPersistentEffects("sb_bioimplant",b[2]) end
  end)

  --Peacekeeper Teleporter
  message.setHandler("sb_peacekeeperteleporter", function(_, _, b)
    local bountyData = player.getProperty("bountyStation", nil)
    bountyData = bountyData[player.serverUuid()] or nil
    local interactData = root.assetJson(b[2])
    if bountyData and bountyData ~= '{}' then
      if bountyData.worldId then
        local worldId = bountyData.worldId
        local systemObjects = root.assetJson("/system_objects.config")
        local n = worldId:find(":")+1
        local rank = worldId:sub(n,worldId:find(":",n)-1)
        dest = {
          deploy = player.getProperty("mechUnlocked", false),
          name = systemObjects[rank].parameters.displayName,
          planetName = "",
          warpAction = worldId,
          icon = rank
        }
      end
    end
    if bountyData and dest then
      interactData.destinations[1] = dest --#interactData.destinations+1
    else
      interactData.destinations = nil
    end
    player.interact(b[1],interactData,b[3])
  end)

  --Random Fountain
  message.setHandler("sb_randomfountain", function(_, _, args)
    if args then
      if type(args) == "string" then
        status.addEphemeralEffect(args)
      else
        status.addEphemeralEffect(args[1], args[2])
      end
      if player.emote then
        player.emote("eat")
      end
    end
  end)

  --Wired Teleporters
  message.setHandler("sb_wiredteleporter", function(_, _, x, y)
    if x and y and not status.uniqueStatusEffectActive("blink") then
      status.addEphemeralEffect("blink", 0.5)
      mcontroller.setPosition({x, y + 3})
    end
  end)

  --SE commands
  message.setHandler("/sb_maketechavailable", function(_, fromSelf, b)
    if fromSelf == false then return end
    if b == nil or type(b) ~= "string" then return end
    local suits = player.getProperty("sb_availableBioimplants")
    if #suits == 0 then suits = {b} else suits[#suits+1] = b end
    player.setProperty("sb_availableBioimplants",suits)
    return "Added "..b.." to player's visible techs"
  end)

  message.setHandler("/sb_enabletech", function(_, fromSelf, b)
    if fromSelf == false then return end
    if b == nil or type(b) ~= "string" then return end
    local suits = player.getProperty("sb_bioimplants")
    if #suits == 0 then suits = {b} else suits[#suits+1] = b end
    player.setProperty("sb_bioimplants",suits)
    return "Player tech "..b.." enabled"
  end)

  message.setHandler("/sb_showhunger", function(_, fromSelf)
    if interface and fromSelf then
      interface.queueMessage(string.format(root.assetJson("/betabound.config:showHunger"), math.floor(status.resource("food")).."/"..math.floor(status.resourceMax("food"))), 4, 0.5)
    end
  end)
end