local originalUninit = uninit or function() end

function uninit()
  if status.isResource("health") and status.resource("health") <= 0 then
    world.spawnItem({"sb_candycane", 1, {level = world.threatLevel()}}, entity.position())
    local pools = {monster.type() == "giftmonster" and "giftMonsterBoxTreasure" or "smallGiftMonsterBoxTreasure", "money"}
    for n = 1, #pools do
      if root.isTreasurePool(pools[n]) then
        local loot = root.createTreasure(pools[n], world.threatLevel())
        for i = 1, #loot do world.spawnItem(loot[i], entity.position()) end
      end
    end
  end
  originalUninit()
end