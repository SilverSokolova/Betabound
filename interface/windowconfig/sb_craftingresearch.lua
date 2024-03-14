function init()
  recipes = config.getParameter("recipes")
  table.sort(recipes, function(a, b) return root.itemConfig(a.output).config.shortdescription < root.itemConfig(b.output).config.shortdescription end)
  ownedIcon = config.getParameter("ownedIcon")
  subtitles = root.assetJson("/items/categories.config:labels")
  iconUnderlay = root.assetJson("/blueprint.config").iconUnderlay.image
  itemList, query, lastQuery, category, selectedItem = "scrollArea.itemList", nil, nil, "all", nil --(config.getParameter("gui").categories.buttons)[1].data
  newIconOffset = (root.imageSize(root.assetJson("/interface/windowconfig/sb_craftingresearch.config").gui.scrollArea.children.itemList.schema.listTemplate.newIcon.file)[1] - root.imageSize(ownedIcon)[1])/2.5
  populateList()
end

function update(dt)
  widget.setText("lblPlayerMoney",tostring(player.currency("money")))
  widget.setButtonEnabled("btnCraft", selectedItem and hasItems())
  if (query ~= lastQuery) then populateList(category) end
  lastQuery = query
end

function populateList() --We've already checked if the item exists
  widget.clearListItems(itemList)
  local showAll = category == "all"
  for i = 1, #recipes do
    local recipe = recipes[i]
    local output = root.itemConfig(recipe.output).config
    local shortdescription = output.shortdescription or "Unnamed Item"
    if (showAll or recipe.groups[1] == category) and ((not query and true) or (query and shortdescription:lower():find(query))) then
      local listItem = widget.addListItem(itemList); listItem = string.format("%s.%s", itemList, listItem)
      widget.setText(listItem..".itemName", shortdescription)
      widget.setItemSlotItem(listItem..".itemIcon", output.itemName)
      widget.setText(listItem..".priceLabel", recipe.input[2][2])
      widget.setData(listItem, {output.itemName, recipe.input[2]})
      local recipeData = root.recipesForItem(output.itemName:sub(1,-8))[1].output
      if player.blueprintKnown({recipeData.name, recipeData.count, recipeData.parameters}) then --recipesForItem for recipes with parameters, ie frost spear
        local newIcon = listItem..".newIcon"
        local oldPos = widget.getPosition(newIcon)
        widget.setImage(newIcon, ownedIcon)
        widget.setPosition(newIcon, {oldPos[1]+(newIconOffset),oldPos[2]})
      end
    end
  end
end

function searchBar()
  query = widget.getText("searchBar"):lower()
end

function craft()
  if selectedItem and hasItems() then
    if not player.isAdmin() then
      player.consumeItem("sb_blankblueprint")
      player.consumeCurrency("money", selectedItem[2][2])
    end
    player.giveItem(selectedItem[1])
  end
end

function hasItems()
  if player.isAdmin() then return true end
  return player.hasItem("sb_blankblueprint") and player.currency("money") > selectedItem[2][2]
end

function itemSelected()
  local listItem = widget.getListSelected(itemList)
  if listItem then
    selectedItem = widget.getData(itemList.."."..listItem)
    local item = root.itemConfig(selectedItem[1]); local directory = item.directory; item = sb.jsonMerge(item.config,item.parameters)
    widget.setText("description", item.description or "This item needs to have a description set.")
    widget.setText("shortdescription", item.shortdescription or "Unnamed Item")
    local category = item.category or "other"; widget.setText("itemSubtitle", "^gray;"..(subtitles[item.category] or item.category))
    widget.setImage("objectImage", formatIcon(item.inventoryIcon, directory))
    widget.setItemSlotItem("currentRecipeIconInput2",selectedItem[2])
    widget.setItemSlotItem("currentRecipeIconOutput1",selectedItem[1])
    widget.setItemSlotItem("currentRecipeIconOutput2",{selectedItem[1],1,{tooltipKind="simpletooltip"}})
    local recipeData = root.recipesForItem(selectedItem[1]:sub(1,-8))[1].output
    widget.setItemSlotItem("currentRecipeIconOutput3",{recipeData.name, 1, recipeData.parameters})

    if not selectedAnything then
      widget.setImage("objectUnderlay", iconUnderlay)
      widget.setItemSlotItem("currentRecipeIconInput1","sb_blankblueprint")
      widget.setVisible("currentRecipeIconOutput2", true)
      widget.setVisible("currentRecipeIconOutput3", true)
      widget.setVisible("lblInput", true)
      widget.setVisible("lblOutput", true)
      widget.setVisible("lblDetails", true)
      selectedAnything = true
    end
  end
end

function formatIcon(icon, directory)
  if type(icon) ~= "string" then return (#icon == 1 and formatIcon(icon[1].image, directory) or "/items/generated/blueprintinhand.png") end
  return string.sub(icon, 1, 1) == "/" and icon or directory..icon
end

function categories(_, index)
  category = category == index and "all" or index
  populateList()
end