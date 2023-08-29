require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/sb_assetmissing.lua"

function init() sb_techType()
  script.setUpdateDelta(20)
  activeItem.setHoldingItem(false)
  sb_cursor("power")
  tech = config.getParameter("techModule")
  durability = config.getParameter("durability",5)
end

function activate() if player.isAdmin() or config.getParameter("durabilityHit",5) >= durability then equipTech() end end

function update(dt)
  local d = config.getParameter("durabilityHit",5)
  if d < durability then activeItem.setInstanceValue("durabilityHit",d+1) end
end

function equipTech()
  if root.hasTech(tech) then
    local tec = root.techType(tech) == "Suit" and player.getProperty("sb_bioimplant") or player.equippedTech(root.techConfig(tech).type)
    if tec ~= nil then
      if ownsTech() then
	local suit = root.techType(tech) == "Suit" and true
	if (tech ~= tec) then
	  activeItem.setInstanceValue("durabilityHit",0)
	  if not suit then
	    player.equipTech(tech)
	  else
	    world.sendEntityMessage(player.id(),"sb_implant",tech)
	  end
	  animator.playSound("success")
	else sb_uiMessage(9) end --wearing that
      else sb_uiMessage(5) end --does not own tech
    else if ownsTech() then player.equipTech(tech) activeItem.setInstanceValue("durabilityHit",0) animator.playSound("success") else sb_uiMessage(5) end end --not wearing, not owned
  else sb_uiMessage(3) end --does not exist
end

function ownsTech() return contains(player.enabledTechs(), tech) or contains(player.getProperty("sb_bioimplants",{}), tech) end