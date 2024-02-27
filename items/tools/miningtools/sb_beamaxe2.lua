require "/scripts/vec2.lua"
function init()
  id = activeItem.ownerEntityId()
  radius = config.getParameter("blockRadius")
  altRadius = config.getParameter("altBlockRadius")
  harvestLevel = config.getParameter("harvestLevel", 99)
  storedLiquids = config.getParameter("storedLiquids")
--range = config.getParameter("interactRadius",root.assetJson("/player.config:interactRadius") or 5) + status.statusProperty("bonusBeamGunRadius",0)
--inRange = false

  magnetEnabled = config.getParameter("magnetEnabled", true)
  liquidEnabled = config.getParameter("canCollectLiquid", false)
--lightEnabled = config.getParameter("lightEnabled",true)

  firePosition = config.getParameter("firePosition", {0, 0})
  notifyTime = config.getParameter("notifyEntityTime")
  notifyTimer = 0
  notifyDamage = ((config.getParameter("tileDamage") / config.getParameter("fireTime") * notifyTime) + 0.5) * 1.1
  notifyQueryParams = {
    includedTypes = {"vehicle"},
    boundMode = "position"
  }

  if magnetEnabled then
    magnet = config.getParameter("magnet")
    magnet.length = radius * 2.5 + magnet.length
    vacuum = {}
    for i = 1, magnet.length do
      vacuum[i] = {
        type = "RadialForceRegion",
        categoryWhitelist = magnet.categoryWhitelist,
        innerRadius = 0,
        outerRadius = magnet.length - i * 0.25, --I'd love to divide this by 2 but then it gets wonky at certain diagonal angles
        controlForce = math.max(50, 500 - (i * 50)),
        targetRadialVelocity = -20,
        center = {(i - 3) * 1.5, 0}
      }
    end
    vacuum[1].outerRadius = 2
    vacuum[1].center[1] = 0
    vacuum[1].targetRadialVelocity = vacuum[1].targetRadialVelocity * 2
    activeItem.setItemForceRegions(vacuum)
  end
end

function update(dt, fireMode, shifting)
  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(firePosition[2], activeItem.ownerAimPosition())
  activeItem.setArmAngle(aimAngle)
  activeItem.setFacingDirection(aimDirection or 0)
  activeItem.setScriptedAnimationParameter("radius", shifting and altRadius or radius)

--inRange = world.magnitude(mcontroller.position(), activeItem.ownerAimPosition()) <= range
--activeItem.setScriptedAnimationParameter("inRange", inRange)
--if inRange then
  if fireMode ~= "none" then
    world.damageTiles(shifting and fillRadius(altRadius) or fillRadius(radius),
      fireMode == "alt" and "background" or "foreground",
      activeItem.ownerAimPosition(),
      "beamish",
      notifyDamage * ((shifting and 1 + radius - altRadius) or 1), --this would be fine if a radius of 2 meant 2 blocks, but it means 4 blocks
      harvestLevel,
      id
    )
  end

  if fireMode == "primary" then
    if liquidEnabled then
      local area = shifting and fillRadius(altRadius) or fillRadius(radius)
      for n = 1, #area do
        local liquid = world.destroyLiquid(area[n])
        if liquid then
          if root.liquidConfig(liquid[1]) then
            if liquid[2] == 1 then
              giveLiquid(liquid[1])
            else
              updateStoredLiquids(liquid)
            end
          end
        end
      end
    end
    notifyTimer = math.max(0, notifyTimer - dt)
    if notifyTimer == 0 then
      notifyTimer = notifyTime
      notifyEntities(shifting)
    end
  else
    notifyTimer = 0
  end
end

function notifyEntities(shifting)
  local entities = world.entityQuery(activeItem.ownerAimPosition(), shifting and altRadius or radius, notifyQueryParams)
  for _, entityId in ipairs(entities) do
    world.sendEntityMessage(entityId, "positionTileDamaged", notifyDamage)
  end
end

function fillRadius(radius)
  local base = activeItem.ownerAimPosition()
  base[1] = math.floor(base[1])
  base[2] = math.floor(base[2])

  if radius == 1 then
    return {base} 
  end

  if radius % 2 == 0 then
    base = {base[1] + 0.4, base[2] + 0.4}
  end

  local tiles = {}
  for x = 1, radius do
    for y = 1, radius do
      tiles[#tiles + 1] = {base[1] - (radius / 2) + x, base[2] - (radius / 2) + y} 
    end
  end
  return tiles
end

function giveLiquid(id, quantity)
  local itemDrop = root.liquidConfig(id).config
  if itemDrop then
    itemDrop = itemDrop.itemDrop
    if itemDrop then
      player.giveItem({name=itemDrop, count=quantity})
    end
  end
end

function updateStoredLiquids(liquid)
  storedLiquids[liquid[1]] = (storedLiquids[liquid[1]] or 0) + liquid[2]
  local liquidQuantity = storedLiquids[liquid[1]]
  if liquidQuantity >= 1 then
    local integerQuantity = math.floor(liquidQuantity)
    giveLiquid(liquid[1], integerQuantity)
    liquidQuantity = liquidQuantity - integerQuantity
    storedLiquids[liquid[1]] = liquidQuantity
  end
  activeItem.setInstanceValue("storedLiquids", storedLiquids)
end