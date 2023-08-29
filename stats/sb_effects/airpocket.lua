local liquidPercentage, addEphemeralEffects
function init()
  effects = config.getParameter("effects",{})
  liquidPercentage = mcontroller.liquidPercentage
  addEphemeralEffects = status.addEphemeralEffects
end
function update() if liquidPercentage() < 0.5 then addEphemeralEffects(effects) end end