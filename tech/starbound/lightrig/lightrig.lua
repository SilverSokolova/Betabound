require "/tech/sb_doubletap.lua"

function init()
  energyUsageRate = config.getParameter("energyUsageRate", 0)
  maximumDoubleTapTime = config.getParameter("maxDoubleTapTime", 0.2)

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
  lastMoves = {}

  doubleTap = DoubleTap:new({"left", "right", "up", "down"}, maximumDoubleTapTime, function(dir)
    if not status.resourceLocked("energy") then
      activeLights[dir] = not activeLights[dir]
      animator.setLightActive(dir.."Light", activeLights[dir])
      animator.playSound("toggle")
    end
  end)
end

function input(args)
  for dir, timer in pairs(timers) do
    if timers[dir] > 0 then
      timers[dir] = timer - args.dt
    end

    if (args.moves[dir] == true) and inputs[dir] and not lastMoves[dir] then
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
  lastMoves = args.moves
end

function update(args); doubleTap:update(args.dt, args.moves); input(args)
  local numActiveLights = 0
  for dir, active in pairs(activeLights) do
    if inputs[dir] then
      activeLights[dir] = not activeLights[dir]
    end

    if activeLights[dir] then
      numActiveLights = numActiveLights + 1
    end
  end

  local usedEnergy = 0
  for _, light in pairs(activeLights) do
    if light then usedEnergy = usedEnergy + energyUsageRate * args.dt end
  end

  if not status.overConsumeResource("energy", usedEnergy) then
    disableLights()
  end
end

function disableLights()
  for dir, _ in pairs(activeLights) do
    activeLights[dir] = false
    animator.setLightActive(dir.."Light", false)
  end
end

function uninit()
  disableLights()
end