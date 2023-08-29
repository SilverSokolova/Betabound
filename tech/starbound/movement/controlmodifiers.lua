function init() a=config.getParameter("controlModifiers") end
function update(dt) mcontroller.controlModifiers(a) end