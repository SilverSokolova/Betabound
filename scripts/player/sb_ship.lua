local originalUpdateShipUpgrades = updateShipUpgrades or function() end
function updateShipUpgrades(); originalUpdateShipUpgrades()
  local ship = player.getProperty("betabound",{}).ship
  if ship then
    local upgrades = player.shipUpgrades()
    for k, v in pairs(ship) do
      if type(ship[k]) ~= "table" and upgrades[k] < v then
        ship[k] = v
      end
    end
    player.upgradeShip(ship)
  end
end