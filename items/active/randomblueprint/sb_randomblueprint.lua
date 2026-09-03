require("/scripts/sb_uimessage.lua")

local originalInit = init or function() end
local originalLearnBlueprint = learnBlueprint or function() end

function init(); originalInit()
  sb_recipes = {}
  sb_gatherRecipes(self.recipes)
  local allRecipesKnown = true
  for i = 1, #sb_recipes do
    if not player.blueprintKnown(sb_recipes[i]) then
      allRecipesKnown = false
      break
    end
  end
  sb_uiMessage(allRecipesKnown and "blueprintSetKnown" or "blueprintSetUnknown")
  sb_recipes = nil
end

function learnBlueprint(); originalLearnBlueprint()
--self.swingTime = 0
  self.swingTimer = false
  activeItem.setArmAngle(-math.pi / 2) --Same as in init
end

function sb_gatherRecipes(recipeList)
  for i = 1, #recipeList do
    if type(recipeList[i]) == "table" then
      sb_gatherRecipes(recipeList[i])
    else
      sb_recipes[#sb_recipes + 1] = recipeList[i]
    end
  end
end