local originalInit = init or function() end

function init() originalInit()
  rotationFrame = 1
  playedSplashSound = false
end

function updateRotationFrame(dt)
  angle = math.fmod(math.pi * 2 + angle + angularVelocity * dt, math.pi * 2)

  local moving = angularVelocity
  if moving < 0 then moving = -moving end
  moving = moving > 2
  if moving then
    rotationFrame = math.floor(angle / math.pi * ballFrames) % ballFrames
    if rotationFrame == 3 then
      if not playedSplashSound and mcontroller.onGround() then
        playedSplashSound = true
        animator.playSound("splash")
      end
    else
      playedSplashSound = false
    end
  elseif rotationFrame ~= 0 then
    rotationFrame = math.floor(angle / math.pi * rotationFrame) % ballFrames
  end
  animator.setGlobalTag("rotationFrame", rotationFrame)
end