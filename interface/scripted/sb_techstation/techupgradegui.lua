require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/sb_assetmissing.lua"

function init()
  sb_techType()
  static = {0,0}
  techList = "techScrollArea.techList"
  ownedImplants = player.getProperty("sb_bioimplants")
  self_availableImplants = player.getProperty("sb_availableBioimplants")
  if #ownedImplants > 1 then table.sort(ownedImplants,function(a,b) return a<b end) end
  if #self_availableImplants > 1 then table.sort(self_availableImplants,function(a,b) return a<b end) end
  self_techLockedIcon = config.getParameter("techLockedIcon")
  self_suitImagePath = config.getParameter("suitImagePath")
  buttonImages = config.getParameter("buttonImages")
  imgSuit = sb_assetmissing(string.format(self_suitImagePath,player.species(),player.gender()),string.format(self_suitImagePath,"novakid",player.gender()))
  selectTechDescription, techValues = config.getParameter("selectTechDescription"), config.getParameter("techValues")
  showUnlockButton = false
  driveCost = config.getParameter("driveCost")
  defaultCost = config.getParameter("defaultCost",root.assetJson("/interface/scripted/techupgrade/techupgradegui.config:defaultCost"))

  techs = {}
  for _,tech in pairs(player.availableTechs()) do
    if root.hasTech(tech) then
      techs[tech] = root.techConfig(tech)
--  else
--    sb.logWarn("Could not load tech '"..tech.."'. Skipping!")
    end
  end

  setSelectedSlot("Head")
  updateEquippedIcons()
  widget.setText("lblDescription", selectTechDescription)
  techSelected()
  setButtonImage(1)
end

function update(dt)
  sb.setLogMap("sb_selectedtech","%s",selectedTech or "")
  sb.setLogMap("sb_bioimplant","%s",player.getProperty("sb_bioimplant",""))
  animateSelection(dt)
  widget.setButtonEnabled("btnEnable", false or (selectedTech ~= nil))
  if selectedSlot == "Suit" then widget.setText("lblChipsCount","") end
  if selectedTech ~= nil then
    local currentChips = player.hasCountOfItem("techcard")
    if selectedSlot ~= "Suit" then
      if not contains(player.enabledTechs(), selectedTech) then
	showUnlockButton = true
	local cost = techCost(selectedTech)
	widget.setText("lblChipsCount", string.format("%s/%s", currentChips, cost))
	setButtonEnabled(player.isAdmin() or currentChips >= cost)
      else
	showUnlockButton = false
      end
    end
    if selectedSlot == "Suit" then
      if not contains(ownedImplants, selectedTech) then
	showUnlockButton = true
	local cost = techCost(selectedTech)
	widget.setText("lblChipsCount", string.format("%s/%s", currentChips, cost))
	setButtonEnabled(player.isAdmin() or currentChips >= cost)
      else
	showUnlockButton = false
      end
    end
  end
  updateButtonImage()
end

function techCost(techName)
  if techs[techName] == nil then return defaultCost end
  return techs[techName].chipCost or defaultCost
end

function showDriveCost()
  local currentDrives = player.hasCountOfItem("techcard")
  widget.setText("lblChipsCount", string.format("%s/%s", currentDrives, driveCost))
  setButtonEnabled(player.isAdmin() or currentDrives >= driveCost)
end

function populateTechList(slot)
  selectedTech = nil
  widget.setText("lblChipsCount", "")
  widget.setButtonImages("btnEnable", buttonImages[1])
  widget.clearListItems(techList)

  local availableTechs = player.availableTechs()
  local enabledTechs = player.enabledTechs()
  local disabled = util.filter(util.keys(techs), function(a) return not contains(enabledTechs, a) end)
  util.appendLists(enabledTechs, disabled)
  availableTechs = enabledTechs

  for _,techName in pairs(availableTechs) do
    if not techs[techName] then techs[techName] = root.hasTech(techName) and root.techConfig(techName) end
    if root.hasTech(techName) then
      local config = techs[techName]
      if root.techType(techName) == slot then
        local listItem = widget.addListItem(techList)
        widget.setText(string.format("%s.%s.techName", techList, listItem), config.shortDescription)
        widget.setData(string.format("%s.%s", techList, listItem), techName)

        if contains(player.enabledTechs(), techName) then
          widget.setImage(string.format("%s.%s.techIcon", techList, listItem), sb_assetmissing(config.icon,"/interface/sb_tooltips/assetmissing.png"))
        else
          widget.setImage(string.format("%s.%s.techIcon", techList, listItem), self_techLockedIcon)
        end

        if player.getProperty("sb_bioimplant") == techName or player.equippedTech(slot) == techName then
          widget.setListSelected(techList, listItem)
	  widget.setButtonEnabled("btnEnable", true)
	  widget.setButtonImages("btnEnable", buttonImages[3])
        end
      end
    end
  end
end

function setSelectedSlot(slot)
  selectedSlot = slot
  updateEquippedIcons()
  widget.setText("lblDescription", selectTechDescription)

  if slot == "Suit" then
    widget.clearListItems(techList)
    selectedTech = nil
    widget.setButtonImages("btnEnable", buttonImages[1])
    widget.setButtonEnabled("btnEnable", false)
    equipSuit()
  else
    populateTechList(slot)
  end
end

function animateSelection(dt)
  if static[1] >= 3 then static[1] = 0 else static[1] = static[1] + 1 end
  if static[2] >= 13 then static[2] = 0 else static[2] = static[2] + 1 end
  widget.setImage("staticImage","/ai/staticapex.png:"..static[1])
  widget.setImage("staticImage","/interface/scripted/sb_techstation/scanlines.png:"..static[2])
end

function enableTech(techName)
  local cost = techCost(techName)
  if player.isAdmin() or player.consumeItem({name = "techcard", count = cost}) then
    player.enableTech(techName)
    equipTech(techName)
    populateTechList(selectedSlot)
  end
end

function enableSuit(techName)
  local cost = techCost(techName)
  if not contains(ownedImplants, techName) and (player.isAdmin() or player.consumeItem({name = "techcard", count = cost})) then
    if #ownedImplants == 0 then ownedImplants = {techName} else ownedImplants[#ownedImplants+1] = techName end
    player.setProperty("sb_bioimplants", ownedImplants)
    if #ownedImplants > 1 then table.sort(ownedImplants,function(a,b) return a<b end) end
    setSelectedSlot("Suit")
  end
end

function updateEquippedIcons()
  updateSuitImage()
  local suit = player.getProperty("sb_bioimplant")
  if suit and root.hasTech(suit) then
    local config = root.techConfig(suit)
    widget.setImage("techIconSuit", sb_assetmissing(config.icon,"/interface/sb_tooltips/assetmissing.png"))
  end
  for _,slot in pairs({"Head", "Body", "Legs"}) do
    local tech = player.equippedTech(slot)
    if (tech and techs[tech]) and (tech ~= nil) then
      widget.setImage(string.format("techIcon%s", slot), sb_assetmissing(techs[tech].icon,"/interface/sb_tooltips/assetmissing.png"))
    else
      widget.setImage(string.format("techIcon%s", slot), "")
    end
  end
end

function updateButtonImage() --Probably not the best idea to set images and enable the button every update cycle, but I want to get this done.
  if showUnlockButton then setButtonImage(2) return end
  if not selectedTech then setButtonImage(1) setButtonEnabled(false) return end
  if selectedSlot ~= "Suit" then
    if selectedSlot then
      if player.equippedTech(selectedSlot) == (selectedTech or "") then
	setButtonImage(3)
	showDriveCost()
	return
      end
    end
  end

  if selectedSlot == "Suit" and player.getProperty("sb_bioimplant") == selectedTech then setButtonImage(3) showDriveCost() return end
  setButtonImage(1) widget.setText("lblChipsCount","")
end

function setButtonImage(n) widget.setButtonImages("btnEnable", buttonImages[n]) end
function setButtonEnabled(b) widget.setButtonEnabled("btnEnable",b) end

function equipTech(techName)
  player.equipTech(techName)
  updateEquippedIcons()
end

function doDesc(config)
  local desc = (config.sb_uiDescription or string.format("%s ^reset;%s",config.description, config.sb_longDescription or ""):gsub("%^white;","^reset;")).."\n\n"
  for k, v in pairs(techValues) do
    if config[k] then desc = desc..string.format(v.."\n",config[k]) end
  end
  return desc
end

function setSelectedTech(techName)
  if techName == nil then return end
  selectedTech = techName
  widget.setText("lblDescription", doDesc(root.techConfig(techName)))
  updateEquippedIcons()
  if selectedSlot == "Suit" then
    widget.setButtonEnabled("btnEnable", true)
    return
  end

  if contains(player.enabledTechs(), techName) then
    widget.setButtonEnabled("btnEnable", true)
  else
    local affordable = player.isAdmin() or player.hasCountOfItem("techcard") >= techCost(techName)
    widget.setButtonEnabled("btnEnable", affordable)
  end
  updateButtonImage()
end

function equipSuit()
  local listItem = widget.getListSelected(techList)
  if listItem then setSelectedTech(player.getProperty("sb_bioimplant")) end
  widget.clearListItems(techList)
  widget.setButtonEnabled("btnEnable", false)
  local listedTechs = {}
  for i = 1, 2 do
    local target2 = i == 1 and #ownedImplants or #self_availableImplants
    for implants = 1, target2 do
      local target = i == 1 and ownedImplants[implants] or self_availableImplants[implants]
      player.makeTechUnavailable(target)
      if root.hasTech(target) then
	if not contains(listedTechs, target) then
	  listedTechs[#listedTechs+1] = target
	  local config = root.techConfig(target)
	  local listItem = widget.addListItem(techList)
	  widget.setText(string.format("%s.%s.techName", techList, listItem), config.shortDescription)
	  widget.setData(string.format("%s.%s", techList, listItem), {target,config.sb_effect})
	  widget.setImage(string.format("%s.%s.techIcon", techList, listItem), i==1 and sb_assetmissing(config.icon,"/interface/sb_tooltips/assetmissing.png") or self_techLockedIcon)
	  if player.getProperty("sb_bioimplant") == config.name then
	    widget.setListSelected(techList, listItem)
	  end
	end
--    else
--      sb.logWarn("Could not load tech '"..target.."' of kind 'suit'. Skipping!")
      end
    end
  end
end

function updateSuitImage()
  local tech = player.getProperty("sb_bioimplant")
  local icon = ""
  if tech and root.hasTech(tech) then
    icon = root.techConfig(tech).sb_suitImage or "?replace;73daff=f7d700;27abff=e99400;117ee4=c65d00;1f45d4=8a2400;002b72=430000;001522=230000?saturation=-50"
  end
  widget.setImage("imgSuit", string.format(imgSuit)..string.format(icon.."?multiply=FFFFFF%2x", math.floor(0.8 * 255)))
end

function ownsTech(techName)
  local ownedTech = player.availableTechs()
    for techs_ = 1, #ownedTech do
      if ownedTech[techs_] == techName then return true
    end
  end
end

function techSelected()
  local listItem = widget.getListSelected(techList)
  if listItem then
    local techName = nil
    if selectedSlot == "Suit" then techName = widget.getData(string.format("%s.%s", techList, listItem)) techName = techName[1] else
    techName = widget.getData(string.format("%s.%s", techList, listItem)) end
    setSelectedTech(techName)
  end
end

function techSlotGroup(button, slot)
  setSelectedSlot(slot)
end

function doEnable()
  if selectedTech == nil then return end

  if selectedSlot == "Suit" then
    local ownsSuit = contains(ownedImplants, selectedTech)
    if ownsSuit then
      if player.getProperty("sb_bioimplant") == selectedTech then giveTech() return end
      world.sendEntityMessage(player.id(), "sb_implant", widget.getData(string.format("%s.%s", techList, widget.getListSelected(techList))))
      equipSuit()
    else
      enableSuit(selectedTech) return
    end
  end
    
  if (selectedTech) and (selectedSlot ~= "Suit") then
    if player.equippedTech(selectedSlot) == selectedTech then giveTech() return
      else if contains(player.enabledTechs(), selectedTech) then
	equipTech(selectedTech)
      else
	enableTech(selectedTech)
      end
    end
  end
end

function giveTech()
  if player.isAdmin() or player.consumeItem({name="techcard",count=driveCost}) then
    player.giveItem({"sb_tech",1,{techModule=selectedTech}})
  end
end

function unequip(_,slot)
  if slot == "suit" then
    world.sendEntityMessage(player.id(),"sb_implant_unequip")
    widget.setText("lblDescription", selectTechDescription)
    widget.setButtonEnabled("btnEnable", false)
  else
  local tech = player.equippedTech(slot)
    if tech then player.unequipTech(tech) end
  end
  updateEquippedIcons()
  updateSuitImage()
end

function openPane(_,a) player.interact("ScriptPane",a,pane.sourceEntity()) pane.dismiss() end