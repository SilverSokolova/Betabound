function init()
	owner = config.getParameter("owner")
	text = config.getParameter("text")
	status.setResource("health",root.assetJson("/interface/windowconfig/chatbubbles.config:maxAge"))
	message.setHandler("despawn",function()
		status.setResource("health",0)
		self.shouldDie=true
		status.addEphemeralEffect("monsterdespawn")
	end)
end

function update()
	monster.say(text) --doing this here because it doesn't work in init. cant even add a bool for spoken
	if not world.entityExists(owner) then
		suicide()
	else
		mcontroller.setPosition(world.entityPosition(owner))
	end
	status.modifyResource("health",-0.1)
end

function suicide() status.setResource("health",0) end