local updateShipUpgrade = updateShipUpgrades
function updateShipUpgrades() if updateShipUpgrade then updateShipUpgrade() end
  local ship = player.getProperty("betabound",{}).ship
  if ship then
    local upgrades = player.shipUpgrades()
    for k, v in pairs(ship) do
      if type(ship[k]) ~= "table" and upgrades[k] < v then ship[k] = v end
    end
  player.upgradeShip(ship)
  end
end