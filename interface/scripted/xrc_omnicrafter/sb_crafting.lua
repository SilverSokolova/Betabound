local originalOpenPane = openPane or function() end

function openPane(_, config); originalOpenPane(_, config)
  if stages[config.itemName] then
    for i = 1, stages[config.itemName] do
      local scandata = config.upgradeStages[i].sb_scanObjectsOnInteract
      if scandata then
        for j = 1, #scandata do
          world.sendEntityMessage(player.id(), "sb_addScandata", scandata[j], true)
        end
      end
    end
  end
end