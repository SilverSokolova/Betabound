require "/scripts/vec2.lua"

function init()
  local pos = entity.position()
  inputPosition = vec2.add(vec2.add(config.getParameter("inputPosition"), pos), {0.5, 0.5})
  outputPosition = vec2.add(vec2.add(config.getParameter("outputPosition"), pos), {0.5, 0.5})

  if object.direction() < 0 then
    inputPosition, outputPosition = outputPosition, inputPosition
  end

  pumpTimer = 0
  pumpFrequency = config.getParameter("pumpFrequency", 0.25)

  storage.pumping = storage.pumping or true
end

function update(dt)
  world.debugPoint(inputPosition, "blue")
  world.debugPoint(outputPosition, "green")

  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
    storage.pumping = object.getInputNodeLevel(0)
  else
    object.setInteractive(true)
  end

  local pumpAnimationState = storage.pumping and ((world.liquidAt(inputPosition) and not world.pointCollision(outputPosition)) and "pump" or "error") or "idle"
  animator.setAnimationState("pumping", pumpAnimationState)
  object.setOutputNodeLevel(0, pumpAnimationState == "pump")

  pumpTimer = math.max(0, pumpTimer - dt)
  if storage.pumping and pumpTimer == 0 then
    local liquid = world.liquidAt(inputPosition)
    if liquid and not world.pointCollision(outputPosition) then
      world.destroyLiquid(inputPosition)
      world.spawnLiquid(outputPosition, table.unpack(liquid))
    end
    pumpTimer = pumpFrequency
  end
end

function onInteraction(args)
  storage.pumping = not storage.pumping
  animator.playSound("switch")
end
--bioluminescent