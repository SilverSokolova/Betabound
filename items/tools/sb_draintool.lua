function init()
  radius = config.getParameter("blockRadius")
  altRadius = config.getParameter("altBlockRadius")

  range = root.assetJson("/player.config:initialBeamGunRadius") + status.statusProperty("bonusBeamGunRadius", 0)
  inRange = false
  playSound = false

  activeItem.setScriptedAnimationParameter("highlightColor", config.getParameter("highlightColor"))
  animator.setSoundVolume("fire", 0.5)
end

function update(dt, fireMode, shifting)
  local aimPosition = activeItem.ownerAimPosition()
  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, aimPosition)
  activeItem.setArmAngle(aimAngle)
  activeItem.setFacingDirection(aimDirection or 0)
  activeItem.setScriptedAnimationParameter("radius", shifting and altRadius or radius)

  inRange = player.isAdmin() or world.magnitude(mcontroller.position(), aimPosition) <= range
  activeItem.setScriptedAnimationParameter("inRange", inRange)

  if inRange then
    if fireMode ~= "none" then
      local area = shifting and altRadius or radius

      local base = {math.floor(aimPosition[1]) - area / 2, math.floor(aimPosition[2]) - area / 2}
      for x = 1, area do
        for y = 1, area do
          local targetPosition = {base[1] + x, base[2] + y}
          local layer = fireMode == "alt" and "background" or "foreground"
          local material = world.material(targetPosition, layer)

          if material and not world.isTileProtected(targetPosition) then
            local hueshift = world.materialHueShift(targetPosition, layer)
            local itemDrop = root.materialConfig(material); if itemDrop then itemDrop = itemDrop.config.itemDrop end

            if hueshift ~= 0 and itemDrop then
              player.giveItem({"sb_paint", 1, {sb_paintData = {itemDrop, math.floor(hueshift * 360 / 255) + 1}}})
              world.setMaterialColor(targetPosition, layer, 0)
              playSound = true
            end
          end
        end

        if playSound then
          animator.playSound("fire")
          playSound = false
        end
      end
    end
  end
end