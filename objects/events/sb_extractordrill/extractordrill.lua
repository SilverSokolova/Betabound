require "/scripts/util.lua"

function init()
  animator.resetTransformationGroup("cog")
  animator.scaleTransformationGroup("cog", {4, 1})

  object.setInteractive(true)
  active = false
  raiseTime = config.getParameter("raiseTime")
  drillHeight = config.getParameter("drillHeight")
  holdTime = config.getParameter("holdTime")
  fallTime = config.getParameter("fallTime")
  hasDrilled = false
  ores = config.getParameter("ores")[world.type()]
  projectiles = config.getParameter("projectiles")
  drillCount = config.getParameter("drillCount")
  if type(drillCount) == "table" then
    drillCount = math.random(table.unpack(drillCount))
  end

  animator.setAnimationState("cog", "off")
  animator.setParticleEmitterActive("smoke", false)

  if ores then
    oreData = {}
    for i = 1, #ores do
      local itemData = root.itemConfig(ores[i])
      local icon = "/assetmissing"
      if type(itemData.config.inventoryIcon) == "string" then
        icon = itemData.config.inventoryIcon:sub(1, 1) == "/" and itemData.config.inventoryIcon or itemData.directory..itemData.config.inventoryIcon
      end
      
      if itemData then
        oreData[ores[i]] = {
          icon = icon,
          name = ores[i]
        }
      end
    end
    sb.logInfo(sb.printJson(oreData["money"], 1))
  end

  state = FSM:new()
  state:set(drillState)
end

function update()
  if drillCount > 0 and ores and active then
    state:update()
  end
end

function onInteraction()
  active = true
  object.setInteractive(false)
end

function drillState()
  while true do
    -- raise drill
    object.say("!")
    animator.setAnimationState("cog", "on")
    animator.setParticleEmitterActive("smoke", true)
    local timer = 0
    while timer < raiseTime do
      local height = drillHeight * timer / raiseTime
      animator.resetTransformationGroup("drill")
      animator.translateTransformationGroup("drill", {0, height})

      timer = timer + script.updateDt()
      coroutine.yield()
    end
    
    animator.resetTransformationGroup("drill")
    animator.translateTransformationGroup("drill", {0, drillHeight})
    animator.setAnimationState("cog", "off")
    animator.setParticleEmitterActive("smoke", false)

    util.wait(holdTime)

    local timer = 0
    while timer < fallTime do
      local ratio = (timer / fallTime) ^ 2
      local height = drillHeight - drillHeight * ratio
--      sb.logInfo("height: %s", height)
      animator.resetTransformationGroup("drill")
      animator.translateTransformationGroup("drill", {0, height})

      timer = timer + script.updateDt()
      coroutine.yield()
    end
    animator.burstParticleEmitter("smash")
    animator.burstParticleEmitter("smash2")
    animator.resetTransformationGroup("drill")
    for i = 1, #projectiles do
      for j = 1, 3 do
        local action = projectiles[i]
        local selectedOre = oreData[ores[math.random(#ores)]]
        action.config = {}
        action.config.actionOnReap = {
          {
            action = "item",
            name = selectedOre.name
          }
        }
        action.config.processing = "?setcolor=fff?replace;fff0=fff?blendmult="..selectedOre.icon
        world.spawnProjectile("invisibleprojectile", entity.position(), nil, nil, nil, {timeToLive = 0, actionOnReap = {action}})
      end
    end
    hasDrilled = true
    drillCount = drillCount - 1
    object.setConfigParameter("drillCount", drillCount)
    util.wait(holdTime)
  end
end

function die()
  if not hasDrilled then
    object.setConfigParameter("breakDropPool", "money")
  end
end