require "/scripts/sb_uimessage.lua"
require "/scripts/sb_assetmissing.lua"
require "/scripts/activeitem/sb_swing.lua"

function init() swingInit() end

function swingAction(_, _, shiftHeld)
  local recipe = config.getParameter("recipe",config.getParameter("sb_recipe","perfectlygenericitem"))
  if shiftHeld then
    if sb_itemExists((type(recipe)=="string" and recipe or recipe.name).."-recipe") then
      if type(recipe) ~= "string" then recipe = recipe.name or config.getParameter("sb_recipe","perfectlygenericitem") end
      player.giveItem(recipe.."-recipe")
      item.consume(1)
      return
    end
  end
  if not player.blueprintKnown(recipe) then
    player.giveBlueprint(recipe)
    animator.playSound("success")
    item.consume(1)
  else
    sb_uiMessage("blueprintKnown")
  end
end