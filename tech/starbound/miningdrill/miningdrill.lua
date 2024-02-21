require "/scripts/vec2.lua"
require "/tech/sb_doubletap.lua"

function init()
  id = entity.id()
  radius = config.getParameter("blockRadius",2)
  damageType = config.getParameter("damageType","beamish")
  baseDamageAmount = config.getParameter("damageAmount",0.75)
  harvestLevel = config.getParameter("harvestLevel",99)
  energyUsageRate = config.getParameter("energyUsageRate",0)
  maximumDoubleTapTime = config.getParameter("maxDoubleTapTime",0.2)
  directions = {"left","right","up","down"}
  timers = {
    up = 0,
    down = 0,
    left = 0,
    right = 0
  }
  activeDrills = {
    up = false,
    down = false,
    left = false,
    right = false
  }
  drillPositions = config.getParameter("drillPositions")
  inputs = {}
  lastInput = {}
  oppositeDrill = {
    left = "right",
    right = "left"
  }

  doubleTap = DoubleTap:new({"left","right","up","down"}, config.getParameter("maxDoubleTapTime", 0.2), function(dir)
    if not status.resourceLocked("energy") then
      activeDrills[dir] = not activeDrills[dir]
      animator.setAnimationState("drill"..dir, activeDrills[dir] and "on" or "off")
      animator.playSound((activeDrills[dir] and "" or "de").."activate")
    end
  end)
end

function disableDrills()
  for dir, _ in pairs(activeDrills) do
    activeDrills[dir] = false
    animator.setAnimationState("drill"..dir, "off")
  end
end

function input(args)
  for dir,timer in pairs(timers) do
    if timers[dir] > 0 then timers[dir] = timer - args.dt end
    if (args.moves[dir] == true) and inputs[dir] and not lastInput[dir] then
      if inputs[dir] then
        if timers[dir] <= 0 then
          inputs[dir] = true
        else
          timers[dir] = maximumDoubleTapTime
        end
      end
      inputs[dir] = true
    else
      inputs[dir] = false
    end
  end
  lastInput = args.moves
end

function update(args) doubleTap:update(args.dt, args.moves) input(args)
  local facing = mcontroller.facingDirection()
  for dir, action in pairs(activeDrills) do
    if inputs[dir] then
      if facing < 0 and (dir == "left" or dir == "right") then
        activeDrills[oppositeDrill[dir]] = not activeDrills[oppositeDrill[dir]]
      else
        activeDrills[dir] = not activeDrills[dir]
      end
    end
  end

  local usedEnergy = 0
  for dir, drill in pairs(activeDrills) do
    if drill then
      usedEnergy = usedEnergy + energyUsageRate * args.dt
      local pos = mcontroller.position(); pos = vec2.add(pos, drillPositions[dir])
      local damageAmount = baseDamageAmount
      for i = 1, 2 do
        world.damageTileArea(pos, radius, (i == 1 and "fore" or "back").."ground", pos, damageType, damageAmount, harvestLevel, id)
      end
    end
  end

  if not status.overConsumeResource("energy", usedEnergy) then
    disableDrills()
  end
end

function uninit()
  disableDrills()
end