require("/scripts/util.lua") --Provides `copy` function
local originalInit = init or function() end
function init()
  originalInit()
  interactable = interactable or true
  object.setConfigParameter("mouthPosition", config.getParameter("mouthPositions")[direction == "right" and 1 or 2])
  shopInUseText = config.getParameter("shopInUseText")
  animator.setSoundPool("speech", config.getParameter("speechSoundPool"))
  interactAction = config.getParameter("interactAction")
  local rotationTime = config.getParameter("rotationTime")
  
  seed = math.floor(os.time() / rotationTime)
  local lastSeed = config.getParameter("lastSeed", "")
  if lastSeed ~= seed then
    items = createItemList(config.getParameter("pools"))
    object.setConfigParameter("items", items)
    object.setConfigParameter("lastSeed", seed)
  else
    items = config.getParameter("items")
  end

  message.setHandler("itemPurchased", function(_, _, data, count)
    items[data.order].count = items[data.order].count - count
    object.setConfigParameter("items", items)
  end)

  message.setHandler("toggleInteractable", function(_, _, id)
    interactable = id and id or true
  end)
end

function createItemList(pools)
  local poolRounds = config.getParameter("poolRounds", 1)
  local newItems = {}
  for i = 1, poolRounds do
    for j = 1, #pools do
      local draw = root.createTreasure(pools[j], world.threatLevel(), seed * (math.random(5834) * j))
      for k, v in pairs(draw) do
        if root.itemType(v.name) ~= "currency" then
          local stackedItem = false
          v.count = math.random(v.count)
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
  end
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
  if interactable == true then
    return setInteractable(args.sourceId) and {interactAction, interactData}
  else
    if interactable ~= args.sourceId then
      object.say(shopInUseText)
      animator.playSound("speech")
    end
  end
end

function setInteractable(sourceId)
  interactable = sourceId
  return true
end