require "/scripts/sb_uimessage.lua"
require "/scripts/sb_assetmissing.lua"
require "/scripts/activeitem/sb_swing.lua"

function init()
  swingInit()
  recipe = config.getParameter("recipe", config.getParameter("sb_recipe", "perfectlygenericitem"))
end

function swingAction(_, _, shiftHeld)
  if shiftHeld then
    return unstackBlueprint()
  end

  local recipes = root.recipesForItem(type(recipe) == "string" and recipe or recipe.name)
  for i = 1, #recipes do
    if root.itemDescriptorsMatch(recipes[i].output, recipe, true) then
      if not player.blueprintKnown(recipe) then
        player.giveBlueprint(recipe)
        animator.playSound("success")
        item.consume(1)
      else
        sb_uiMessage("blueprintKnown")
      end
      break
    end
    unstackBlueprint()
    sb_uiMessage("blueprintFail")
  end
end

function unstackBlueprint()
  if sb_itemExists((type(recipe) == "string" and recipe or recipe.name).."-recipe") then
    if type(recipe) ~= "string" then
      recipeName = recipe.name or config.getParameter("sb_recipe", "perfectlygenericitem")
    end
    player.giveItem((recipeName or recipe).."-recipe")
    item.consume(1)
  end
end