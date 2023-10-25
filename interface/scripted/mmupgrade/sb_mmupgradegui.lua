local ini = init or function() end
local updateGu = updateGui or function() end
local performUpgrad = performUpgrade or function() end

function sb_moveGui()
  local w = {{"LiquidCollection","Beamaxe","PaintMode","WireMode","ScanMode"},root.assetJson("/betabound.config:posMMUI")}
  for i = 1, #w[1] do widget.setPosition("btnSb"..w[1][i],w[2][i]) end
  for i = 0, 6 do widget.setImage("imgSbLine"..i,"/assetmissing.png") end
end

function init() ini()
  if (root.assetJson("/betabound.config:forceMoveMMUI") --betabound
    or (#config.getParameter("upgrades",{}).paintmode.prerequisites < 1) --EnhancedMatterManipulator
    or betterResetTools) --moremmupgrades
  then
    sb_moveGui()
  end
  self.sb_defaultDescription = self.defaultDescription or ""
  sb_statusProperties = {}
  for k, v in pairs(self.upgradeConfig) do
    if v.setStatusProperties then
      for k2, v2 in pairs(v.setStatusProperties) do
        if (sb_statusProperties[k2] or 0) < v2 then
          sb_statusProperties[k2] = v2
        end
      end
    end
  end
end

function updateGui() updateGu()
  local upgrades = sb_getUpgrades()
  if not sb_mmChecked and contains(upgrades, "sb_generic") then
    local mm = player.essentialItem("beamaxe").parameters.upgrades
    local u = {}
    for i = 1, #mm do
      if mm[i] ~= "sb_generic" then
        u[#u+1] = mm[i]
       end
    end
    mm = player.essentialItem("beamaxe")
    util.mergeTable(mm.parameters, {upgrades=u})
    player.giveEssentialItem("beamaxe", mm)
    sb_mmChecked = true
  end
  widget.setChecked("btnSbLiquidCollection", player.essentialItem("beamaxe").parameters.canCollectLiquid or false)
  sb_setWidgetsVisible({"imgSbLine2","imgSbLine3","imgSbLine4","btnSbLiquidCollection"}, contains(upgrades, "liquidcollection"))
  sb_setWidgetsVisible({"btnSbPaintMode","imgSbLine1"}, upgrades.paintmode or player.essentialItem("painttool"))
  sb_setWidgetsVisible({"btnSbWireMode","imgSbLine0"}, upgrades.wiremode or player.essentialItem("wiretool"))
  sb_setWidgetsVisible({"btnSbScanMode","imgSbLine6"}, player.essentialItem("inspectiontool") ~= nil and player.essentialItem("inspectiontool").name ~= "inspectionmode")
end

function sb_swap(_, widgetData)
  self.defaultDescription = self.sb_defaultDescription
  local swapSlot = player.swapSlotItem()
  if swapSlot and swapSlot.name ~= "inspectionmode" and
    (root.itemType(swapSlot.name) == widgetData["tool"] or contains(root.itemTags(swapSlot.name), widgetData["tag"]))
  then
    player.setSwapSlotItem(player.essentialItem(widgetData["slot"]))
    player.giveEssentialItem(widgetData["slot"], swapSlot)
  else
    sb_text(1)
  end
end

function sb_liquid()
  local item = player.essentialItem("beamaxe")
  local enabled = widget.getChecked("btnSbLiquidCollection")
  util.mergeTable(item.parameters, {canCollectLiquid=enabled})
  player.giveEssentialItem("beamaxe", item)
  sb_text(enabled and 2 or 3)
end

function sb_getUpgrades()
  local mm = player.essentialItem("beamaxe") or {}
  local mmType = root.itemType(mm.name)
  if (mmType=="miningtool" or mmType=="currency") then widget.setButtonEnabled("btnUpgrade",false) end
  return mm.parameters and mm.parameters.upgrades or {}
end

function sb_beamaxe()
  self.defaultDescription = self.sb_defaultDescription
  local mm = player.swapSlotItem()
  if mm then
    local mmType = root.itemType(mm.name)
    if (not (mmType == "beamminingtool" or mmType == "miningtool" or root.itemHasTag(mm.name, "miningtool"))) then
      sb_text(1)
      return
    end
  else
    sb_text(1)
    return
  end
  local swapUpgrades = mm.parameters and mm.parameters.upgrades or {}
  local setProperties = {}
  status.setStatusProperty("bonusBeamGunRadius", 0)
  for i = 0, #swapUpgrades-1 do
    local setStatusProperties = self.upgradeConfig[swapUpgrades[#swapUpgrades-i]]
    setStatusProperties = setStatusProperties and setStatusProperties.setStatusProperties --to check if it exists
    if setStatusProperties then
      for k, v in pairs(setStatusProperties) do
        if not setProperties[k] then
          setProperties[k] = 1
          status.setStatusProperty(k, v)
        end
      end
    end
  end
  player.setSwapSlotItem(player.essentialItem("beamaxe"))
  player.giveEssentialItem("beamaxe", mm)
  sb_mmChecked = false
end

function performUpgrade(widgetName, widgetData)
  local upgrade = self.upgradeConfig[self.selectedUpgrade]
  if upgrade.setItem then
    local oldItem = player.essentialItem(upgrade.essentialSlot)
    if oldItem then
      player.giveItem(oldItem)
    end
  end
  return performUpgrad(widgetName, widgetData)
end

function sb_setWidgetsVisible(w,b) for i=1, #w do widget.setVisible(w[i],b) end end
function sb_text(n) self.selectedUpgrade = nil self.defaultDescription = config.getParameter("sb_text")[n] updateGui() end