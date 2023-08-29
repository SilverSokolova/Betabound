--[[
I think the only thing left is to make it attack (if it ever did that)
Does repairEnd play?
Need to set animation on death?
]]

require "/scripts/companions/capturable.lua"
require "/scripts/drops.lua"
require "/scripts/status.lua"

function init()
  capturable.init()
  self.shouldDie = true
  self.sensors = sensors.create()

  self.state = stateMachine.create({
    "moveState",
    "repairState",
    "attackState"
  })

  self.damageTaken = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if status.resourcePositive("health") and notification.healthLost > 0 then
        self.damaged = true
        self.state.pickState(notification.sourceEntityId)
      end
    end
  end)

--self.state.leavingState = function(stateName)
--  if not mcontroller.running() and not animator.animationState("body"):find("repair") then
--    animator.setAnimationState("body", "idle")
--  end
--end

  message.setHandler("notify", function(_,_,notification)
    return notify(notification)
  end)

  message.setHandler("despawn", function()
    monster.setDropPool(nil)
    monster.setDeathParticleBurst(nil)
    monster.setDeathSound(nil)
    self.deathBehavior = nil
    self.shouldDie = true
    status.addEphemeralEffect("monsterdespawn")
  end)

  monster.setAggressive(false)
  monster.setDeathParticleBurst("deathPoof")
  animator.setAnimationState("body", "idle")

  repairStatusEffect = config.getParameter("repairStatusEffect")
  repairDistance = config.getParameter("repairDistance")
  attackTargetHoldTime = config.getParameter("attackTargetHoldTime")
  attackRange = config.getParameter("attackRange")
  repairResponseMaxDistance = config.getParameter("repairResponseMaxDistance")
  idleTimeRange = config.getParameter("idleTimeRange")
  moveTimeRange = config.getParameter("moveTimeRange")
  targetNoticeRadius = repairResponseMaxDistance
  selfId = entity.id()
end

function update(dt)
  animation = animator.animationState("body") --Have to do this here instead of in setAnimation because string:find doesn't return anything there for some ungodly reason
  capturable.update(dt)
local pos = entity.position()
  world.debugText("^shadow;"..animator.animationState("body"),{pos[1]-1,pos[2]+3},"green")
  world.debugText("^shadow;repairing: "..sb.print(animator.animationState("body"):find("repair")),{pos[1]-1,pos[2]+4},"orange")
  world.debugText("^shadow;attacking: "..sb.print(animator.animationState("body"):find("attack")),{pos[1]-1,pos[2]+5},"orange")
  world.debugText("^shadow;walking: "..sb.print(mcontroller.walking()),{pos[1]-1,pos[2]+6},"orange")
  world.debugText("^shadow;running: "..sb.print(mcontroller.running()),{pos[1]-1,pos[2]+7},"orange")
  local repairTargetId = repairState.findTarget()
  if repairTargetId ~= nil then
    self.state.pickState({repairTargetId = repairTargetId})
  end

  self.state.update(dt)
  self.sensors.clear()

  --self.state.leavingState just decided to stop working and i don't really care to find out why
  if not mcontroller.running() and not animator.animationState("body"):find("repair") then
    animator.setAnimationState("body", "idle")
  end
end

function isOnPlatform()
  return mcontroller.onGround() and
    not self.sensors.nearGroundSensor.collisionTrace.any(true) and
    self.sensors.midGroundSensor.collisionTrace.any(true)
end

function move(toTarget)
  setAnimation("move")

  if math.abs(toTarget[2]) < 4 and isOnPlatform() then
    mcontroller.controlDown()
  end

  mcontroller.controlMove(toTarget[1], true)
end

function setAnimation(desiredAnimation)
  --animator.animationState doesn't work here for some reason
  if animation == desiredAnimation then
    return true
  end

  if desiredAnimation == "attack" then
    if animation ~= "attack" and animation ~= "attackStart" then
      animator.setAnimationState("body", "attackStart")
      return true
    end
  elseif desiredAnimation == "repair" then
    if not animation:find("repair") then
      animator.setAnimationState("body", "repairStart")
      return true
    end
  else
    if animation == "attack" or animation == "attackStart" then
      animator.setAnimationState("body", "attackEnd")
      return true
   elseif animation == "repair" and not animation:find("repair") then
      animator.setAnimationState("body", "repair")
      return true
    elseif animation ~= "attackEnd" then
      animator.setAnimationState("body", desiredAnimation)
      return true
    end
  end

  return false
end


moveState = {}

function moveState.enter()
  return {
    timer = math.random(moveTimeRange[1], moveTimeRange[2]),
    direction = math.random(100) > 50 and 1 or -1
  }
end

function moveState.update(dt, stateData)
  if self.sensors.collisionSensors.collision.any(true) then
    stateData.direction = -stateData.direction
  end

  move({stateData.direction, 0})

  stateData.timer = stateData.timer - dt
  if stateData.timer <= 0 then
    return true, math.random(idleTimeRange[1], idleTimeRange[2])
  end

  return false
end

repairState = {}

function repairState.enterWith(targetId)
  return targetId
end

function repairState.update(dt, targetId)
  if type(targetId) ~= "number" then targetId = targetId.repairTargetId end

  local targetPosition = world.entityPosition(targetId)
  if targetPosition == nil then
    return setAnimation("move")
  end

  local targetHealthStatus = world.entityHealth(targetId)
  if targetHealthStatus[1] == 0 or targetHealthStatus[1] == targetHealthStatus[2] then
    return setAnimation("move")
  end

  local toTarget = world.distance(targetPosition, mcontroller.position())
  local animation = animator.animationState("body")
  if world.magnitude(toTarget) < repairDistance then
    if setAnimation("repair") then
      world.sendEntityMessage(targetId, "applyStatusEffect", repairStatusEffect)
    end
  else
    if setAnimation("move") then
      move(toTarget)
    end
  end

  return false
end

function repairState.findTarget()
  local entityIds = world.entityQuery(mcontroller.position(), repairResponseMaxDistance, {includedTypes = {"creature"}})

  for i, entityId in ipairs(entityIds) do
    if (entityId ~= selfId) and world.entityExists(entityId) and not world.entityCanDamage(selfId, entityId) then
      local healthStatus = world.entityHealth(entityId)
      if healthStatus[1] < healthStatus[2] then
        return entityId
      end
    end
  end

  return nil
end

attackState = {}

function attackState.enterWith(targetId)
  if targetId == nil then return nil end

  self.targetId = targetId
  return {timer = attackTargetHoldTime}
end

function attackState.update(dt, stateData)
  util.trackExistingTarget(targetNoticeRadius)

  monster.setAggressive(true)

  local shouldFire = false
  if self.targetPosition ~= nil then
    local toTarget = world.distance(self.targetPosition, mcontroller.position())
    local distance = world.magnitude(toTarget)

    if distance < attackRange[1] then
      if setAnimation("move") then
        move({-toTarget[1], 0})
      end
    elseif distance > attackRange[2] then
      if setAnimation("move") then
        move({toTarget[1], 0})
      end
    else
      mcontroller.controlFace(toTarget[1])
      if setAnimation("repair") then
        shouldFire = true
      end
    end
  end

  if self.targetId == nil then
    stateData.timer = stateData.timer - dt
  else
    stateData.timer = attackTargetHoldTime
  end

  if stateData.timer <= 0 then
    monster.setAggressive(false)
    return true
  else
    return false
  end
end

function shouldDie()
  return (self.shouldDie and status.resource("health") <= 0) or capturable.justCaptured
end

function die()
  if not capturable.justCaptured then
    if self.deathBehavior then
      self.deathBehavior:run(script.updateDt())
    end
    capturable.die()
  end
  spawnDrops()
end