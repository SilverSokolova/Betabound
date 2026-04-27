require "/scripts/sb_assetmissing.lua"

--I'd love to have this apply a persistent effect group, and
--have it removed in uninit, but removing two at the same
--time (suit tech unequip and uninit) kills the game with
--a 50,000+ line stack traceback.

--The reason for this approach is to have specifically
--this tech check is Shellguard is installed.
function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  if sb_itemExists(techConfig.sb_requiredItemFromAssetSource) then
    update = function()
      for i = 1, #techConfig["appliedEffects"] do
        status.addEphemeralEffect(techConfig["appliedEffects"][i], 0.1)
      end
    end
  end
end