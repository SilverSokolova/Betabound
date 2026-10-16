require("/scripts/sb_uimessage.lua")

local originalInit = init or function() end
local originalLearnBlueprint = learnBlueprint or function() end

function init(); originalInit()
  sb_recipes = sb_gatherRecipes(self.recipes)
  sb_checkAllRecipesKnown()
end

function learnBlueprint(); originalLearnBlueprint()
--self.swingTime = 0
  self.swingTimer = false
  activeItem.setArmAngle(-math.pi / 2) --Same as in init
  sb_checkAllRecipesKnown()
end

function sb_checkAllRecipesKnown()
  local allRecipesKnown = true
  for i = 1, #sb_recipes do
    if not player.blueprintKnown(sb_recipes[i]) then
      allRecipesKnown = false
      break
    end
  end
  sb_uiMessage(allRecipesKnown and "blueprintSetKnown" or "blueprintSetUnknown")
end

function sb_gatherRecipes(recipeList)
  local newRecipeList = {}

  for i = 1, #recipeList do
    if type(recipeList[i]) == "table" then
      sb_gatherRecipes(recipeList[i])
    else
      newRecipeList[#newRecipeList + 1] = recipeList[i]
    end
  end

  return newRecipeList
end