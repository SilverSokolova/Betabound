local originalOpenPane = openPane or function() end

function openPane(_, config); originalOpenPane(_, config)
  if stages[config.itemName] then
    for i = 1, stages[config.itemName] do
      local scandata = config.upgradeStages[i].sb_scanObjectsOnInteract
      if scandata then
        for j = 1, #scandata do
          player.interact("message", {messageType = "sb_addScandata", messageArgs = {scandata[j], true}})
        end
      end
    end
  end
end