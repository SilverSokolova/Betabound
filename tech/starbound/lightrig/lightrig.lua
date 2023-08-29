require "/tech/sb_doubletap.lua"

function init()
  energyUsageRate = config.getParameter("energyUsageRate",0)
  maximumDoubleTapTime = config.getParameter("maxDoubleTapTime",0.2)
  directions = {"left","right","up","down"}
  timers = {
    up = 0,
    down = 0,
    left = 0,
    right = 0
  }
  activeLights = {
    up = false,
    down = false,
    left = false,
    right = false
  }
  inputs = {}
  lastInput = {}
  oppositeLight = {
    left = "right",
    right = "left"
  }

  doubleTap = DoubleTap:new({"left","right","up","down"}, config.getParameter("maxDoubleTapTime",0.2), function(dir)
    if not status.resourceLocked("energy") then
      activeLights[dir] = not activeLights[dir]
      animator.setLightActive("light"..dir, activeLights[dir])
      animator.playSound("toggle")
    end
  end)
end

function disableLights()
  for dir,_ in pairs(activeLights) do
    activeLights[dir] = false
    animator.setLightActive("light"..dir, false)
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

function update(args) doubleTap:update(args.dt,args.moves) input(args)
  local facing = mcontroller.facingDirection()
  for dir,action in pairs(activeLights) do
    if inputs[dir] then
      if facing < 0 and (dir == "left" or dir == "right") then
        activeLights[oppositeLight[dir]] = not activeLights[oppositeLight[dir]]
      else
        activeLights[dir] = not activeLights[dir]
      end
    end
  end

  local usedEnergy = 0
  for dir,light in pairs(activeLights) do
  if facing < 0 and (dir == "left" or dir == "right") then light = activeLights[oppositeLight[dir]] end
    if light then usedEnergy = usedEnergy + energyUsageRate * args.dt end
  end

  if not status.overConsumeResource("energy",usedEnergy) then
    disableLights()
  end
end