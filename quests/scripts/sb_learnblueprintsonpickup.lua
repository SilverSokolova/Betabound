--Right now, it's suited to work for invalidMods. Should be easy to add others if the time comes!
require("/scripts/sb_assetmissing.lua")

function init()
  local configParameters = config.getParameter("")
  local valid = not sb_modsInGroupPresent(configParameters.invalidMods)

  if valid then
    local learnBlueprintsOnPickup = configParameters.learnBlueprintsOnPickup
    local unlockedNewBlueprint = false
    for i = 1, #learnBlueprintsOnPickup do
      if not player.blueprintKnown(learnBlueprintsOnPickup[i]) then
        player.giveBlueprint(learnBlueprintsOnPickup[i])
        unlockedNewBlueprint = true
      end
    end
    
    local radioMessagesOnPickup = configParameters.radioMessagesOnPickup
    if unlockedNewBlueprint and radioMessagesOnPickup then
      for i = 1, #radioMessagesOnPickup do
        player.radioMessage(radioMessagesOnPickup[i])
      end
    end
  end

  quest.fail()
end