require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit() sb_cursor("power")
  itemName = config.getParameter("itemName")..config.getParameter("customUpgradeID","")
  onlyOnce = config.getParameter("onlyOnce",true)
end

function swingAction()
  if hasUpgrade() and onlyOnce then sb_uiMessage("enhancementApplied") return end
  local upgrade, ship = config.getParameter("shipUpgrade",{}), player.shipUpgrades()
  if config.getParameter("additive",true) then
    for k, v in pairs(upgrade) do upgrade[k] = ship[k] + v end
  end
  if onlyOnce then
    local upgrades = player.getProperty("sb_shipUpgrades",{})
    if #upgrades == 0 then
      player.setProperty("sb_shipUpgrades",{itemName})
    else
      upgrades[#upgrades+1] = itemName
      player.setProperty("sb_shipUpgrades",upgrades)
    end
    local betabound = player.getProperty("betabound",{})
    player.setProperty("betabound",sb.jsonMerge(betabound,{ship=sb.jsonMerge(betabound.ship,upgrade)}))
  end
  animator.playSound("success")
  player.upgradeShip(upgrade)
  item.consume(1)
end

function hasUpgrade() return contains(player.getProperty("sb_shipUpgrades",{}),itemName) end