function init()
  cooldownTime = config.getParameter("cooldownTime")
  storage.cooldownTimer = storage.cooldownTimer or 0
end

function activate()
  if player and storage.cooldownTimer == 0 then
    world.sendEntityMessage(player.id(), "pets.sb_callPodPets")
    storage.cooldownTimer = cooldownTime
  end
end

function update()
  storage.cooldownTimer = math.max(0, storage.cooldownTimer - 1)
end