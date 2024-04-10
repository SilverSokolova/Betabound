local sb_activateVisualEffects = activateVisualEffects or function() end
function activateVisualEffects() sb_activateVisualEffects()
  local directives = config.getParameter("sb_directives")
  if self.protectionBonus then
    effect.setParentDirectives(directives)
  end
end