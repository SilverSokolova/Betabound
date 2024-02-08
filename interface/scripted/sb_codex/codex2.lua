require "/scripts/sb_assetmissing.lua"
  
function init()
  missingImage = "/interface/sb_tooltips/assetmissing.png"
  entityId = pane.containerEntityId()
	widget.registerMemberCallback("modeStack.bookList", "prepareBook", prepareBook)
	bookList = "modeStack.bookList"
  longContentPages = false
	invalidCodexText = config.getParameter("invalidCodexText")
  items = world.getObjectParameter(entityId, "items") or {}
  populateList()
end

function update()
  local item = world.containerItemAt(entityId, 0)
  if item then
    world.containerTakeAt(entityId, 0)
    world.sendEntityMessage(entityId, "sb_lectern:add", item)
  end

	widget.setButtonEnabled("takeButton", widget.getListSelected(bookList) ~= nil)
end

function populateList()
	widget.clearListItems(bookList)
  table.sort(items, function(a, b) return a.name < b.name end)
  for i = 1, #items do
    if sb_itemExists(items[i].name) then
      longContentPages = false
      local item = root.itemConfig(items[i])
      if root.itemType(item.config.itemName) == "codex" then
        local codexData = readCodex(item)
        item.config.contentPages = codexData.contentPages
        item.config.inventoryIcon = codexData.icon or item.config.codexIcon
        sb.logInfo(sb.print(item.config.inventoryIcon))
      end
      local listItem = widget.addListItem(bookList)
      listItem = bookList.."."..listItem
      widget.setText(listItem..".bookName", configParameter(item, "shortdescription"))
      widget.setData(listItem, {configParameters(item, {"noteText", "contentPages", "description"}), longContentPages or false})
      widget.setImage(listItem..".newIcon", sb_assetmissing(sb_pathToImage(configParameter(item, "inventoryIcon"), item.directory)), missingImage)
    else
      sb.logInfo("[Betabound] Could not instiantiate item for lectern: "..items[i].name)
    end
  end
end

function readCodex(item)
  item = item.directory..""..item.config.codexId..".codex"
  local valid = pcall(function() root.assetJson(item) end)
  if valid then
    item = root.assetJson(item)
    if item.longContentPages then
      longContentPages = true
    end
    return item
  else
    return {codexIcon=missingImage,contentPages=string.format(invalidCodexText, item)}
  end
end

function configParameter(item, keyName, defaultValue) return item.parameters and item.parameters[keyName] or item.config[keyName] or defaultValue end
function configParameters(item, keyNames)
  local returnValue
  for i = 1, #keyNames do
    returnValue = item.parameters and item.parameters[keyNames[i]] or item.config[keyNames[i]]
  end
  return returnValue or ""
end

function prepareBook() interface.queueMessage("what?? hello??") end