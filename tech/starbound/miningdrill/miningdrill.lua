require "/scripts/vec2.lua"

function init()
  radius = config.getParameter("blockRadius", 2)
  damageType = config.getParameter("damageType", "beamish")
  damageAmount = config.getParameter("damageAmount", 0.75)
  harvestLevel = config.getParameter("harvestLevel", 99)
  energyUsageRate = config.getParameter("energyUsageRate", 0)
  drillPositions = config.getParameter("drillPositions")

  entityId = entity.id()
  drills = {
    up = false,
    down = false,
    left = false,
    right = false
  }
  lastMoves = {}
end

function update(args)
  local usedEnergy = 0
  local position = mcontroller.position()
  for dir, active in pairs(drills) do
    if args.moves["special1"] and args.moves[dir] and not lastMoves[dir] then
      toggleDrill(dir)
    end

    if active then
      usedEnergy = usedEnergy + energyUsageRate * args.dt
      local drillPosition = vec2.add(position, drillPositions[dir])

      world.damageTileArea(drillPosition, radius, "foreground", drillPosition, damageType, damageAmount, harvestLevel, entityId)
      world.damageTileArea(drillPosition, radius, "background", drillPosition, damageType, damageAmount, harvestLevel, entityId)
    end
  end

  if not status.overConsumeResource("energy", usedEnergy) then
    disableDrills()
  end

  lastMoves = args.moves
end

function toggleDrill(dir)
  local drillState = drills[dir]
  if not status.resourceLocked("energy") then
    drills[dir] = not drillState
    animator.setAnimationState(dir.."Drill", drillState and "off" or "on")
    animator.playSound((drillState and "de" or "").."activate")
  end
end

function disableDrills()
  for dir, _ in pairs(drills) do
    drills[dir] = false
    animator.setAnimationState(dir.."Drill", "off")
  end
end

function uninit()
  disableDrills()
end