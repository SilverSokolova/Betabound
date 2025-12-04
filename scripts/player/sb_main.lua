require "/scripts/sb_assetmissing.lua"

function init()
  math.betabound_player = _ENV.player
  mcontroller = math.betabound_mcontroller
  sb_techType()

  --Suit tech icon, and equip/unequip handlers
  --If this check isn't passing on oSB, whatever is setting it before we get here (status script?) probably isn't, so move that check here.
  if math.betabound_client == "OpenSB" then
    inventory = interface.bindRegisteredPane("Inventory")
    updateSuitIcon(player.getProperty("sb_equippedSuitTech"))
  else
    updateSuitIcon = function() end
  end

  --Suit tech functions
  message.setHandler("sb_suitTech:enable", function(_, fromSelf, tech)
    if not fromSelf then return end

    local shouldAddTech = true
    local suits = player.getProperty("sb_enabledSuitTechs")

    if #suits == 0 then
      player.setProperty("sb_enabledSuitTechs", {tech}) --Prevent it from becoming a keyed table
    else
      for i = 1, #suits do
        if suits[i] == tech then
          shouldAddTech = false
          break
        end
      end

      if shouldAddTech then
        suits[#suits + 1] = tech
        player.setProperty("sb_enabledSuitTechs", suits)
      end
    end
  end)

  message.setHandler("sb_suitTech:makeAvailable", function(_, fromSelf, tech)
    if not fromSelf then return end

    local shouldAddTech = true
    local suits = player.getProperty("sb_availableSuitTechs")

    if #suits == 0 then
      player.setProperty("sb_availableSuitTechs", {tech}) --Prevent it from becoming a keyed table
    else
      for i = 1, #suits do
        if suits[i] == tech then
          shouldAddTech = false
          break
        end
      end

      if shouldAddTech then
        suits[#suits + 1] = tech
        player.setProperty("sb_availableSuitTechs", suits)
      end
    end
  end)

  --Pass a string to equip, pass null to unequip
  message.setHandler("sb_suitTech:equip", function(_, fromSelf, tech)
    if not fromSelf then return end

    status.clearPersistentEffects("sb_equippedSuitTech")
    if tech then
      if root.hasTech(tech) then
        local effects = root.techConfig(tech).sb_effect or {} --god i really wanna rename it to sb_effects PLURAL for consistency with consumables
        status.setPersistentEffects("sb_equippedSuitTech", type(effects) == "string" and {effects} or effects)
        player.setProperty("sb_equippedSuitTech", tech)
      end
    else
      status.clearPersistentEffects("sb_equippedSuitTech")
      player.setProperty("sb_equippedSuitTech")
    end
    updateSuitIcon(tech)
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

  --SE/oSB commands
  message.setHandler("/sb_enabletech", function(_, fromSelf, tech)
    if fromSelf == false or type(tech) ~= "string" then return end

    if not root.hasTech(tech) then
      return "No such tech " .. tech
    end

    if root.techType(tech) == "Suit" then
      player.interact("message", {messageType = "sb_suitTech:enable", messageArgs = {tech}})
    else
      player.makeTechAvailable(tech)
      player.enableTech(tech)
    end

    return "Player tech " .. tech .. " enabled"
  end)

  message.setHandler("/sb_maketechavailable", function(_, fromSelf, tech)
    if fromSelf == false or type(tech) ~= "string" then return end

    if not root.hasTech(tech) then
      return "No such tech " .. tech
    end

    if root.techType(tech) == "Suit" then
      player.interact("message", {messageType = "sb_suitTech:makeAvailable", messageArgs = {tech}})
    else
      player.makeTechAvailable(tech)
    end

    return "Added " .. tech .. " to player's visible techs"
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
        tooltipKind = "sb_tech3",
        description = techConfig.description,
        shortdescription = "",
        category = "" --^white;" .. techConfig.shortDescription
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

        if (head[1] < body[1] and head[2] == body[2]) and (body[1] < legs[1] and body[2] == legs[2]) then
          inventoryWidgets["setPosition"]("techBody", {head[1] + cfg.techBodyOffset, body[2]})
          inventoryWidgets["setPosition"]("techLegs", {head[1] + cfg.techLegsOffset, legs[2]})
          inventoryWidgets["setPosition"]("sb_techSuit", {head[1] + cfg.techSuitOffset[1] + centeredOffset, legs[2] + cfg.techSuitOffset[2] + centeredOffset})

          inventoryWidgets["setPosition"]("sb_techHeadBacking", {head[1] + centeredOffset, head[2] + centeredOffset})
          inventoryWidgets["setPosition"]("sb_techBodyBacking", {head[1] + cfg.techBodyOffset + centeredOffset, body[2] + centeredOffset})
          inventoryWidgets["setPosition"]("sb_techLegsBacking", {head[1] + cfg.techLegsOffset + centeredOffset, legs[2] + centeredOffset})

          --Hi there! Did you know that in vanilla, the 16x16 disabled icons are one pixel higher than the 16x16 tech icons they go over, and inventory mods have likely inherited this too? Now you do!
          --The reason we check for the difference between the UI elements is to fix this if it isn't already fixed by another mod.
          inventoryWidgets["setPosition"]("techHeadDisabled", {headD[1], headD[2] - (head[2] - headD[2] == 8 and 1 or 0)})
          inventoryWidgets["setPosition"]("techBodyDisabled", {head[1] + cfg.techBodyDisabledOffset, bodyD[2] - (body[2] - bodyD[2] == 8 and 1 or 0)})
          inventoryWidgets["setPosition"]("techLegsDisabled", {head[1] + cfg.techLegsDisabledOffset, legsD[2] - (legs[2] - legsD[2] == 8 and 1 or 0)})
        end
      else
        updateSuitIcon = function() end
      end
    end
  end
end