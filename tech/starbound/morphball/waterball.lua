local originalInit = init or function() end
local originalInput = input or function() end
local originalUpdate = update or function() end

function init() originalInit()
  rotationFrame = 1
  unmovingRotationFrameCounter = 0
  playedSplashSound = false
  transformedStats = config.getParameter("transformedStats")
end

function input(args)
  local result = originalInput(args)
  return (result and active and result == "groundsmash" and "groundsmash")
end

function update(...) originalUpdate(...)
  if active then
    status.setPersistentEffects("sb_waterball", transformedStats)
  else
    status.clearPersistentEffects("sb_waterball")
  end
end

function updateRotationFrame(dt)
  angle = math.fmod(math.pi * 2 + angle + angularVelocity * dt, math.pi * 2)

  local moving = angularVelocity
  if moving < 0 then moving = -moving end
  moving = moving > 1
  if moving then
    unmovingRotationFrameCounter = 0
    rotationFrame = math.floor(angle / math.pi * ballFrames) % ballFrames
    if rotationFrame == 3 then --Bit unreliable at fast speeds, but randomizing it leads to spam
      if not playedSplashSound and mcontroller.onGround() then
        playedSplashSound = true
        animator.playSound("splash")
      end
    else
      playedSplashSound = false
    end
  --This handles the ball regaining its shape after being stationary 
  elseif rotationFrame ~= 0 and rotationFrame ~= 2 then --Frames 0 and 2 are its 'default' shape, and snapping from 0 or 2 or vice versa looks weird 
    unmovingRotationFrameCounter = unmovingRotationFrameCounter + (dt * 3)
    rotationFrame = rotationFrame == 1 and (math.random(2) == 1 and 0 or 2) or (rotationFrame + math.floor(unmovingRotationFrameCounter)) % ballFrames
  end
  animator.setGlobalTag("rotationFrame", rotationFrame)
end