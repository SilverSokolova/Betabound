local ini = init or function() end
function init() ini()
  if not status.statusProperty("sb_minibossSpawned") then
    status.addEphemeralEffect("sb_minibossspawn")
    status.setStatusProperty("sb_minibossSpawned", true)
  end
end