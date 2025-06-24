--WHY DOES THIS KEEP BREAKING? AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
function init()
  storage.radio = storage.radio or config.getParameter("radioData")
  storage.knownPlayers = {}

  if storage.radio[1] then
    storage.radio = {
      song = type(storage.radio[1]) == "string" and storage.radio[1] or storage.radio[1][1],
      range = storage.radio[2],
      active = false
    }
  end

  entityPosition = entity.position()
  interfaceData = root.assetJson(config.getParameter("interactData"))
  interfaceData.radioType = "stationary"
  interfaceData.id = entity.id()
  interactAction = config.getParameter("interactAction")

  message.setHandler("sb_radio:update", function(_, _, data)
    updateRadio(data)
  end)

  processWireInteraction()
  if storage.radio.active == false then
    disableRadio()
  end
end

function onInteraction()
  interfaceData.objectStorage = storage.radio
  return {interactAction, interfaceData}
end

function enableRadio()
  script.setUpdateDelta(60)
  object.setInteractive(true)
  storage.radio.active = true
end

function onNodeConnectionChange() processWireInteraction() end
function onInputNodeChange() processWireInteraction() end
function processWireInteraction()
  if object.isInputNodeConnected(0) then
    if object.getInputNodeLevel(0) or not object.isInputNodeConnected(0) then
      enableRadio()
    else
      disableRadio()
      object.setInteractive(false)
    end
  end
  animator.setParticleEmitterActive("music", storage.radio.active)
end

function updateRadio(data)
  storage.radio.range = data.range

  if data.song then
    storage.radio.song = data.song
  end

  if data.active ~= nil then
    if data.active then
      enableRadio()
    else
      disableRadio()
    end
  end
  animator.setParticleEmitterActive("music", storage.radio.active)
--mode.playing = (not mode.playing and string.match(storage.radio[1][1], "/([^/]+)%.%w+$")) or storage.radio[1][1]
end

function update(dt)
  local players = world.players()
  world.debugPoly({
    {entityPosition[1] + storage.radio.range, entityPosition[2] + storage.radio.range - 2},
    {entityPosition[1] - storage.radio.range + 2, entityPosition[2] + storage.radio.range - 2},
    {entityPosition[1] - storage.radio.range + 2, entityPosition[2] - storage.radio.range - 2},
    {entityPosition[1] + storage.radio.range, entityPosition[2] - storage.radio.range - 2}
  }, "green")
  if storage.radio.active then
    for _, player in pairs(players) do
      if world.magnitude(entityPosition, world.entityPosition(player)) < storage.radio.range then
        world.sendEntityMessage(player, "playAltMusic", {storage.radio.song}, 1)
        storage.knownPlayers[player] = true
      elseif storage.knownPlayers[player] then
        world.sendEntityMessage(player, "stopAltMusic", 1)
        storage.knownPlayers[player] = false
      end
    end
  end
end

--remember that this runs when the object is broken too
function uninit()
  stopMusic()
end

function disableRadio()
  storage.radio.active = false
  stopMusic()
end

function stopMusic()
  script.setUpdateDelta(0)
  animator.setParticleEmitterActive("music", false)
  local players = storage.knownPlayers
  for player, isKnown in pairs(players) do
    if isKnown then
      local playerPosition = world.entityPosition(player)
      if not entityPosition or not playerPosition then
        return
      end
      local magnitude = world.magnitude(entityPosition, playerPosition)
      if magnitude and magnitude <= storage.radio.range then
        world.sendEntityMessage(player, "stopAltMusic", 1)
      end
    end
    storage.knownPlayers = {}
  end
end