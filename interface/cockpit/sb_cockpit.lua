require "/scripts/sb_assetmissing.lua"
local ini = init

function init() ini()
  if root.assetJson("/betabound.config:fuelScaling") and not sb_hasOtherFuelScalingMod() then
    sb_jumpFuelCostCap = config.getParameter("sb_jumpFuelCostCap")
    --sb_fuelJumpCostDivision = config.getParameter("sb_fuelJumpCostDivision")
    config.sb_getParameter = config.getParameter
    config.getParameter = function(parameter, default)
      if parameter == "jumpFuelCost" then
        local current = celestial.currentSystem().location
        local dest = self.travel.system
        if not dest then dest = dest or sb_travel or self.travel.system end
        sb_travel = self.travel.system or dest
        local distanceCost = math.sqrt(((current[1] - dest[1]) ^ 2) + ((current[2] - dest[2]) ^ 2))
        return math.min(config.sb_getParameter(parameter, default) + distanceCost, sb_jumpFuelCostCap)
      else
        return config.sb_getParameter(parameter, default)
      end
    end
  end
end

function sb_hasOtherFuelScalingMod()
  local items = config.getParameter("sb_fuelScalingModItems")
  local valid = false
  for i = 1, #items do
    if sb_itemExists(items[i]) then
      valid = true
      break
    end
  end
  return valid
end