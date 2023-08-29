local ini = init or function() end
local updat = update or function() end
--todo: sfx for bouncing?

function init() ini() rotationFrame = 1 end
function update(args) updat(args) end

function updateRotationFrame(dt)
  angle = math.fmod(math.pi * 2 + angle + angularVelocity * dt, math.pi * 2)

  local moving = angularVelocity
  if moving < 0 then moving = -moving end
  moving = moving > 2
  if moving then
    rotationFrame = math.floor(angle / math.pi * ballFrames) % ballFrames
  elseif rotationFrame ~= 0 then
    rotationFrame = math.floor(angle / math.pi * rotationFrame) % ballFrames
  end
  animator.setGlobalTag("rotationFrame", rotationFrame)
end