function init()
  radius = animationConfig.animationParameter("radius", config.getParameter("blockRadius"))
  endImages = config.getParameter("endImages")
end

function update(dt)
  radius = animationConfig.animationParameter("radius", config.getParameter("blockRadius"))
--inRange = animationConfig.animationParameter("inRange", false)
--if inRange then  end
  fillRadius(radius)
end

function fillRadius(radius)
  local layer = "overlay"
  local base = activeItemAnimation.ownerAimPosition()
  localAnimator.clearDrawables()
  localAnimator.clearLightSources()
  localAnimator.addDrawable({image = endImages[1], fullbright = true, position = base}, layer)
  base = {math.floor(base[1]), math.floor(base[2])}

  if radius == 1 then
    addLight({base[1] + 0.4, base[2] + 0.4}, layer)
    return
  end

  if radius % 2 == 0 then
    base = {base[1] + 0.4, base[2] + 0.4}
  end

  local tiles = {}
  for x = 1, radius do
    for y = 1, radius do
      tiles[#tiles+1] = {base[1] - (radius / 2) + x, base[2] - (radius / 2) + y}
      addLight(tiles[#tiles], layer) --if #t>1 then addLight(t[#t],layer) end
    end
  end
end

function addLight(pos,layer)
  localAnimator.addDrawable({image = endImages[2], fullbright = true, position = pos}, layer)
  localAnimator.addLightSource({position = pos, color = {25.5, 40, 46.75}, pointLight = false, beamAmbience = 0.00002})
end
