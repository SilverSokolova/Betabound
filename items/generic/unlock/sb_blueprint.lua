require "/scripts/sb_uimessage.lua"
require "/scripts/sb_assetmissing.lua"
--does not work with sb_swing
function init()
  swingTime = config.getParameter("swingTime",1)
  activeItem.setArmAngle(-math.pi / 2)
end

function update(dt, fireMode, shiftHeld)
  updateAim()

  if not swingTimer and fireMode == "primary" and player then
    swingTimer = swingTime
  end

  if swingTimer then
    swingTimer = math.max(0, swingTimer - dt)
    activeItem.setArmAngle((-math.pi / 2) * (swingTimer / swingTime))
    if swingTimer == 0 then
      learnBlueprint(shiftHeld)
      activeItem.setArmAngle(-math.pi / 2)
    end
  end
end

function learnBlueprint(shiftHeld)
  local recipe = config.getParameter("recipe",config.getParameter("sb_recipe","perfectlygenericitem"))
  if shiftHeld then
    if sb_itemExists((type(recipe)=="string" and recipe or recipe.name).."-recipe") then
      if type(recipe) ~= "string" then recipe = recipe.name or config.getParameter("sb_recipe","perfectlygenericitem") end
      player.giveItem(recipe.."-recipe")
      item.consume(1)
      swingTimer = swingTime
      return
    end
  end
  if not player.blueprintKnown(recipe) then
    player.giveBlueprint(recipe)
    item.consume(1)
    script.setUpdateDelta(0)
    animator.playSound("learnBlueprint")
  else
    script.setUpdateDelta(0)
    sb_uiMessage(7)
  end
end

function updateAim()
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)
end