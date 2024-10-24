require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/sb_assetmissing.lua"

function init() sb_techType()
  techList = "techScrollArea.itemList"
  techs = {}
  selectedTechs = {}
  strings = config.getParameter("strings")
  widget.setText("description", strings["intro"])

  local ownedTechs = util.mergeLists(player.enabledTechs(), (player.getProperty("sb_bioimplants") or {}))
  for _, tech in pairs(ownedTechs) do
    if root.hasTech(tech) then
      techs[tech] = root.techConfig(tech)
      techs[tech].icon = sb_assetmissing(techs[tech].icon, "/interface/sb_tooltips/assetmissing.png")
    else
      sb.logWarn("Could not load tech '"..tech.."'. Skipping!")
    end
  end
  populateTechList("Head")
end

function addTech(_, index)
  local tech = widget.getListSelected(techList)
  if tech then
    selectedTechs[index] = widget.getData(string.format("%s.%s", techList, tech))
    widget.setImage("itemSlot"..index, techs[widget.getData(string.format("%s.%s", techList, tech))].icon)
  end
end

function accept()
  if #selectedTechs == 2 and selectedTechs[1] ~= selectedTechs[2] then
    if player.isAdmin() or player.consumeItem("techcard") then
      player.giveItem({"sb_lockin",1,{techModules=selectedTechs}})
    else
      deny("cantAfford")
    end
  elseif #selectedTechs == 1 or selectedTechs[1] == nil and selectedTechs[2] then
    if player.isAdmin() or player.consumeItem("techcard") then
      local target = selectedTechs[1] ~= nil and selectedTechs[1] or selectedTechs[2]
      local inventoryIcon = jarray()
      table.insert(inventoryIcon, {image = "/tech/starbound/banana3.png"})
      table.insert(inventoryIcon, {image = techs[target].icon})
      player.giveItem({"sb_equip",1,{techModule=target}})
    else
      deny("cantAfford")
    end
  elseif #selectedTechs == 0 then
    deny("nothingSelected")
  else
    deny("invalidCombination")
  end
end

function deny(message)
  widget.playSound("/sfx/interface/clickon_error.ogg")
  widget.setText("description", strings[message])
end

function techSelected()
  local techName = widget.getListSelected(techList)
  if techName then
    local config = techs[widget.getData(string.format("%s.%s", techList, techName))]
    widget.setImage("techIcon", config.icon)
    widget.setText("shortdescription",string.format("%s\n^gray;%s",config.shortDescription,root.techType(config.name)))
    widget.setText("description",config.sb_uiDescription or string.format("%s ^reset;%s",config.description,config.sb_longDescription or ""):gsub("%^white;","^reset;"))
  end
end

function populateTechList(slot)
  widget.clearListItems(techList)

  local techsToDisplay = {}
  for k, _ in pairs(techs) do
    if root.hasTech(k) and root.techType(k) == slot then
      techsToDisplay[#techsToDisplay + 1] = k
    end
  ends

  for i = 1, #techsToDisplay do
    local config = techs[techsToDisplay[i]]
    local listItem = widget.addListItem(techList)
    widget.setText(string.format("%s.%s.techName", techList, listItem), config.shortDescription)
    widget.setImage(string.format("%s.%s.techIcon", techList, listItem), config.icon)
    widget.setData(string.format("%s.%s", techList, listItem), techsToDisplay[i])
  end
end

function reset()
  widget.setImage("itemSlot1", "")
  widget.setImage("itemSlot2", "")
  widget.setImage("techIcon", "")
  widget.setText("shortdescription", "")
  widget.setText("description", strings["intro"])
  selectedTechs = {}
end


function techSlotGroup(_, slot)
  reset()
  populateTechList(slot)
end