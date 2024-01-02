require "/scripts/sb_assetmissing.lua"
local ini = init

function init() ini()
  if root.assetJson("/betabound.config:fuelScaling") and not sb_itemExists("ceftlthruster") and not sb_itemExists("fu_carbon") then
    sb_jumpFuelCostCap = config.getParameter("sb_jumpFuelCostCap")
    sb_fuelJumpCostDivision = config.getParameter("sb_fuelJumpCostDivision")
    config.sb_getParameter = config.getParameter
    config.getParameter = function(parameter, default)
      if parameter == "jumpFuelCost" then
        local current = celestial.currentSystem().location
        local dest = sb_travel or self.travel.system
        sb_travel = dest
        return math.min(config.sb_getParameter(parameter, default) + math.sqrt(((dest[1] - current[1]) ^ 2) + ((dest[2] - current[2]) ^ 2)), sb_jumpFuelCostCap)
      else
        return config.sb_getParameter(parameter, default)
      end
    end
  end
end