function init()
	if entity.entityType() ~= "player" then effect.expire() return end
	food = config.getParameter("resource","food")
	wellfed = config.getParameter("effect","wellfed")
	if status.isResource(food) then
		if status.resourceMax(food) < effect.duration() + status.resource(food) then status.addEphemeralEffect(wellfed) end
		status.modifyResource(food,effect.duration())
	else status.addEphemeralEffect(wellfed) end
	effect.expire()
	update=updat updat=nil
end
function updat() effect.expire() end