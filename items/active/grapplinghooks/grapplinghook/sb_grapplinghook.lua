local ini = init or function() end
local updat = update or function() end

function init()
  sb_hasHook = root.assetJson("/items/active/grapplinghooks/grapplinghook/grapplinghook.animation").animatedParts.stateTypes.sb_hook and true
  ini()
end

function update(...)
  updat(...)
  if sb_hasHook then
    animator.setAnimationState("sb_hook", self.projectileId and "off" or "on")
  end
end