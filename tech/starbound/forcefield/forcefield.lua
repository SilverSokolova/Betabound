function init()
  effect.setParentDirectives(config.getParameter("directives"))
  status.setResource("sb_forceFieldStrength",config.getParameter("forceFieldStrength"))
end

function uninit()
  status.setResource("sb_forceFieldStrength",0)
end