require "/scripts/util.lua"

function init()
  local oldData = config.getParameter("sb_codex")
  if oldData then
    local size = 0
    local newItems = {}
    for k, v in pairs(oldData) do
      size = size + 1
      local newItem = {}
      newItem.name = v[1]
      newItem.count = v[2]
      if v[3] then newItem.parameters = v[3] end
      if size == 1 then
        newItems = {newItem}
      else
        newItems[#newItems+1] = newItem
      end
    end
    if size >= 1 then
      object.setConfigParameter("items", newItems)
      object.setConfigParameter("sb_codex", nil)
    end
  end
  id = entity.id()
  items = config.getParameter("items", {})
  
  message.setHandler("sb_lectern:rename", function(_, _, name)
    name = string.gsub(name, "(%^.-%;)", "")
    if string.gsub(name, "(% )", "") == "" then
      name = root.itemConfig(object.name()).config.shortdescription or "Lectern"
    end
    object.setConfigParameter("shortdescription", "^orange;"..name.."^reset;")
  end)
  
  message.setHandler("sb_lectern:add", function(_, _, item)
    local hasItems = false
    local addedItem = false
    for k, v in pairs(items) do
      hasItems = true
      if root.itemDescriptorsMatch(item, v, true) then
        addedItem = true
        items[k].count = items[k].count + item.count
        saveItems()
        break
      end
    end

    if not addedItem then
      if hasItems then
        items[#items+1] = item
        saveItems()
      else
        items = {item}
        saveItems()
      end
    end
  end)

  message.setHandler("sb_lectern:remove", function(_, _, item)
    if not item.name then
      item.name = item.config.itemName --god forbid anything be consistent anywhere ever
    end
    local hasItems = false
    local count = 0
    local itemIndexToRemove
    local itemToRemove
    local newItems = {}
    for k, v in pairs(items) do
      hasItems = true
      if root.itemDescriptorsMatch(item, v, true) then
        itemToRemove = v
        itemIndexToRemove = k
      else
        if count == 0 then
          newItems = {v}
        else
          newItems[#newItems+1] = v
        end
        count = count + 1
      end
    end
    if itemToRemove then
      items = newItems
      local itemData = root.itemConfig(itemToRemove)
      local maxStack = itemData.parameters and itemData.parameters.maxStack or itemData.config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack")
      local stackSize = itemToRemove.count
      if stackSize > maxStack then
      --TODO: pass it to a function also make it actually give 1500 if maxstack is 1000 and they have 1500
        while stackSize > maxStack do
          stackSize = stackSize - maxStack
          world.spawnItem({name = itemToRemove.name, count = maxStack, parameters = itemToRemove.parameters, config = itemToRemove.config}, world.entityPosition(id))
        end
        stackSize = stackSize - maxStack
        world.spawnItem({name = itemToRemove.name, count = maxStack, parameters = itemToRemove.parameters, config = itemToRemove.config}, world.entityPosition(id))
      else
        world.spawnItem(itemToRemove, world.entityPosition(id))
      end
      saveItems()
    end
  end)

  message.setHandler("xrc_omnicrafter:add", function(_,_,a,b)
    if not contains(stations, a) then
      if #stations == 0 then
        stations = {a}
      else
        stations[#stations+1] = a
      end
    end
    if b then stages[a] = b end
    object.setConfigParameter("stations", stations)
    object.setConfigParameter("stages", stages)
    markAsUsed()
  end)
 
  message.setHandler("xrc_omnicrafter:remove", function(_,_,a)
    local b, c = stations, {}
    for i = 1, #b do
      if b[i] ~= a then c[#c+1] = b[i] end
    end
    if stages[a] then
      stages[a] = nil
      object.setConfigParameter("stages", stages)
    end
    object.setConfigParameter("stations", c)
    markAsUsed()
  end)
end

function onInEteraction(args)
  local data = root.assetJson(config.getParameter("interactData"))
  data.stages = stages or {}
  data.stations = stations or {}
  data.id = id
  return {config.getParameter("interactAction"),data}
end

function saveItems(item)
  object.setConfigParameter("items", items)

  --We have to use an if statement here because I don't want to set a parameter on a blank lectern because that would prevent it from stacking with other virgins
  if #items > 0 then
    object.setConfigParameter("rarity", "rare")
  else
    local rarity = config.getParameter("rarity")
    if rarity:upper() ~= rarity then
      object.setConfigParameter("rarity", "uncommon") --If you change this, the first letter needs to be lowercase
    end
  end
end