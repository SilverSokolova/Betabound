local ini = init or function() end
local updat = update or function() end

function init() ini()
  effect.addStatModifierGroup({{stat = config.getParameter("sb_stat", "maxHealth"), effectiveMultiplier = config.getParameter("sb_amount", 1.1)}})
end

function update(...) updat(...)
  if status.uniqueStatusEffectActive("foodpoison") then
    effect.expire()
  end
end