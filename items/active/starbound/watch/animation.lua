function init()
  midday = root.assetJson("/scripts/fishing/fishingspawner.config")
  midday = (midday.dayRange[2] + midday.nightRange[1]) / 2
  dayNightIcons = config.getParameter("dayNightIcons")
end

function update(dt)
  local day = world.timeOfDay()
  local seconds = day * 24 * 3600 or 0
  local minute = tostring(math.floor((seconds / 60) % 60))
  minute = (#minute == 2 and minute or "0"..minute)
  local hour = string.format("%02d", math.floor(((seconds / 3600) + 6) % 24))

  localAnimator.clearDrawables()
  local position = activeItemAnimation.ownerPosition()
  localAnimator.addDrawable(
    {
      image = dayNightIcons[day <= midday and 1 or 2],
      fullbright = true,
      position = {position[1] + ((addText(string.format("%s:%s", hour, minute), position) + 0.5) / 1.6), position[2] + handOffset + 0.125},
      scale = 0.5
    },
    "overlay"
  )
end