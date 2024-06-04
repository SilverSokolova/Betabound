local sb_activateVisualEffects = activateVisualEffects or function() end
function activateVisualEffects() sb_activateVisualEffects()
  if self.protectionBonus then
    effect.setParentDirectives(config.getParameter("sb_directives"))
  end
end