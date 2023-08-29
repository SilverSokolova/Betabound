local ini = init or function() end
function init() ini()
	local i = config.getParameter("interactData")
	local r = config.getParameter("sb_treasuredtrophies")
	for n = 1, #r do
		if world.universeFlagSet(r[n]) then
			i.filter[#i.filter+1] = "sb_treasuredtrophies_"..r[n]
		end
	end
	object.setConfigParameter("interactData",i)
	object.setConfigParameter("sb_treasuredtrophies",{}) --this is to stop that issue caused by using groundfirebombs a specific distance away. Yes, that's how you trigger it. Why do you think it went unnoticed for so long?
end