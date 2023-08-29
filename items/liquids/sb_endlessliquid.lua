function init() maxStack = config.getParameter("maxStack",1000) end
function update() item.setCount(maxStack) end