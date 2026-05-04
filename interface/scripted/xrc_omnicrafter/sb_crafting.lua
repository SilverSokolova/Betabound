local originalOpenPane = openPane or function() end

function openPane(_, config); originalOpenPane(_, config)
  local scandata = config.sb_scanObjectsOnInteract

  if stages[config.itemName] and not scandata then
    for i = 1, stages[config.itemName] do
      scandata = config.upgradeStages[i].sb_scanObjectsOnInteract
      if scandata then
        for j = 1, #scandata do
          world.sendEntityMessage(player.id(), "sb_addScandata", scandata[j], true)
        end
      end
    end
  elseif scandata then
    for j = 1, #scandata do
      world.sendEntityMessage(player.id(), "sb_addScandata", scandata[j], true)
    end
  end
end