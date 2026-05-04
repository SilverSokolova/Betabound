local originalInit = init or function() end
local originalUpdateStageData = updateStageData or function() end

local originalOnInteraction = onInteraction or function(args)
  return {config.getParameter("interactAction"), config.getParameter("interactData")}
end

function init(); originalInit()
  sb_scanObjectsOnInteract = config.getParameter("sb_scanObjectsOnInteract")
end

function onInteraction(args)
  sb_addScandata({args.sourceId})
  return originalOnInteraction(args)
end

function updateStageData(...)
  sb_addScandata()
  return originalUpdateStageData(...)
end

function sb_addScandata(entityIds)
  if not entityIds then
    entityIds = world.playerQuery(object.position(), 15)
  end

  local function broadcastScandata(entityIds, scandata)
    for j = 1, #scandata do
      for k = 1, #entityIds do
        world.sendEntityMessage(entityIds[k], "sb_addScandata", scandata[j], true)
      end
    end
  end

  if sb_scanObjectsOnInteract then
    broadcastScandata(entityIds, sb_scanObjectsOnInteract)
  else
    for i = 1, storage.currentStage do
      local scandata = self.stageDataList[i].sb_scanObjectsOnInteract
      if scandata then
        broadcastScandata(entityIds, scandata)
      end
    end
  end

  if ObjectAddons then
    if ObjectAddons:isConnectedToAny() then
      local addons = currentStageData().addonConfig.usesAddons
      for i = 1, #addons do
        if ObjectAddons.connectedTo[addons[i].name] then
          local scandata = addons[i].addonData and addons[i].addonData.sb_scanObjectsOnInteract
          if scandata then
            broadcastScandata(entityIds, scandata)
          end
        end
      end
    end
  end
end