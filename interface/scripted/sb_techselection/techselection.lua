require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/sb_assetmissing.lua"

function lockin(_,a)
--if #self_locked < 1 then a = 1 end
  local tech = widget.getListSelected(self_techList) or nil
  if tech == nil then return end
  self_locked[a] = widget.getData(string.format("%s.%s", self_techList, tech))
  widget.setImage("itemSlot"..a, sb_assetmissing(self_techs[widget.getData(string.format("%s.%s", self_techList, tech))].icon,"/interface/sb_tooltips/assetmissing.png"))
end

function init() sb_techType()
  self_locked = {}
  self_techList = "techScrollArea.itemList"
  self_techs = {}
  local ownedTechs = util.mergeLists(player.enabledTechs(),player.getProperty("sb_bioimplants",{}))
  for _,tech in pairs(ownedTechs) do
    if root.hasTech(tech) and tech ~= "sb_noprotection" then
      self_techs[tech] = root.techConfig(tech)
    else
      sb.logWarn("Could not load tech '"..tech.."'. Skipping!")
    end
  end
  cantAffordText = config.getParameter("cantAffordText")
  incompatibleText = config.getParameter("incompatibleText")
  selectSomethingText = config.getParameter("selectSomethingText")
  populateTechList()
end

function accept()
  if #self_locked == 2 and (root.techType(self_locked[1]) == root.techType(self_locked[2])) and not (root.techConfig(self_locked[1]).name == root.techConfig(self_locked[2]).name) then
    if player.isAdmin() or player.consumeItem("techcard") then
      local fields = {}
      fields.objectImage = ""
      fields.objectBImage = sb_assetmissing(root.techConfig(self_locked[1]).icon,"/interface/sb_tooltips/assetmissing.png")
      fields.objectCImage = sb_assetmissing(root.techConfig(self_locked[2]).icon,"/interface/sb_tooltips/assetmissing.png")
      player.giveItem({name="sb_lockin",count=1,parameters={techModules=self_locked,tooltipFields=fields,version=2}})
    else
      deny(cantAffordText)
    end
  elseif #self_locked == 1 or self_locked[1] == nil and self_locked[2] then
    if player.isAdmin() or player.consumeItem("techcard") then
      local target = self_locked[1] ~= nil and self_locked[1] or self_locked[2]
      local inventoryIcon = jarray()
      table.insert(inventoryIcon, {image = "/tech/starbound/banana3.png"})
      table.insert(inventoryIcon, {image = sb_assetmissing(root.techConfig(target).icon,"/interface/sb_tooltips/assetmissing.png")})
      player.giveItem({name="sb_equip",count=1,parameters={techModule=target,inventoryIcon=inventoryIcon}})
    else
      deny(cantAffordText)
    end
  elseif #self_locked == 0 then
    deny(selectSomethingText)
  else
    deny(incompatibleText)
  end
end

function deny(s) widget.playSound("/sfx/interface/clickon_error.ogg") widget.setText("description",s) end

function techSelected()
  local techName = widget.getListSelected(self_techList)
  if techName then
    local config = self_techs[widget.getData(string.format("%s.%s", self_techList, techName))]
    widget.setImage("techIcon", sb_assetmissing(config.icon,"/interface/sb_tooltips/assetmissing.png"))
    widget.setText("shortdescription",string.format("%s\n^gray;%s",config.shortDescription,root.techType(config.name)))
    widget.setText("description",config.sb_uiDescription or string.format("%s ^reset;%s",config.description,config.sb_longDescription or ""):gsub("%^white;","^reset;"))
  end
end

function populateTechList()
  widget.clearListItems(self_techList)

  local suits = player.getProperty("sb_bioimplants",{})
  if #suits > 1 then table.sort(suits,function(a,b) return a<b end) end
  local ownedTechs = util.mergeLists(player.enabledTechs(),suits)
  local techs = util.mergeLists(player.enabledTechs(),suits)
  local slots = {"Head","Body","Legs","Suit"}

  for i = 1, #slots do --I was pretty sure I had a better way of doing this, but it seems to have been lost. Enjoy this replacement; it's not the best.
    for _,techName in pairs(techs) do
      local config = self_techs[techName]
      if root.hasTech(techName) and techName ~= "sb_noprotection" then
	if root.techType(techName) == slots[i] then
	  local listItem = widget.addListItem(self_techList)
	  widget.setText(string.format("%s.%s.techName", self_techList, listItem), config.shortDescription)
	  widget.setImage(string.format("%s.%s.techIcon", self_techList, listItem), sb_assetmissing(config.icon,"/interface/sb_tooltips/assetmissing.png"))
	  widget.setData(string.format("%s.%s", self_techList, listItem), techName)
	end
      end
    end
  end
end

function reset()
  widget.setImage("itemSlot1","")
  widget.setImage("itemSlot2","")
  self_locked = {}
end

function openPane(_,a) player.interact("ScriptPane",a,pane.sourceEntity()) pane.dismiss() end