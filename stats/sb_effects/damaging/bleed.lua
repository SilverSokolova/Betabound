--disabled spurts because they're op with large amounts of health (ie: swansong)
function init()
	lastHealth = status.resource("health")
	if status.statusProperty("targetMaterialKind","") ~= "organic" then effect.expire() end --glitch and novas have red particles when hit. blood?? i guess this can also be internal bleeding. also this doesnt work for monsters??
	effect.modifyDuration(math.random(8))
--	spurt = math.random(5,10) + math.ceil(status.resourceMax("health")/40)
end

function update(dt)
	animator.setFlipped(mcontroller.facingDirection()<0)
--	if spurt > 0 then status.modifyResource("health",-(spurt/10)) spurt=spurt-1 end
	status.modifyResource("health",-0.01)
	animator.setParticleEmitterEmissionRate("blood",3+effect.duration())
	if lastHealth < status.resource("health") then effect.modifyDuration(-0.3) end
	lastHealth = status.resource("health")
end