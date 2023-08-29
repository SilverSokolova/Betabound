require "/scripts/vec2.lua"

function drawables()
  local ropeItemOffset = activeItemAnimation.animationParameter("ropeItemOffset", {0,0})
  local ropeWidth = activeItemAnimation.animationParameter("ropeWidth", 1)
  local ropeColor = activeItemAnimation.animationParameter("ropeColor", {255, 255, 255, 255})
  local ropeFullbright = activeItemAnimation.animationParameter("ropeFullbright", false)
  local ropeSegments = activeItemAnimation.animationParameter("ropeSegments", {})

  if #ropeSegments == 0 then
    return {}
  elseif #ropeSegments == 1 then
    sb.logInfo("Can't draw a rope with 1 point!")
    return {}
  end

  for i, segPoint in ipairs(ropeSegments) do
    -- points specified as single numbers are entity ids that need to be turned into positions
    if type(segPoint) == "number" then
      if world.entityExists(segPoint) then
        ropeSegments[i] = world.entityPosition(segPoint)
      else
        -- WHAT DO
        -- sb.logInfo("Rope can't point to nonexistent entity %s", segPoint)
        return {}
      end
    -- points specified as strings refer to special positions
    elseif type(segPoint) == "string" then
      if segPoint == "item" then
        ropeSegments[i] = vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(ropeItemOffset))
      end
    end
  end

  -- sb.logInfo("Drawing rope with points %s", ropeSegments)

  local newDrawables = {}

  for i, segPoint in ipairs(ropeSegments) do
    if i ~= 1 then
      local lineVector = world.distance(segPoint, ropeSegments[i - 1])
      table.insert(newDrawables, {{ line = {{0, 0}, lineVector}, width = ropeWidth, color = ropeColor, position = ropeSegments[i - 1], fullbright = true}})
    end
  end

  if #newDrawables > 0 then
    --sb.logInfo("Drawable count: %s", #newDrawables)
  end
  return newDrawables
end
