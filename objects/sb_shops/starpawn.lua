require("/scripts/util.lua")
local ini = init or function() end
function init()
  ini()
  interactable = interactable or true
  shopInUseText = config.getParameter("shopInUseText")
  interactAction = config.getParameter("interactAction")
  local rotationTime = config.getParameter("rotationTime")
  
  seed = math.floor(os.time() / rotationTime+1)
  local lastSeed = config.getParameter("lastSeed", "")
  if lastSeed ~= seed then
    items = createItemList(config.getParameter("pools"))
    object.setConfigParameter("items", items)
    object.setConfigParameter("lastSeed", seed)
  else
    items = config.getParameter("items")
  end

  message.setHandler("itemPurchased", function(_, _, data)
    sb.logInfo(sb.print(data))
    items[data.order].count = items[data.order].count - 1
    object.setConfigParameter("items", items)
  end)

  message.setHandler("toggleInteractable", function()
    interactable = not interactable
  end)
end

function createItemList(pools)
  local newItems = {}
  for i = 1, #pools do
    local draw = root.createTreasure(pools[i], world.threatLevel(), seed)
    for k, v in pairs(draw) do
      if root.itemType(v.name) ~= "currency" then
        --sb.logInfo(sb.printJson(v))
        local stackedItem = false
        for k2, v2 in pairs(newItems) do
          if root.itemDescriptorsMatch(v2, v, true) then
            newItems[k2].count = newItems[k2].count + v.count
            stackedItem = true
          end
        end
        if not stackedItem then
          newItems[#newItems+1] = v
        end
      end
    end
  end
  --sb.logInfo(sb.printJson(newItems, 1))
  return newItems
end

function onInteraction(args)
  if not interactData then
    interactData = config.getParameter("interactData")
    interactConfigs = interactData.config
    interactData = sb.jsonMerge(root.assetJson(interactConfigs[1]), interactData)
    local merchant = root.assetJson(interactConfigs[2])
    merchant.paneLayout.buySellTabs.tabs[1].children.scrollArea.children.itemList.callback = "itemSelected"
    merchant.paneLayout.buySellTabs.tabs[1].children.scrollArea.children.itemList.schema.listTemplate.unavailableoverlay.mouseTransparent = true
    local subtitle = copy(merchant.paneLayout.buySellTabs.tabs[1].children.scrollArea.children.itemList.schema.listTemplate.itemName)
    subtitle.position[2] = subtitle.position[2] / 2
    merchant.paneLayout.buySellTabs.tabs[1].children.scrollArea.children.itemList.schema.listTemplate.sb_itemSubtitle = subtitle
    interactData.gui = sb.jsonMerge(merchant.paneLayout, interactData.paneLayoutOverride)
    interactData.items = items

    merchant = root.assetJson("/merchant.config")
    interactData.merchant = {
      buySound = merchant.buySound,
      sellSound = merchant.sellSound
    }
  end
  --sb.logInfo(sb.printJson(interactData, 1))
  if interactable then
    return {interactAction, interactData}
  else
    object.say(shopInUseText)
  end
end

--[[
function onInteraction(args)
  if not interactData then
    interactData = config.getParameter("interactData")
    interactData = sb.jsonMerge(interactData, root.assetJson(interactData["config"][1]))
    --local paneLayoutOverride = interactData.paneLayoutOverride
  --merchant.paneLayout.buySellTabs[2] = nil
    interactData.gui = {background=root.assetJson(interactData["config"][2]).paneLayout.background} --sb.jsonMerge(root.assetJson(interactData["config"][2]).paneLayout, paneLayoutOverride)
    --interactData.paneLayoutOverride = nil
    --interactData.config = nil
  end
  sb.logInfo(sb.printJson(interactData, 1))
  return {interactData, interactData}
end
]]