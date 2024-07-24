local originalInit = init or function() end
function init() originalInit()
  world.sb_entityHasCountOfItem = world.entityHasCountOfItem
  world.entityHasCountOfItem = function(entityId, itemDescriptor, exactMatch)
    return itemDescriptor == "solidfuel" and
    world.sb_entityHasCountOfItem(entityId, itemDescriptor, exactMatch) +
    world.sb_entityHasCountOfItem(entityId, "supermatter", false) or
    world.sb_entityHasCountOfItem(entityId, itemDescriptor, exactMatch)
  end
end