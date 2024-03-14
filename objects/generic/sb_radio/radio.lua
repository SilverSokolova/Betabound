function init()
  storage.radio = storage.radio or config.getParameter("radioData")
  storage.knownPlayers = {}
  playing = false

  if storage.radio[1] then
    storage.radio = {
      song = type(storage.radio[1]) == "string" and storage.radio[1] or storage.radio[1][1],
      range = storage.radio[2]
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

  if storage.radio.song == "" then
    uninit()
  end
  processWireInteraction()
end

function onInteraction()
  interfaceData.objectStorage = storage.radio
  return {interactAction, interfaceData}
end

function enableRadio()
  script.setUpdateDelta(60)
  animator.setParticleEmitterActive("music", storage.radio.song ~= "")
  object.setInteractive(true)
  playing = true
end

function onNodeConnectionChange() processWireInteraction() end
function onInputNodeChange() processWireInteraction() end
function processWireInteraction()
  if object.isInputNodeConnected(0) then
    if object.getInputNodeLevel(0) or not object.isInputNodeConnected(0) then
      enableRadio()
    else
      uninit()
      object.setInteractive(false)
    end
  end
end

function updateRadio(data)
  storage.radio.song = data.song
  if song ~= "" and not playing then
    enableRadio()
  elseif playing then
    uninit()
  end

  storage.radio.range = data.range
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
  for _, player in pairs(players) do
    if world.magnitude(entityPosition, world.entityPosition(player)) < storage.radio.range then
      world.sendEntityMessage(player, "playAltMusic", {storage.radio.song}, 1)
      storage.knownPlayers[player] = true
    elseif storage.knownPlayers[player] and playing then
      world.sendEntityMessage(player, "stopAltMusic", 1)
      storage.knownPlayers[player] = false
    end
  end
end

function uninit() --disableRadio
  playing = false
  animator.setParticleEmitterActive("music", false)
  script.setUpdateDelta(0)
  local players = world.players()
  for _, player in pairs(players) do
    if storage.knownPlayers[player] then
      storage.knownPlayers[player] = false
      local playerPosition = world.entityPosition(player)
      if not entityPosition or not playerPosition then
        return
      end
      local magnitude = world.magnitude(entityPosition, playerPosition)
      if magnitude and magnitude < storage.radio.range then
        world.sendEntityMessage(player, "stopAltMusic", 1)
      end
    end
  end
end