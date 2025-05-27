function init()
  radius = animationConfig.animationParameter("radius", config.getParameter("blockRadius"))
  highlight = config.getParameter("highlight")
  local unconvertedFavoriteColor = animationConfig.animationParameter("favoriteColor", root.assetJson("/player.config:defaultHumanoidIdentity.color"))
  unconvertedFavoriteColor[4] = nil
  favoriteColor = ""
  for i = 1, #unconvertedFavoriteColor do
    favoriteColor = favoriteColor .. string.format("%02x", unconvertedFavoriteColor[i])
  end
end

function update(dt)
  radius = animationConfig.animationParameter("radius", config.getParameter("blockRadius"))
  inRange = animationConfig.animationParameter("inRange", false)
  localAnimator.clearDrawables()
  localAnimator.clearLightSources()
  if inRange then
    fillRadius(radius)
  end
end

function fillRadius(radius)
  local layer = "overlay"
  local base = activeItemAnimation.ownerAimPosition(); base = {math.floor(base[1]), math.floor(base[2])}
--localAnimator.addDrawable({image = endImages[1], fullbright = true, position = base}, layer)

  local position = {base[1] + 0.5, base[2] + 0.5}
  localAnimator.addDrawable({image = string.format(highlight, favoriteColor, radius, favoriteColor), fullbright = true, position = position}, layer)

  if radius == 1 then
    addLight(position)
  else
    local baseX = base[1] - radius / 2
    local baseY = base[2] - radius / 2

    for x = 1, radius do
      for y = 1, radius do
        addLight({baseX + x, baseY + y})
      end
    end
  end
end

function addLight(position)
  if world.material(position, "foreground") then
    localAnimator.addLightSource({position = position, color = {50, 50, 50}, pointLight = true, beamAmbience = 0.00002}) --TODO: unhardcode light
  end
end
