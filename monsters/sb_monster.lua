local originalInit = init or function() end

function init() originalInit()
  --Initial status effects. Temporary innate status effects
  sb_initialStatusEffects = config.getParameter("sb_initialStatusEffects")
  if sb_initialStatusEffects and not status.statusProperty("sb_appliedInitialStatusEffects") then
    status.setStatusProperty("sb_appliedInitialStatusEffects", true)
    status.addEphemeralEffects(sb_initialStatusEffects)
  end

  sb_repeatingInitialStatusEffects = config.getParameter("sb_repeatingInitialStatusEffects")
  if sb_repeatingInitialStatusEffects then
    status.addEphemeralEffects(sb_repeatingInitialStatusEffects)
  end
end