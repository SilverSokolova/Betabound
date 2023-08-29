require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit()
  recipes = config.getParameter("recipes",{"money"})
  reusable, consume, used = config.getParameter("reusable",false), false, false
end

function swingAction() animateSwing()
  for i = 1, #recipes do
    if not player.blueprintKnown(recipes[i]) then
      consume = not reusable
      used = true
      player.giveBlueprint(recipes[i])
    end
  end
  if consume then item.consume(1) end
  if used then
    animator.playSound("success")
  else
    sb_uiMessage(11)
  end
end