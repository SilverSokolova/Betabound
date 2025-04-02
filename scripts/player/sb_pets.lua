local originalInit = init
function init() originalInit()
  sb_pets = {}
  message.setHandler("pets.sb_callPodPets", function()
    local pets = playerCompanions.getCompanions("pets")
    for i = 1, #pets do
      local podUuid = pets[i].podUuid
      petSpawner.pods[podUuid]:recall()
      sb_pets[#sb_pets+1] = podUuid
    end
    sb_skipUpdate = true
  end)
end

local originalUpdate = update
function update(dt)
  --This is to fix pets not being resummoned if triggered on the same frame as an update cycle
  if sb_skipUpdate then
    sb_skipUpdate = false
  else
    originalUpdate(dt)
    if #sb_pets > 0 then
      local playerPosition = world.entityPosition(player.id())
      for i = 1, #sb_pets do
        petSpawner.pods[sb_pets[i]]:release(playerPosition)
      end
      sb_pets = {}
    end
  end
end