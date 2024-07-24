local originalInit = init or function() end

function init() originalInit()
  effect.addStatModifierGroup({{stat = config.getParameter("sb_stat", "maxHealth"), effectiveMultiplier = config.getParameter("sb_amount", 1.1)}})
end