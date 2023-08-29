require "/scripts/util.lua"
--what about the status properties?
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
  widget.setChecked("btnSbLiquidCollection",player.essentialItem("beamaxe").parameters.canCollectLiquid or false)
end

function updateGui() updateGu()
  local u = sb_getUpgrades()
  sb_setWidgetsVisible({"imgSbLine2","imgSbLine3","imgSbLine4","btnSbLiquidCollection"},u.liquidcollection)
  sb_setWidgetsVisible({"btnSbPaintMode","imgSbLine1"},u.paintmode or player.essentialItem("painttool"))
  sb_setWidgetsVisible({"btnSbWireMode","imgSbLine0"},u.wiremode or player.essentialItem("wiretool"))
  sb_setWidgetsVisible({"btnSbScanMode","imgSbLine6"},player.essentialItem("inspectiontool") ~= nil and player.essentialItem("inspectiontool").name~="inspectionmode")
end

function sb_swap(_,b)
  self.defaultDescription = self.sb_defaultDescription
  local c = player.swapSlotItem()
  if c and c.name~="inspectionmode" and (root.itemType(c.name) == b["tool"] or contains(root.itemTags(c.name),b["tag"])) then
  player.setSwapSlotItem(player.essentialItem(b["slot"]))
  player.giveEssentialItem(b["slot"],c) else sb_text(1) end
end

function sb_liquid()
  local item = player.essentialItem("beamaxe")
  local liq = widget.getChecked("btnSbLiquidCollection")
  util.mergeTable(item.parameters,{canCollectLiquid=liq})
  player.giveEssentialItem("beamaxe",item)
  sb_text(liq and 2 or 3)
end

function sb_getUpgrades()
  local u = {}
  local mm = player.essentialItem("beamaxe") or {}
  local mmType = root.itemType(mm.name)
  if (mmType=="miningtool" or mmType=="currency") then widget.setButtonEnabled("btnUpgrade",false) end
  mm = mm.parameters.upgrades or {}
  --if not contains(mm,"sb_generic") then mm[#mm+1]="sb_generic" end
  for i, v in ipairs(mm) do u[v] = true end
  return u
end

function sb_beamaxe()
  self.defaultDescription = self.sb_defaultDescription
  local mm = player.swapSlotItem()
  if mm ~= nil then
    local mmType = root.itemType(mm.name)
    if (not (mmType == "beamminingtool" or mmType == "miningtool" or root.itemHasTag(mm.name,"miningtool"))) then
    sb_text(1) return end
  else sb_text(1) return end
  local u = sb_getUpgrades() or {}
  if mm and u ~= {} then
    mm.parameters.upgrades = mm.parameters.upgrades or {}
    local p = mm.parameters.upgrades
    if not contains(p,"sb_generic") then mm.parameters.upgrades[#mm.parameters.upgrades+1]="sb_generic" end
    if u.paintmode and not contains(p,"paintmode") then mm.parameters.upgrades[#mm.parameters.upgrades+1]="paintmode" end
    if u.wiremode and not contains(p,"wiremode") then mm.parameters.upgrades[#mm.parameters.upgrades+1]="wiremode" end
  end
  player.setSwapSlotItem(player.essentialItem("beamaxe"))
  player.giveEssentialItem("beamaxe",mm)
--widget.setButtonEnabled("btnUpgrade",(root.itemType(mm.name)~="miningtool" and root.itemType(mm.name)~="currency"))
end

function performUpgrade(n,d)
  local upgrade = self.upgradeConfig[self.selectedUpgrade]
  if upgrade.setItem then
    local a = player.essentialItem(upgrade.essentialSlot)
    if a then player.giveItem(a) end
  end
  return performUpgrad(n,d)
end

function sb_setWidgetsVisible(w,b) for i=1, #w do widget.setVisible(w[i],b) end end
function sb_text(n) self.selectedUpgrade = nil self.defaultDescription = config.getParameter("sb_text")[n] updateGui() end