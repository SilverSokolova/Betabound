require "/scripts/sb_assetmissing.lua"
function init() script.setUpdateDelta(20) end
function update(dt)
  local beamaxe = player.essentialItem("beamaxe")
  if beamaxe then
    local itemConfig = root.itemConfig(beamaxe.name).config
    local durability = itemConfig["durability"] or 4
    if ((beamaxe.parameters["durabilityHit"] or 2) >= durability-1) then --eject it even if can be blunted so they can repair it without an MM
      player.giveItem(beamaxe)
      player.giveEssentialItem("beamaxe",{name="sb_empty",parameters={upgrades=beamaxe.parameters.upgrades or {}}})
    elseif beamaxe.count == 0 then
      player.giveEssentialItem("beamaxe",{name="sb_empty",parameters={upgrades=beamaxe.parameters.upgrades or {}}})
    end
  end

  local swapSlotItem = player.swapSlotItem()
  if swapSlotItem and root.itemType(swapSlotItem.name) == "blueprint" then
    local s = swapSlotItem.name
    if s:sub(s:len()-6) == "-recipe" and not s:find("-codex") then
      local f = s:sub(0,s:len()-7)
      local recipe = root.itemConfig(f.."-recipe")
      local s = swapSlotItem; swapSlotItem = nil
      s.name = "sb_blueprint"
      s.parameters = {
        sb_recipe = recipe.config.recipe,
        price = (recipe.config.price or root.assetJson("/items/defaultParameters.config:defaultPrice")) * root.assetJson("/items/defaultParameters.config:blueprintPriceFactor") or 0.5,
        shortdescription = recipe.config.shortdescription or "Blueprint",
        description = recipe.config.description or "Used for crafting.",
        rarity = recipe.config.rarity or "uncommon",
        inventoryIcon = jarray()
      }

      if type(recipe.config.inventoryIcon) == "table" then
        for i = 1, #recipe.config.inventoryIcon do
          table.insert(s.parameters.inventoryIcon, {
            image = sb_assetmissing(sb_pathToImage(recipe.config.inventoryIcon[i].image, recipe.directory),
            root.assetJson("/items/defaultParameters.config:missingIcon") or "/objects/generic/perfectlygenericitem/perfectlygenericitemicon.png")
          })
        end
      else
        table.insert(s.parameters.inventoryIcon, {
          image = sb_assetmissing(sb_pathToImage(recipe.config.inventoryIcon, recipe.directory),
          root.assetJson("/items/defaultParameters.config:missingIcon") or "/objects/generic/perfectlygenericitem/perfectlygenericitemicon.png")
        })
      end

      table.insert(s.parameters.inventoryIcon, {position = {5.5,-4}, image = "/items/generic/unlock/sb_blueprints.png:"..string.lower(s.parameters.rarity)})
      player.setSwapSlotItem(s)
    end
  end
end