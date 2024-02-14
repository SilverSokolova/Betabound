require("/scripts/sb_assetmissing.lua")
local sb_init = init or function() end
local sb_setSelectedTech = setSelectedTech or function() end
local sb_animateSelection = animateSelection or function() end
local sb_populateTechList = populateTechList or function() end
local sb_equipTech = equipTech or function() end
local sb_createTooltip = createTooltip or function() end
local sb_techSlotGroup = techSlotGroup or function() end
local sb_pat_remove = pat_remove or function() end

function init() sb_init()
  if sb_didInit then return end --prevent stack overflow when removing techs with Patman's mod
  sb_didInit = true

  sb_techType()
  player.sb_equippedTech = player.equippedTech
  player.equippedTech = function(tech)
    if tech == "sb_suit" then return nil end
    return player.sb_equippedTech(tech) 
  end
  if pat_unequip then widget.setVisible("pat_unequip", false) end --no need for a tech button that doesnt do suits
  player.sb_enabledTechs = player.enabledTechs
  player.sb_enableTech = player.enableTech

  player.enabledTechs = function() return self.selectedSlot ~= "sb_suit" and player.sb_enabledTechs() or sb_ownedImplants end
  player.enableTech = function(tech)
    if self.selectedSlot ~= "sb_suit" then
      player.sb_enableTech(tech)
    else
      if #sb_ownedImplants == 0 then
        sb_ownedImplants = {tech}
      else
        sb_ownedImplants[#sb_ownedImplants+1] = tech
        table.sort(sb_ownedImplants,function(a,b) return a<b end)
      end
      world.sendEntityMessage(player.id(), "sb_implant", tech)
      sb_suit = tech
      sb_toggleButtons()
      populateTechList("sb_suit")
      player.setProperty("sb_bioimplants", sb_ownedImplants)
    end
  end

  local pos = widget.getPosition("imgSelectedLegs")
  widget.setPosition("sb_btnSuit",{pos[1]+10, pos[2]-16})
--widget.setPosition("sb_btnSuit",{widget.getPosition("lblSlot")[1]-2, widget.getPosition("close")[2]-16})
--widget.setPosition("sb_btnSuit",{pos[1] - (widget.getChildAt({321, 236}) and 72 or 90),pos[2]-2}) --width of button plus 18/36
  sb_prepareSuits()
  sb_selectTechDescription = config.getParameter("sb_selectTechDescription")
  sb_downloadTechDescription = config.getParameter("sb_downloadTechDescription")
  sb_downloadCost = config.getParameter("sb_downloadCost", 1)
  sb_suitImage = string.format(config.getParameter("suitImagePath"), player.species(), player.gender())
  sb_suitSelectedPath = string.format(self.suitSelectedPath, player.species(), player.gender(), ""):gsub("-.png","")..".png"
  sb_suitImageColor = ""
  sb_suit = player.getProperty("sb_bioimplant")
  sb_tooltip = root.assetJson("/interface/tooltips/sb_tech.tooltip")
  sb_tooltip.priceLabel.visible = false; sb_tooltip.moneyIcon.visible = false; sb_tooltip.background.fileHeader = "/interface/tooltips/sb_header4.png"
  sb_updateSuitImage()
end

function setSelectedTech(techName)
  if self.selectedSlot ~= "sb_suit" then
    sb_setSelectedTech(techName)
    local config = root.techConfig(techName)
    if config.sb_briefDescription then
      widget.setText("lblDescription", config.sb_briefDescription)
    end
  else
    self.selectedTech = techName
    if contains(sb_ownedImplants, techName) then
      widget.setButtonEnabled("btnEnable", false)
      world.sendEntityMessage(player.id(), "sb_implant", techName)
      sb_suit = techName --set it here in case the message arrives late
      sb_updateSuitImage()
    else
      widget.setButtonEnabled("btnEnable", false)
    end
  end
end

function animateSelection(dt)
  if self.selectedSlot ~= "sb_suit" then sb_animateSelection(dt) else
    self.animationTimer = self.animationTimer + dt
    while self.animationTimer > self.selectionPulse do
      self.animationTimer = self.animationTimer - self.selectionPulse
    end

    widget.setVisible("imgSelectedHead", false)
    widget.setVisible("imgSelectedBody", false)
    widget.setVisible("imgSelectedLegs", false)
    widget.setImage("imgSelected", sb_suitSelectedPath..string.format("?multiply=FFFFFF%2x", math.floor(interp.sin((self.animationTimer / self.selectionPulse) * 2, 0, 1) * 255))..sb_suitImageColor)
  end
end

function populateTechList(slot)
  self.selectedTech = nil
  if slot ~= "sb_suit" then sb_populateTechList(slot) else
    widget.clearListItems(self.techList)
    local listedTechs = {}
    for i = 1, 2 do
      local currentList = i == 1 and sb_ownedImplants or sb_availableImplants
      for suit = 1, #currentList do
        local tech = currentList[suit]
        player.makeTechUnavailable(tech)
        if root.hasTech(tech) and not contains(listedTechs, tech) then
          listedTechs[#listedTechs+1] = tech
          if not self.techs[tech] then self.techs[tech] = root.techConfig(tech) end
          local config = self.techs[tech]
          --Some mod setups can cause techs to end up in the wrong place... somehow. Check for it.
          if root.techType(tech) == "Suit" then
            local listItem = widget.addListItem(self.techList)
            widget.setText(string.format("%s.%s.techName", self.techList, listItem), config.shortDescription)
            widget.setData(string.format("%s.%s", self.techList, listItem), tech)
            widget.setImage(string.format("%s.%s.techIcon", self.techList, listItem), i == 1 and config.icon or self.techLockedIcon)

            if sb_suit == tech then
              widget.setListSelected(self.techList, listItem)
            end
          else
            local newOwned, newAvailable = {}, {}
            for i = 1, #sb_ownedImplants do
              if tech ~= sb_ownedImplants[i] then
                newOwned[#newOwned+1] = sb_ownedImplants[i]
              end
            end
            for i = 1, #sb_availableImplants do
              if tech ~= sb_availableImplants[i] then
                newAvailable[#newAvailable+1] = sb_availableImplants[i]
              end
            end
            player.setProperty("sb_bioimplants", newOwned)
            player.setProperty("sb_availableImplants", newAvailable)
            player.makeTechAvailable(tech)
            player.sb_enableTech(tech)
            sb_prepareSuits()
          end
        end
      end
    end
  end
end

--function techCost(techName) --fixes being able to purchase non-suit techs as suits. doesnt fix it with bk3k but oh well
--  local cost = sb_techCost(techName)
--  return cost == 0 and self.selectedSlot == "sb_suit" and 1 or cost
--end

function techSlotGroup(button, slot)
  sb_techSlotGroup(button, slot)
  sb_toggleButtons()
end

function equipTech(tech)
  if self.selectedSlot ~= "sb_suit" then sb_equipTech(tech) end
  sb_toggleButtons()
end

function sb_unequip()
  if self.selectedSlot == "sb_suit" then
    world.sendEntityMessage(player.id(), "sb_implant_unequip")
    sb_suit = nil
  else
    local tech = player.equippedTech(self.selectedSlot)
    if tech then player.unequipTech(tech) end
  end
  updateEquippedIcons()
  sb_updateSuitImage()
  sb_toggleButtons()
end

function sb_showSuits()
  self.selectedSlot = "sb_suit"
  sb_updateSuitImage()
  populateTechList("sb_suit")
  widget.setText("lblDescription", sb_selectTechDescription)
  widget.setText("lblSlot", self.slotLabelText["sb_suit"])
  sb_toggleButtons()
end

function sb_download()
  if self.selectedTech and (contains(sb_ownedImplants, self.selectedTech) or contains(player.enabledTechs(), self.selectedTech)) then
    if player.isAdmin() or player.consumeItem({name="techcard",count=sb_downloadCost}) then
      player.giveItem({"sb_tech",1,{techModule=self.selectedTech}})
    else
      widget.setText("lblDescription", sb_downloadTechDescription)
    end
  end
end

function sb_updateSuitImage()
  if sb_suit and root.hasTech(sb_suit) then
    sb_suit = player.getProperty("sb_bioimplant")
    sb_toggleButtons()
    self.animationTimer = 0
    sb_suitImageColor = root.techConfig(sb_suit).sb_suitImage or "?replace;73daff=f7d700;27abff=e99400;117ee4=c65d00;1f45d4=8a2400;002b72=430000;001522=230000?saturation=-50"
    widget.setImage("imgSuit", string.format(sb_suitImage)..string.format(sb_suitImageColor.."?multiply=FFFFFF%2x", math.floor(0.8 * 255)))
  else
    widget.setImage("imgSuit", string.format(self.suitImagePath, player.species(), player.gender()))
  end
end

function pat_remove()
  if self.selectedSlot ~= "sb_suit" then
    sb_toggleButtons()
    return sb_pat_remove()
  end
end

function sb_toggleButtons()
  local tech = self.selectedTech and (self.selectedSlot ~= "sb_suit" and player.equippedTech(self.selectedSlot) or self.selectedSlot == "sb_suit" and sb_suit) or false
  --yknow what fuck it it doesnt matter if the unequip/download buttons are visible for locked techs. they cant even download it. i tried string.find-ing "--" in the cost amount text but it didnt work for some reason
  --hi hello yes this is me from the future you need to %-%- ahahahaha that's also why the food rot bar detection didnt work
  widget.setButtonEnabled("sb_download", tech and true or false)
  widget.setButtonEnabled("sb_unequip", tech and true or false)
end

function sb_prepareSuits()
  sb_ownedImplants, sb_availableImplants = player.getProperty("sb_bioimplants",{}), player.getProperty("sb_availableBioimplants",{})
  if #sb_ownedImplants > 1 then table.sort(sb_ownedImplants,function(a,b) return a<b end) end
  if #sb_availableImplants > 1 then table.sort(sb_availableImplants,function(a,b) return a<b end) end
  widget.setButtonEnabled("sb_btnSuit", #sb_ownedImplants + #sb_availableImplants > 0)
end

function createTooltip(p)
  if self.selectedSlot ~= "sb_suit" then return sb_createTooltip(p) else
    name = widget.getChildAt(p)
    name = name and name:sub(2,(name:find("%.", 26) or 3)-1) or nil
    name = name and widget.getData(name)
    if name then
      sb_tooltip.descriptionLabel.value = self.techs[name].description
      return sb_tooltip
    end
  end
end