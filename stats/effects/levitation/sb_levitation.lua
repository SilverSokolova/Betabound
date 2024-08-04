local originalActivateVisualEffects = activateVisualEffects or function() end
function activateVisualEffects() originalActivateVisualEffects()
  if self.protectionBonus then
    effect.setParentDirectives(config.getParameter("sb_directives"))
  end
end