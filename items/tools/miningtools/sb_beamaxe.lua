function init()
  magnet = world.spawnProjectile("sb_beamaxemagnet",fireableItem.ownerAimPosition(),nil,nil,true)
  radius = config.getParameter("blockRadius") / 2
  altRadius = config.getParameter("altBlockRadius") / 2

  notifyTime = config.getParameter("notifyEntityTime")
  notifyTimer = 0
  notifyDamage = config.getParameter("tileDamage") / config.getParameter("fireTime") * notifyTime
  notifyQueryParams = {
    includedTypes = {"vehicle"},
    boundMode = "position"
  }
end

function update(dt, fireMode, shifting)
  world.sendEntityMessage(magnet,"move",{fireableItem.ownerAimPosition()[1],fireableItem.ownerAimPosition()[2]})
  if fireMode == "primary" then
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
  local entities = world.entityQuery(fireableItem.ownerAimPosition(), shifting and altRadius or radius, notifyQueryParams)
  for _, entityId in ipairs(entities) do
    world.sendEntityMessage(entityId, "positionTileDamaged", notifyDamage)
  end
end
