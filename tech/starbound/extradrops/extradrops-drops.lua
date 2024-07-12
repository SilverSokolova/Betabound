function init()
  entityTypeName = world.entityTypeName(entity.id())
  if world.entityHealth(entity.id())[2] < config.getParameter("minimumHealth", 3.5) or not entityTypeName then
    effect.expire()
    return
  end
  treasurePool = config.getParameter("treasurePool", entityTypeName.."Treasure")
  treasurePool = root.isTreasurePool(treasurePool) and treasurePool or findTreasurePool()
  rolls = config.getParameter("rolls", 2)
  weight = config.getParameter("weight", 40)
  level = math.max(1, world.threatLevel())
end

function uninit()
  --You can kill Small Po from a larger po with a flamethrower before they're fully initialized, which specifically breaks world.entityHealth but not world.entityExists?
  --But world.entityHealth doesn't seem to work in uninit anyway, so we can only check for a value set in init
  if not rolls then
    return
  end

  if not status.resourcePositive("health") then
    for i = 1, rolls do
      if math.random(100) <= weight then
        local items = root.createTreasure(treasurePool, level)
        if #items > 0 then
          world.spawnItem(items[math.random(#items)], entity.position())
        end
      end
    end
    effect.expire()
  end
end

function findTreasurePool()
  local treasurePool = world.entityType(entity.id()) == "npc" and root.npcConfig(entityTypeName).dropPools
  if treasurePool then
    if #treasurePool > 0 then
      treasurePool = treasurePool[math.random(#treasurePool)]
    else
      treasurePool = "empty" 
    end
  else
    treasurePool = entityTypeName.."treasure" --Check for treasure but with a lowercase 'T'
  end
  return (treasurePool and root.isTreasurePool(treasurePool) and treasurePool) or config.getParameter("defaultTreasurePool")
end