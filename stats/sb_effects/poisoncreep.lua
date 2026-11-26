function init()
  if not status.statPositive("sb_poisoncreepImmunity") then
    status.addEphemeralEffect(config.getParameter("poisonEffect"))
  end
  effect.expire()
end