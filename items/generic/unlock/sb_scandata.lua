require "/scripts/sb_uimessage.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit()
  recipe = config.getParameter("recipe")
  reset()
end

function reset()
  reusable, consume, used = config.getParameter("reusable", false), false, false
end

function swingAction()
  world.sendEntityMessage(entity.id(), "objectScanned", recipe) --This is here so players that deleted the object from their printer via the Lagless Pixel Printer mod can relearn it
  if player.addScannedObject(recipe) then
    consume = not reusable
    used = true
  end
  if consume then item.consume(1) end
  if used then
    animator.playSound("success")
    sb_uiMessage("scandataLearned")
  else
    sb_uiMessage("scandataKnown")
  end
  reset()
end