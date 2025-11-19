function init()
  math.betabound_player = _ENV.player
  mcontroller = math.betabound_mcontroller

  --If this check isn't passing on oSB, whatever is setting it before we get here (status script?) probably isn't, so move that check here.
  if math.betabound_client == "OpenSB" then
    inventory = interface.bindRegisteredPane("Inventory")
    updateSuitIcon(player.getProperty("sb_bioimplant"))
  else
    updateSuitIcon = function() end
  end

  --Suit tech. TODO: clean this up. give names to variables
  message.setHandler("sb_implant_unequip", function(_, fromSelf)
    if fromSelf == false then return end
    status.clearPersistentEffects("sb_bioimplant")
    player.setProperty("sb_bioimplant")
    updateSuitIcon()
  end)

  message.setHandler("sb_implant", function(_, fromSelf, techName)
    if not fromSelf or not techName then return end

    status.clearPersistentEffects("sb_bioimplant")
    local effects = root.techConfig(techName).sb_effect
    if effects then
      if type(effects) == "string" then
        effects = {effects}
      end
      status.setPersistentEffects("sb_bioimplant", effects)
    end

    player.setProperty("sb_bioimplant", techName)
    updateSuitIcon(techName)
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
      if not showHungerMessage then
        showHungerMessage = root.assetJson("/betabound.config:showHunger")
      end
      interface.queueMessage(string.format(showHungerMessage, math.ceil(status.resource("food")).."/"..math.ceil(status.resourceMax("food"))), 4, 0.5)
    end
  end)
end

function updateSuitIcon(techName)
  if inventory then
    inventoryWidgets = inventory.toWidget()
  
    if techName then
      local techConfig = root.techConfig(techName)
      inventoryWidgets["setItemSlotItem"]("sb_techSuit", {"lead", 1, {
        inventoryIcon = techConfig.icon,
        tooltipKind = techConfig.tooltipKind or "sb_tech3",
        description = techConfig.description,
        shortdescription = "",
        category = ""
      }})
    else
      inventoryWidgets["setItemSlotItem"]("sb_techSuit")
    end

    if not inventoryWidgets["getData"]("sb_techSuit") then
      inventoryWidgets["setData"]("sb_techSuit", true)
      local cfg = root.assetJson("/interface/windowconfig/playerinventory.config:sb_techDisplay")
      if cfg.enabled then
        local hiddenWidgets = cfg.hiddenWidgets
        for i = 1, #hiddenWidgets do
          inventoryWidgets["setVisible"](hiddenWidgets[i], true)
        end

        local centeredOffset = root.assetJson("/interface/windowconfig/playerinventory.config:paneLayout.techHead.centered") and 0 or 8
        local head, body, legs, suit = inventoryWidgets["getPosition"]("techHead"), inventoryWidgets["getPosition"]("techBody"), inventoryWidgets["getPosition"]("techLegs"), inventoryWidgets["getPosition"]("sb_techSuit")
        local headD, bodyD, legsD = inventoryWidgets["getPosition"]("techHeadDisabled"), inventoryWidgets["getPosition"]("techBodyDisabled"), inventoryWidgets["getPosition"]("techLegsDisabled")
        --Hi there! Did you know that in vanilla, the 16x16 disabled icons are one pixel higher than the 16x16 tech icons they go over, and inventory mods have likely inherited this too? Now you do!
        --Eh? You checked and they're positioned properly? It's fixed in Patch Project if the Y position is the same as the vanilla inventory!

        if (head[1] < body[1] and head[2] == body[2]) and (body[1] < legs[1] and body[2] == legs[2]) then
          inventoryWidgets["setPosition"]("techBody", {head[1] + cfg.techBodyOffset, body[2]})
          inventoryWidgets["setPosition"]("techLegs", {head[1] + cfg.techLegsOffset, legs[2]})
          inventoryWidgets["setPosition"]("sb_techSuit", {head[1] + cfg.techSuitOffset[1] + centeredOffset, legs[2] + cfg.techSuitOffset[2] + centeredOffset})

          inventoryWidgets["setPosition"]("sb_techHeadBacking", {head[1] + centeredOffset, head[2] + centeredOffset})
          inventoryWidgets["setPosition"]("sb_techBodyBacking", {head[1] + cfg.techBodyOffset + centeredOffset, body[2] + centeredOffset})
          inventoryWidgets["setPosition"]("sb_techLegsBacking", {head[1] + cfg.techLegsOffset + centeredOffset, legs[2] + centeredOffset})

          inventoryWidgets["setPosition"]("techBodyDisabled", {head[1] + cfg.techBodyDisabledOffset, bodyD[2]})
          inventoryWidgets["setPosition"]("techLegsDisabled", {head[1] + cfg.techLegsDisabledOffset, legsD[2]})
        end
      else
        updateSuitIcon = function() end
      end
    end
  end
end