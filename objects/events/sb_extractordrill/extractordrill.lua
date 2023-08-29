require "/scripts/util.lua"

function init()
  animator.resetTransformationGroup("cog")
  animator.scaleTransformationGroup("cog", {4.0, 1.0})

  raiseTime = config.getParameter("raiseTime")
  drillHeight = config.getParameter("drillHeight")
  holdTime = config.getParameter("holdTime")
  fallTime = config.getParameter("fallTime")

  state = FSM:new()
  state:set(drillState)
end

function update()
  state:update()
end

function drillState()
  while true do
    -- raise drill
    animator.setAnimationState("cog", "on")
    animator.setParticleEmitterActive("smoke", true)
    local timer = 0.0
    while timer < raiseTime do
      local height = drillHeight * timer / raiseTime
      animator.resetTransformationGroup("drill")
      animator.translateTransformationGroup("drill", {0.0, height})

      timer = timer + script.updateDt()
      coroutine.yield()
    end
    
    animator.resetTransformationGroup("drill")
    animator.translateTransformationGroup("drill", {0.0, drillHeight})
    animator.setAnimationState("cog", "off")
    animator.setParticleEmitterActive("smoke", false)

    util.wait(holdTime)

    timer = 0.0
    while timer < fallTime do
      local ratio = (timer / fallTime) ^ 2
      local height = drillHeight - drillHeight * ratio
--      sb.logInfo("height: %s", height)
      animator.resetTransformationGroup("drill")
      animator.translateTransformationGroup("drill", {0.0, height})

      timer = timer + script.updateDt()
      coroutine.yield()
    end
    animator.burstParticleEmitter("smash")
    animator.burstParticleEmitter("smash2")
    animator.resetTransformationGroup("drill")

    util.wait(holdTime)
  end
end