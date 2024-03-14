--this and the animation patch can be safely removed
local ini = init or function() end
function init() ini()
     local races = {"apex","floran","floran","human","floran","floran"}
     local chosen = config.getParameter("sb_terramartRace",races[math.random(1,#races)])
     object.setConfigParameter("sb_terramartRace",chosen)
     local dir = object.direction() > 0 and "right" or "left"
     animator.setAnimationState(chosen..dir, "on")
end