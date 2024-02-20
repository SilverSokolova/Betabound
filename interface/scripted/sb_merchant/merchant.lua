function init()
  tab = "buySellTabs.tabs.buy."
  itemList = tab.."scrollArea.itemList"
  lblBuyTotal = tab.."lblBuyTotal"
  tbCount = tab.."tbCount"
  btnBuy = tab.."btnBuy"

  id = pane.sourceEntity()
  widget.setButtonEnabled(btnBuy, false)
  widget.registerMemberCallback(itemList, "itemSelected", itemSelected)
  widget.setText(tbCount, "x0")
  widget.setText(lblBuyTotal, "0")

  buyFactor = config.getParameter("buyFactor", 1)
  itemQuantityText = config.getParameter("itemQuantityText")
  soldOutText = config.getParameter("soldOutText")
  buySound = config.getParameter("merchant.buySound")
  buyTotal = 0
  count = 0
  price = 0
  listedItems = {}
  selectedItem = nil
  selectedItemIndex = nil

  widget.clearListItems(itemList)
  local items = config.getParameter("items")
  for i = 1, #items do
    local itemConfig = root.itemConfig(items[i])
    itemConfig.name = itemConfig.config.itemName
    itemConfig.quantity = items[i].count or 1
    itemConfig.count = 1
    local listItem = widget.addListItem(itemList)

    local shortdescription = configParameter(itemConfig, "shortdescription", "Unnamed Item")
    widget.setText(string.format("%s.%s.itemName", itemList, listItem), shortdescription)
    local itemQuantity = itemConfig.quantity or 1
    widget.setText(string.format("%s.%s.sb_itemSubtitle", itemList, listItem), itemQuantity > 0 and string.format(itemQuantityText, itemQuantity) or soldOutText)

    local itemPrice = configParameter(itemConfig, "price", 0)
    itemPrice = itemPrice == 0 and 5 or itemPrice
    itemPrice = math.floor((itemPrice * itemConfig.count) * buyFactor)
    items[i].price = itemPrice
    widget.setText(string.format("%s.%s.priceLabel", itemList, listItem), itemPrice)

    items[i].order = i

    widget.setData(string.format("%s.%s", itemList, listItem), items[i])
    widget.setItemSlotItem(string.format("%s.%s.itemIcon", itemList, listItem), itemConfig)
    listedItems[#listedItems+1] = {
      id = listItem,
      price = itemPrice,
      shortdescription = shortdescription,
      inStock = itemQuantity > 0
    }
  end
  inited = true
end

function countChanged()
  local selectedItemCount = widget.getData(string.format("%s.%s", itemList, selectedItem)).count
  count = math.min(math.max(0, count), selectedItemCount)
  widget.setText(tbCount, "x"..count)
end

spinCount = {}
spinCount["up"] = function() incrementCount(1) end
spinCount["down"] = function() incrementCount(-1) end

function incrementCount(n)
  if hasItemSelected then
    if type(n) == "string" then
      n = n:gsub("x", "")
    end
    n = tonumber(n) or 1
    count = (count or 0) + n
    if count == 1001 then
      count = 1
    elseif count > 1001 then
      count = n == 1 and 1 or 1000
    elseif count < 1 then
      count = 1000
    end
    countChanged()
  end
end

function buy()
  if player.consumeCurrency("money", buyTotal) then
    world.sendEntityMessage(id, "itemPurchased", itemData, count)

    local data = widget.getData(string.format("%s.%s", itemList, selectedItem))
    data.count = data.count - count
    player.giveItem({data.name, count, data.parameters or {}})
    widget.setData(string.format("%s.%s", itemList, selectedItem), data)

    local inStock = data.count > 0
    widget.setText(string.format("%s.%s.sb_itemSubtitle", itemList, selectedItem), inStock and string.format(itemQuantityText, data.count) or soldOutText)
    listedItems[data.order].inStock = inStock
    widget.playSound(buySound)
    countChanged()
  end
end

function parseCountText()
  if not inited then return end
  local tb = widget.getText(tbCount)
  tb = string.gsub(tb, "x", "")
  if tb:len() == 0 then
    tb = 1
  end
  count = tonumber(tb)
  incrementCount(0)
  countChanged()
end

--The game needs these due to our inherited context
function sell() end
function tbCount() end
function itemGrid() end

function configParameter(item, keyName, defaultValue) return item.parameters and item.parameters[keyName] or item.config and item.config[keyName] or defaultValue end

function itemSelected()
  hasItemSelected = true
  selectedItem = widget.getListSelected(itemList)
  count = 1
  countChanged(0)
  itemData = widget.getData(string.format("%s.%s", itemList, selectedItem))
  selectedItemIndex = itemData.order
  price = itemData.price
end

function updatePrice()
  buyTotal = price * count
  widget.setText(lblBuyTotal, buyTotal)
end

function update()
  money = player.currency("money")
  for i = 1, #listedItems do
    widget.setVisible(string.format("%s.%s.unavailableoverlay", itemList, listedItems[i].id), not ((listedItems[i].inStock and money > listedItems[i].price) or false))
    if listedItems[i].id == selectedItem then
      widget.setButtonEnabled(btnBuy, (listedItems[i].inStock and money >= listedItems[i].price * (count == 0 and 1 or count)) or false)
    end
  end
  updatePrice()
end

function uninit()
  world.sendEntityMessage(id, "toggleInteractable")
end