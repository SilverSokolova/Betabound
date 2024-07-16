local ini = init
function init() ini()
  sb_petsToTeleport = {}
  message.setHandler("pets.sb_callPodPets", function()
    local pets = playerCompanions.getCompanions("pets")
    for i = 1, #pets do
      local podUuid = pets[i].podUuid
      petSpawner.pods[podUuid]:recall()
      sb_petsToTeleport[#sb_petsToTeleport+1] = podUuid
    end
    sb_skipUpdate = true
  end)
end

local updat = update
function update(dt)
  --This is to fix pets not being resummoned if triggered on the same frame as an update cycle
  if sb_skipUpdate then
    sb_skipUpdate = false
  else
    updat(dt)
    if #sb_petsToTeleport > 0 then
      local playerPosition = world.entityPosition(player.id())
      local clearList = false
      for i = 1, #sb_petsToTeleport do
        petSpawner.pods[sb_petsToTeleport[i]]:release(world.entityPosition(player.id()))
      end
      sb_petsToTeleport = {}
    end
  end
end