local originalInit = init or function() end
local originalUpdate = update or function() end

function init() originalInit()
  sb_dir = "shop"..(object.direction() > 0 and "right" or "left")
  animator.setAnimationState(sb_dir, "close")
  sb_justClosed = true
end

function update() originalUpdate()
  if #world.entityQuery(object.position(), 5, {includedTypes = {"creature"}}) > 0 then
    animator.setAnimationState(sb_dir, "open")
    sb_justClosed = false
  elseif not sb_justClosed then
    animator.setAnimationState(sb_dir, "close")
    sb_justClosed = true
  end
end