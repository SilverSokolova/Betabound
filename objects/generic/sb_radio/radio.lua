function onNodeConnectionChange() processWireInteraction() end
function onInputNodeChange() processWireInteraction() end
function onInteraction() return interaction end

function processWireInteraction()
  if object.isInputNodeConnected(0) then
    if object.getInputNodeLevel(0) then
      radioOn()
    else
      uninit()
      object.setInteractive(false)
    end
  end
  if not object.isInputNodeConnected(0) then radioOn() end
end

function radioOn()
  script.setUpdateDelta(60)
  animator.setParticleEmitterActive("music",true)
  object.setInteractive(true)
end

function init()
  storage.knownPlayers = {}
  object.setInteractive(true)
  processWireInteraction()
  p = entity.position()
  storage.radio = storage.radio or config.getParameter("radioData")
  local mode = root.assetJson(config.getParameter("interactData"))
  mode.mode = 2; mode.id = entity.id(); mode.range = storage.radio[2]
  interaction = {config.getParameter("interactAction"),mode}
  updateRadio()
  message.setHandler("sb_radio", function(_,_,t,r) updateRadio({t,r}) radioOn() end)
  message.setHandler("sb_radioStop", function() updateRadio({""}) uninit() end)
  if storage.radio[1] == "" then uninit() end
end

function updateRadio(data)
  if not data then return end
  if data[1] then data[1] = data[1] else data[1] = storage.radio[1] end
  if data[2] then data[2] = data[2] else data[2] = storage.radio[2] end
  interaction[2].range = storage.radio[2]
  storage.radio = data or storage.radio
end

function update(dt)
  local players = world.players()
  world.debugPoly({
    {p[1]+storage.radio[2], p[2]+storage.radio[2]-2},
    {p[1]-storage.radio[2]+2, p[2]+storage.radio[2]-2},
    {p[1]-storage.radio[2]+2, p[2]-storage.radio[2]-2},
    {p[1]+storage.radio[2], p[2]-storage.radio[2]-2}
  },"green")
  for _, v in pairs(players) do
    if world.magnitude(p,world.entityPosition(v)) < storage.radio[2] then
      world.sendEntityMessage(v,"playAltMusic",storage.radio[1],1)
      storage.knownPlayers[v] = false
    else
      if not storage.knownPlayers[v] then
        world.sendEntityMessage(v,"stopAltMusic",1)
        storage.knownPlayers[v] = true
      end
    end
  end
end

function uninit()
  animator.setParticleEmitterActive("music",false)
  script.setUpdateDelta(0)
  local players = world.players()
  for _, v in pairs(players) do
    local ep = world.entityPosition(v)
    if (type(p) ~= "table" or type(ep) ~= "table") then return end
    local m = world.magnitude(p,ep)
    if m and m < storage.radio[2] then
      world.sendEntityMessage(v,"stopAltMusic",1)
    end
  end
end