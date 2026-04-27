--TODO: animated new indicator for which items were changed? already have code in beta hotbar
function init()
  sb_itemboxDescription = root.itemConfig("sb_itembox").config.description .. config.getParameter("desc")
  sb_entityId = pane.containerEntityId()
  sb_lastAugment = nil

  config.originalGetParameter = config.getParameter
  config.getParameter = function(value, default)
    return sb_augment.parameters[value] or sb_augment.config[value] or default
  end
end

function sb_clear()
  local contents = world.containerItems(sb_entityId)
  for k, v in pairs(contents) do
    if k ~= 1 then
      player.giveItem(v)
      world.containerConsumeAt(sb_entityId, k - 1, v.count)
    end
  end
end

function sb_wrap()
  local contents = world.containerItems(sb_entityId) --The one unprefixed variable I get to have in my own home
  sb_augment = world.containerItemAt(sb_entityId, 0)

  if sb_augment and root.itemType(sb_augment.name) == "augmentitem" then
    --Close UI to reset required scripts. But do we really need to? Maybe to avoid some hooking schenanigans
    if sb_lastAugment then
      if sb_lastAugment ~= sb_augment.name then
        pane.dismiss()
        return
      end
    end
    sb_lastAugment = sb_augment.name

    if sb_augment.name == "sb_wrappingpaper" then
      sb_wrapItems(contents)
    else
      sb_applyAugments(contents)
    end
  end
end

function sb_wrapItems(contents)
  local items = {}

  for k, v in pairs(contents) do
    if v.name ~= "sb_itembox" and v.name ~= "sb_wrappingpaper" then
      world.containerConsumeAt(sb_entityId, k - 1, v.count)
      items[#items+1] = contents[k]
    end
  end

  if #items > 0 then
    world.containerConsumeAt(sb_entityId, 0, player.isAdmin() and 0 or 1)
    local params = {items = items}
    if #items > 1 then
      params.description = string.format(sb_itemboxDescription, #items)
    end
    player.giveItem({"sb_itembox", 1, params})
  end
end

function sb_applyAugments(contents)
  sb_augment.config = root.itemConfig(sb_augment.name).config

  local scripts = sb_augment.parameters.scripts or sb_augment.config.scripts
  for i = 1, #scripts do
    require(scripts[i])
  end

  for k, v in pairs(contents) do
    if k ~= 1 and sb_augment.count > 0 then
      output, c = apply(v)
      if output then
        world.containerConsumeAt(sb_entityId, k - 1, v.count)
        c = c or 1
        --world.containerPutItemsAt(sb_entityId, output, k-1) --TODO: is it because of the slotOffset.
        world.containerAddItems(sb_entityId, output)
        sb_augment.count = sb_augment.count - c
        world.containerConsumeAt(sb_entityId, 0, player.isAdmin() and 0 or c)
      end
    end
  end
end