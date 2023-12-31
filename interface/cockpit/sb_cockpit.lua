local ini = init

function init() ini()
  sb_jumpFuelCostCap = config.getParameter("sb_jumpFuelCostCap")
  sb_fuelJumpCostDivision = config.getParameter("sb_fuelJumpCostDivision")
  config.sb_getParameter = config.getParameter
  config.getParameter = function(parameter, default)
    if parameter == "jumpFuelCost" then
      local current = celestial.currentSystem().location
      local dest = self.travel.system
      local distanceCost = math.sqrt((dest[1] - current[1]) ^ 2, (dest[2] - current[2]) ^ 2) / sb_fuelJumpCostDivision
      return math.min(config.sb_getParameter(parameter, default) + distanceCost, sb_jumpFuelCostCap)
    else
      return config.sb_getParameter(parameter, default)
    end
  end
end