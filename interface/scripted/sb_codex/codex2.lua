require "/scripts/sb_assetmissing.lua"
--[[
TODO
  * only accept valid items
  * swap to longContentPages when needed
  * do promises to repopulate
  * for SHPD, lectern interact actions in the item?
  * test ABC books
]]
--[[
  Valid secdonaryData types:
    none
    codex (shows page count)
    long (scrolling)
]]
function init()
  entityId = pane.containerEntityId()

  missingImage = "/interface/sb_tooltips/assetmissing.png"
	itemList = "modeStack.itemList"
  secondaryData = "none"
  inactiveSecondaryData = "none"
  currentPage = 1
  pageCount = 1

	modeWidgets = config.getParameter("modeWidgets")
	invalidCodexText = config.getParameter("invalidCodexText")
  pageTextString = config.getParameter("pageNum", "%s/%s")
  acceptedTags = config.getParameter("acceptedItemTags")
  reading = false
  renaming = false

	widget.registerMemberCallback("modeStack.itemList", "readEntry", readEntry)
  populateList()
end

function update()
	if promise and promise:finished() then
    promise = nil
    populateList()
  end
  local item = world.containerItemAt(entityId, 0)
  if item then
    local itemData = root.itemConfig(item)
    local category = string.lower(itemData.parameters and itemData.parameters.category or itemData.config.category or "")
    if (itemHasTags(itemData.config.itemName, acceptedTags)
      or (itemData.parameters.interactData and itemData.parameters.interactAction)
      or category == "codex"
      or category == "blueprint")
      and not item.name:find("%-recipe")
    then
      world.containerTakeAt(entityId, 0)
      promise = world.sendEntityMessage(entityId, "sb_lectern:add", item)
    end
  end

	widget.setButtonEnabled("btnTake", widget.getListSelected(itemList) ~= nil)
end

function itemHasTags(item, tags)
  for i = 1, #tags do
    if root.itemHasTag(item, tags[i]) then
      return true
    end
  end
  return false
end

function populateList()
  items = world.getObjectParameter(entityId, "items") or {}
	widget.clearListItems(itemList)
  --DO NOT TRY TO SORT WITH SHORTDESC IT IS FUCKING CURSED
  --"invalid sort order" NO IT IS NOT
  table.sort(items, function(a, b) return a.name < b.name end)
  for i = 1, #items do
    local valid = false
    if sb_itemExists(items[i].name) then
      inactiveSecondaryData = "none"
      local item = root.itemConfig(items[i])
      if root.itemType(item.config.itemName) == "codex" then
        originalItem = item
        local codexData = readCodex(item)
        item.config.contentPages = codexData.contentPages
        item.config.inventoryIcon = codexData.icon or item.config.codexIcon
      end
      if configParameter(item, "contentPages") then
        inactiveSecondaryData = "codex"
      end
      if configParameter(item, "interactData") and configParameter(item, "interactAction") then
        inactiveSecondaryData = "interact"
      end

      local listItem = widget.addListItem(itemList)
      listItem = itemList.."."..listItem
      widget.setText(listItem..".bookName", configParameter(item, "shortdescription"))
      widget.setData(listItem, {configParameters(item, {{configParameter("interactData"), configParameter("interactAction")}, "noteText", "contentPages", "description"}), inactiveSecondaryData, originalItem or item})
      widget.setImage(listItem..".newIcon", item.config.itemName == "sb_blueprint" and "/items/generated/blueprintinhand.png" or sb_assetmissing(sb_pathToImage(configParameter(item, "inventoryIcon"), item.directory)), missingImage)
    else
      sb.logInfo("[Betabound] Could not instiantiate item for lectern: "..items[i].name)
    end
    originalItem = nil
  end
end

function readCodex(item)
  item = item.directory..""..item.config.codexId..".codex"
  local valid = pcall(function() root.assetJson(item) end)
  if valid then
    item = root.assetJson(item)
    inactiveSecondaryData = "codex"
    if item.longContentPages then
      inactiveSecondaryData = "long"
    end
    return item
  else
    return {codexIcon = missingImage, contentPages = string.format(invalidCodexText, item)}
  end
end

function readEntry()
	widget.setText("pageText", "")
  local data = widget.getData(string.format("%s.%s", itemList, widget.getListSelected(itemList)))
  contentPages = data[1]
  secondaryData = data[2]
  toggleWidgets()

  if type(contentPages) == "table" and type(contentPages[1]) == "table" then
    local newContentPages = {}
    for i = 1, #contentPages do
      for j = 1, 18 do
        newContentPages[i] = (newContentPages[i] or "")..contentPages[i][j].."\n"
      end
    end
    contentPages = newContentPages
  end

  if secondaryData == "codex" then
    currentPage = 1
    pageCount = #contentPages
  end
  turnPage(_, 0)
end

function turnPage(_, n)
  currentPage = currentPage + n
	widget.setText("pageText", type(contentPages) == "table" and contentPages[currentPage] or contentPages)
  
  if secondaryData == "codex" then
    widget.setText("pageNum", string.format(pageTextString, currentPage, pageCount))
    widget.setButtonEnabled("btnNext", currentPage < pageCount)
    widget.setButtonEnabled("btnPrevious", currentPage > 1)
  end
end

function btnBack()
  secondaryData = "none"
  toggleWidgets()
end

function btnRename()
  renaming = not renaming
  widget.setVisible("renameBox", renaming)
end

function renameBox()
  world.sendEntityMessage(entityId, "sb_lectern:rename", widget.getText("renameBox"))
end

function toggleWidgets()
  reading = not reading
	for i = 1, #modeWidgets[1] do widget.setVisible(modeWidgets[1][i], reading) end
	for i = 1, #modeWidgets[2] do widget.setVisible(modeWidgets[2][i], not reading) end
  widget.setVisible("longPageText", secondaryData == "long")
  widget.setVisible("renameBox", false)
  widget.setVisible("btnPrevious", secondaryData == "codex")
  widget.setVisible("btnNext", secondaryData == "codex")
end

function btnTake()
  promise = world.sendEntityMessage(entityId, "sb_lectern:remove", widget.getData(string.format("%s.%s", itemList, widget.getListSelected(itemList)))[3])
end

function configParameter(item, keyName, defaultValue) return item.parameters and item.parameters[keyName] or item.config and item.config[keyName] or defaultValue end
function configParameters(item, keyNames)
  local returnValue
  for i = 1, #keyNames do
    returnValue = item.parameters and item.parameters[keyNames[i]] or item.config[keyNames[i]]
    if returnValue then
      break
    end
  end
  return returnValue or ""
end