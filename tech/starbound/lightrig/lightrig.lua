require "/tech/doubletap.lua"

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

  lastMoves = {}

  doubleTap = DoubleTap:new({"left", "right", "up", "down"}, maximumDoubleTapTime, function(dir)
    if timers[dir] <= 0 and not lastMoves[dir] and not status.resourceLocked("energy") then
      activeLights[dir] = not activeLights[dir]
      animator.setLightActive(dir .. "Light", activeLights[dir])
      animator.playSound("toggle")
      timers[dir] = maximumDoubleTapTime
      lastMoves[dir] = true
    end
  end)
end

function update(args); doubleTap:update(args.dt, args.moves)
  for dir, timer in pairs(timers) do
    if timers[dir] > 0 then
      timers[dir] = timer - args.dt
    end
  end

  local usedEnergy = 0
  for _, light in pairs(activeLights) do
    if light then
      usedEnergy = usedEnergy + energyUsageRate * args.dt
    end
  end

  if not status.overConsumeResource("energy", usedEnergy) then
    disableLights()
  end

  lastMoves = args.moves
end

function disableLights()
  for dir, _ in pairs(activeLights) do
    activeLights[dir] = false
    animator.setLightActive(dir .. "Light", false)
  end
end

function uninit()
  disableLights()
end