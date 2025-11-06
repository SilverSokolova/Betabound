require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/sb_assetmissing.lua"

function init() sb_techType()
  script.setUpdateDelta(20)
  activeItem.setHoldingItem(false)
  sb_cursor("power")
  tech = config.getParameter("techModule")
  durability = config.getParameter("durability", 5)
  subtitle = config.getParameter("subtitle")
  description = config.getParameter("descriptionTemplate")
end

function activate()
  if player.isAdmin() or config.getParameter("durabilityHit", 5) >= durability then
    tryEquipTech()
  else
    animator.playSound("fail")
  end
end

function update(dt)
  local durabilityHit = config.getParameter("durabilityHit", 5)
  if durabilityHit < durability then
    activeItem.setInstanceValue("durabilityHit", durabilityHit + 1)
  end
end

function tryEquipTech()
  if root.hasTech(tech) then
    local equippedTechType = root.techType(tech)
    local equippedTech = equippedTechType == "Suit" and player.getProperty("sb_bioimplant") or player.equippedTech(equippedTechType)
    if ownsTech(equippedTechType) then
      if equippedTech then
        if equippedTech == tech then
          --Both are identical
          sb_uiMessage("techAlreadyEquipped")
        else
          --Both are different; equip w/ change
          equipTech(tech, equippedTechType)
          changeItem(equippedTech, equippedTechType)
        end
      else
        --Not wearing anything; equip w/o change
        equipTech(tech, equippedTechType)
      end
    else
      sb_uiMessage("techNotKnown")
    end
  else
    --No such tech
    sb_uiMessage("invalidModSetup")
  end
end

function equipTech(techName, slot)
  animator.playSound("success")
  activeItem.setInstanceValue("durabilityHit", 0)
  if slot == "Suit" then
    player.interact("message", {messageType = "sb_implant", messageArgs = {techName}})
  else
    player.equipTech(techName)
  end
end

function changeItem(techName, equippedTechType)
  local techData = root.techConfig(techName)
  activeItem.setInventoryIcon(sb_assetmissing(techData.icon))
  activeItem.setInstanceValue("techModule", techName)
  --Items modified by activeItem.setInstanceValue don't update certain values VISUALLY in the inventory, so some values are set in the builder
  local newDescription = string.format(description, techData.shortDescription or "?")
  activeItem.setInstanceValue("tooltipFields", {
    subtitle = string.format(subtitle, equippedTechType),
    fakeDescriptionLabel = newDescription
  })
  activeItem.setInstanceValue("description", "^clear;" .. cutColors(newDescription)) --So item search mods can find it by description
  tech = techName
end

function ownsTech(slot) return slot == "Suit" and contains(player.getProperty("sb_bioimplants",{}), tech) or contains(player.enabledTechs(), tech) end
function cutColors(text) return string.gsub(string.gsub(text, "(%^.-%;)", ""),("\n"),"") end