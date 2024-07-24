local sb_init = init or function() end

function init()
  sb_init()
  if config.getParameter("sb_hasRechargeAnimation") then
    tech.sb_setParentDirectives = tech.setParentDirectives
    tech.setParentDirectives = function(directives)
      tech.sb_setParentDirectives(directives)
      if (directives or 0) == self.rechargeDirectives then
        animator.setAnimationState("sb_recharge", "on")
      end
    end
  end
end