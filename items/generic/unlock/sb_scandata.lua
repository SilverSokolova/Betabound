require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit()
  recipe = config.getParameter("recipe")
  reset()
end

function reset()
  reusable, consume, used = config.getParameter("reusable", false), false, false
end

function swingAction()
  if player.addScannedObject(recipe) then
    consume = not reusable
    used = true
  end
  if consume then item.consume(1) end
  if used then
    animator.playSound("success")
    sb_uiMessage("scandataLearned")
    world.sendEntityMessage(entity.id(), "objectScanned", recipe)
  else
    sb_uiMessage("scandataKnown")
  end
  reset()
end