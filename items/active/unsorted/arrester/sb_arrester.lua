require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/activeitem/stances.lua"
require "/scripts/status.lua"

function init()
  entityId = entity.id()
  targetInnerRadius = config.getParameter("targetInnerRadius")
  targetOuterRadius = config.getParameter("targetOuterRadius")
  targetRange = config.getParameter("targetRange")
  increaseRate = config.getParameter("increaseRate")
  decreaseRate = config.getParameter("decreaseRate")
  minArrestFactor = config.getParameter("minArrestFactor")
  damageInterruptFactor = config.getParameter("damageInterruptFactor")
  energyUsage = config.getParameter("energyUsage")

  beepPitchRange = {1.0, 2.0}
  beepTime = 0.15
  beepTimer = 0

  arrestStatus = nil
  arrestProgress = 0

  initStances()
  setStance("idle")

  activeItem.setCursor("/cursors/reticle0.cursor")

  damageListener = damageListener("damageTaken", function(notifications)
    if arrestStatus == "active" then
      for _,notification in pairs(notifications) do
        arrestProgress = math.max(0, arrestProgress - notification.damageDealt * damageInterruptFactor)
      end
    end
  end)
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

  if not arrestStatus then
    if fireMode == "primary" and lastFireMode ~= "primary" and not status.resourceLocked("energy") then
      if findTarget() then
        startArrest()
      else
        animator.playSound("noTarget")
      end
    end
  elseif arrestStatus == "active" then
    if fireMode == "primary" then
      local targetRadius = checkTargetRadius()
      local arrestRatio, arrestRadius = arrestRatioAndRadius()
      if targetRadius and targetRadius <= arrestRadius * 1.41 then
        beepTimer = beepTimer - dt
        if beepTimer <= 0 then
          beepTimer = beepTime
          animator.setSoundPitch("beep", util.lerp(arrestRatio, beepPitchRange[1], beepPitchRange[2]))
          animator.playSound("beep")
        end
        increaseArrest(dt)
      else
        failArrest()
      end
    else
      failArrest()
    end
  elseif arrestStatus == "success" then
  elseif arrestStatus == "failure" then
  end

  damageListener:update()

  local arrestRatio, arrestRadius = arrestRatioAndRadius()
  activeItem.setScriptedAnimationParameter("arrestStatus", arrestStatus)
  activeItem.setScriptedAnimationParameter("arrestTarget", target)
  activeItem.setScriptedAnimationParameter("arrestRatio", arrestRatio)
  activeItem.setScriptedAnimationParameter("arrestRadius", arrestRadius)

  updateAim()

  if (self.aimDirection < 0) == (activeItem.hand() == "primary") then
    animator.setGlobalTag("hand", "front")
    activeItem.setOutsideOfHand(true)
  else
    animator.setGlobalTag("hand", "back")
    activeItem.setOutsideOfHand(false)
  end

  animator.setAnimationState("arrestState", arrestStatus == "active" and "active" or "idle")

  lastFireMode = fireMode
end

function findTarget()
  local pos = mcontroller.position()
  local cursorPosition = activeItem.ownerAimPosition()
  local candidates = world.entityQuery(cursorPosition, targetOuterRadius, {boundMode = "position", includedTypes = {"creature"}, order = "nearest"})
  for _, e in pairs(candidates) do
    if entity.isValidTarget(e) then
      if world.entityCanDamage(entityId, e) then
        local ePos = world.entityPosition(e)
        if world.magnitude(pos, ePos) <= targetRange then
          target = e
          return true
        end
      end
    end
  end

  return false
end

function checkTargetRadius()
  if target and world.entityExists(target) then
    local pos = mcontroller.position()
    local targetPosition = world.entityPosition(target)
    if world.magnitude(pos, targetPosition) <= targetRange and not world.lineCollision(pos, targetPosition) then
      local cursorPosition = activeItem.ownerAimPosition()
      return world.magnitude(targetPosition, cursorPosition)
    end
  end

  return false
end

function arrestRatioAndRadius()
  if arrestProgress > 0 then
    local arrestRatio = arrestProgress / arrestAmount
    local arrestRadius = util.lerp(arrestRatio ^ 2, targetOuterRadius, targetInnerRadius)
    return arrestRatio, arrestRadius
  else
    return 0, targetOuterRadius
  end
end

function startArrest()
  arrestStatus = "active"
  arrestProgress = 0
  setStance("active")

  local targetHealth = world.entityHealth(target)
--arrestAmount = math.min(targetHealth[1], targetHealth[2] * minArrestFactor)
  arrestAmount = targetHealth[1] * minArrestFactor

  world.sendEntityMessage(target, "applyStatusEffect", "arresting", nil, entity.id())
  world.sendEntityMessage(target, "notify", {type = "arresting", sourceId = activeItem.ownerEntityId()})
end

function increaseArrest(dt)
  arrestProgress = math.min(arrestAmount, arrestProgress + increaseRate * dt)

  status.overConsumeResource("energy", energyUsage * dt)

  if arrestProgress == arrestAmount then
    succeedArrest()
  else
    activeItem.setCursor("/cursors/charge2.cursor")
    world.sendEntityMessage(target, "applyStatusEffect", "arresting", nil, entity.id())
  end
end

function decreaseArrest(dt)
  arrestProgress = math.max(0, arrestProgress - decreaseRate * dt)

  if arrestProgress == 0 then
    reset()
  end
end

function succeedArrest()
  world.sendEntityMessage(target, "applyStatusEffect", "techstun", 8, entity.id())
  arrestStatus = "success"
  setStance("success")
  activeItem.setCursor("/cursors/chargeready.cursor")
  animator.playSound("arrestSuccess")
end

function failArrest()
  arrestStatus = "failure"
  setStance("failure")
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.playSound("arrestFailure")
end

function reset()
  target = nil
  arrestStatus = nil
  arrestProgress = 0
  activeItem.setCursor("/cursors/reticle0.cursor")
  beepTimer = 0
  animator.setSoundPitch("beep", beepPitchRange[1])
end