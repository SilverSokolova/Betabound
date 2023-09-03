local ini = init or function() end
local updat = update or function() end

function init() ini()
  sb_dir = "shop"..(object.direction() > 0 and "right" or "left")
  sb_justClosed = true
end

function update() updat()
  if #world.entityQuery(object.position(), 5, {includedTypes = {"creature"}}) > 0 then
    animator.setAnimationState(sb_dir, "open")
    sb_justClosed = false
  elseif not sb_justClosed then
    animator.setAnimationState(sb_dir, "close")
    sb_justClosed = true
  end
end