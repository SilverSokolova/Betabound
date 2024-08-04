local originalInit = init or function() end

function init()
  originalInit()
  if config.getParameter("sb_hasRechargeAnimation") then
    tech.sb_setParentDirectives = tech.setParentDirectives
    tech.setParentDirectives = function(directives)
      if (directives or 0) == self.rechargeDirectives then
        animator.setAnimationState("sb_recharge", "on")
      end
      return tech.sb_setParentDirectives(directives)
    end
  end
end