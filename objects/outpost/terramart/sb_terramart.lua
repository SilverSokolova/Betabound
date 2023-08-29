local ini = init or function() end
function init() ini()
     local races = {"apex","avian","glitch","human","floran","hylotl"}
     local chosen = config.getParameter("sb_terramartRace",races[math.random(1,#races)])
     object.setConfigParameter("sb_terramartRace",chosen)
     local dir = object.direction() > 0 and "right" or "left"
     animator.setAnimationState(chosen..dir, "on")
end