require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit() sb_cursor("power")
  upgradeName = config.getParameter("customUpgradeID", config.getParameter("itemName"))
  onlyOnce = config.getParameter("onlyOnce", true)
end

function swingAction()
  local betabound = player.getProperty("betabound", {})
  local upgrades = betabound.shipUpgrades or {}

  if contains(upgrades, upgradeName) and onlyOnce then
    sb_uiMessage("upgradeApplied")
    return
  end

  local upgrade, ship = config.getParameter("shipUpgrade", {}), player.shipUpgrades()
  if config.getParameter("additive", true) then
    for k, v in pairs(upgrade) do upgrade[k] = ship[k] + v end
  end

  if onlyOnce then
    if #upgrades == 0 then
      upgrades = {upgradeName}
    else
      upgrades[#upgrades+1] = upgradeName
    end
  end

  player.setProperty("betabound", sb.jsonMerge(betabound, {ship = sb.jsonMerge(betabound.ship, upgrade), shipUpgrades = upgrades}))
  animator.playSound("success")
  player.upgradeShip(upgrade)
  item.consume(1)
end