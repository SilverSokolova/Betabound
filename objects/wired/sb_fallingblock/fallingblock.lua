function init()
  setupMaterialSpaces()
  object.setMaterialSpaces(closedMaterialSpaces)

  detectEntityTypes = config.getParameter("detectEntityTypes", {"player", "npc","monster","vehicle"})
  detectBoundMode = config.getParameter("detectBoundMode", "CollisionArea")
  detectArea = config.getParameter("detectArea")
  local pos = object.position()
  if not detectArea then
    local boundBox = object.boundBox()
    detectArea = {
      {boundBox[1] + 0, boundBox[2] + 16},
      {boundBox[3] - 0, boundBox[4]}
    }
  elseif type(detectArea[2]) == "number" then
    --center and radius
    detectArea = {
      {pos[1], pos[2] + detectArea[1][2]},
      detectArea[2]
    }
  elseif type(detectArea[2]) == "table" and #detectArea[2] == 2 then
    --rect corner1 and corner2
    detectArea = {
      {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
      {pos[1] + detectArea[2][1], pos[2] + detectArea[2][2]}
    }
  end

  stayClosedTime = config.getParameter("stayClosedTime", 0.5)
  stayOpenTime = config.getParameter("stayOpenTime", 0.5)

  state = false
  triggered = false

  closeTimer = 0
  openTimer = stayClosedTime

  object.setInteractive(false)
end

function update(dt)
  if state then
    if entityInArea() then
      closeTimer = stayOpenTime
    else
      closeTimer = math.max(0, closeTimer - dt)
    end

    if closeTimer == 0 then
      closeDoor()
    end
  else
    if not triggered and entityInArea() then
      triggered = true
    end

    if triggered then
      openTimer = math.max(0, openTimer - dt)
      if openTimer == 0 then
        openDoor()
      end
    end
  end
end

function closeDoor()
  if state ~= false then
    state = false
    triggered = false
    openTimer = stayClosedTime
--    animator.playSound("close")
    animator.setAnimationState("padState", "off")
    object.setMaterialSpaces(closedMaterialSpaces)
  end
end

function openDoor()
  if not state then
    state = true
    closeTimer = stayOpenTime
--    animator.playSound("open")
    animator.setAnimationState("padState", "on")
    object.setMaterialSpaces(openMaterialSpaces)
    world.spawnProjectile("sb_fallingblock",{entity.position()[1]+0.5,entity.position()[2]+0.5})
  end
end

function entityInArea()
  local entityIds = world.entityQuery(detectArea[1], detectArea[2], {
        withoutEntityId = entity.id(),
        includedTypes = detectEntityTypes,
        boundMode = detectBoundMode
      })
  return #entityIds > 0
end

function setupMaterialSpaces()
  closedMaterialSpaces = config.getParameter("closedMaterialSpaces")
  if not closedMaterialSpaces then
    closedMaterialSpaces = {}
    for i, space in ipairs(object.spaces()) do
      table.insert(closedMaterialSpaces, {space, "metamaterial:door"})
    end
  end
  openMaterialSpaces = config.getParameter("openMaterialSpaces", {})
end
