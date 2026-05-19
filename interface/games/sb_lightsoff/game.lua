function init()
  self.canvas = widget.bindCanvas("scriptCanvas")
  widget.focus("scriptCanvas")

  cfg = config.getParameter("gameConfig")
  sfx = config.getParameter("gameSounds")
  clr = config.getParameter("gameColors")
  txt = config.getParameter("gameText")

  if type(cfg.lightGridSize) == "number" then
    introActive = true
    endingActive = false

    local lightHalfSize = cfg.lightSize / 2
    cfg.center = cfg.lightStart

    cfg.lightStart = {
      cfg.lightStart[1] - (cfg.lightGridSize * lightHalfSize),
      cfg.lightStart[2] - (cfg.lightGridSize * lightHalfSize)
    }

    self.canvas:drawText(
      txt.intro.text,
      {position={cfg.center[1], cfg.center[2] + txt.intro.y}, horizontalAnchor="mid", verticalAnchor="top"},
      16,
      clr.text
    )

    self.lights = {}
    for x = 1, cfg.lightGridSize do
      for y = 1, cfg.lightGridSize do
        setLightValue({x, y}, true)
      end
    end
  else
    script.setUpdateDelta(0)
    cfg.lightGridSize = math.random(cfg.lightGridSize[1], cfg.lightGridSize[2])
    player.interact("ScriptPane",
      {
        baseConfig = "/interface/games/sb_lightsoff/game.config",
        gameConfig = cfg,
        setup = true
      },
      player.id()
    )
  end
end

function lightPosition(light)
  return {(light[1] - 1) * cfg.lightSize + cfg.lightStart[1], (light[2] - 1) * cfg.lightSize + cfg.lightStart[2]}
end

function lightFor(pos)
  return {math.floor((pos[1] - cfg.lightStart[1]) / cfg.lightSize) + 1, math.floor((pos[2] - cfg.lightStart[2]) / cfg.lightSize) + 1}
end

function lightWithinRange(light)
  return light[1] >= 1 and light[1] <= cfg.lightGridSize and light[2] >= 1 and light[2] <= cfg.lightGridSize
end

function lightValue(light)
  if lightWithinRange(light) then
    return self.lights[light[1]..":"..light[2]]
  else
    return false
  end
end

function setLightValue(light, val)
  if lightWithinRange then
    self.lights[light[1]..":"..light[2]] = val
  end
end

function toggleLightValue(light)
  setLightValue(light, not lightValue(light))
end

function update()
  if introActive or endingActive then
    return
  end

  self.canvas:clear()

  --size
  self.canvas:drawText(
    string.format(txt.size.text, cfg.lightGridSize),
    {position={cfg.center[1], cfg.center[2] + txt.size.y}, horizontalAnchor="mid", verticalAnchor="top"},
    8,
    clr.text
  )

  --border
  local gridMin = {cfg.lightStart[1], cfg.lightStart[2]}
  local gridMax = {cfg.lightStart[1] + cfg.lightSize * cfg.lightGridSize, cfg.lightStart[2] + cfg.lightSize * cfg.lightGridSize}
  self.canvas:drawPoly(
    {{gridMin[1], gridMin[2]}, {gridMax[1], gridMin[2]}, {gridMax[1], gridMax[2]}, {gridMin[1], gridMax[2]}},
    clr.border
  )

  --draw and check lights
  local allGone = true
  for x = 1, cfg.lightGridSize do
    for y = 1, cfg.lightGridSize do
      if lightValue({x, y}) then
        allGone = false
      end

      local pos = lightPosition({x, y})
      if lightValue({x, y}) then
        self.canvas:drawRect(
          {pos[1] + cfg.lightShrink, pos[2] + cfg.lightShrink, pos[1] + cfg.lightSize - cfg.lightShrink, pos[2] + cfg.lightSize - cfg.lightShrink},
          clr.lit
          )
      else
        self.canvas:drawRect(
          {pos[1] + cfg.lightShrink, pos[2] + cfg.lightShrink, pos[1] + cfg.lightSize - cfg.lightShrink, pos[2] + cfg.lightSize - cfg.lightShrink},
          clr.unlit
        )
      end
    end
  end

  if allGone then
    endingActive = true
    self.canvas:clear()
    self.canvas:drawText(
      txt.ending.text,
      {position={cfg.center[1], cfg.center[2] + txt.ending.y}, horizontalAnchor="mid", verticalAnchor="top", wrapWidth = 275},
      8,
      clr.text
    )
  end
end

function canvasClickEvent(position, button, buttonDown)
  if buttonDown then
    if introActive then
      introActive = false
    else
      local light = lightFor(position)
      if lightWithinRange(light) then
        pane.playSound(sfx.toggleLight, 0, 1.0) --TODO: unhardcode args
        toggleLightValue({light[1], light[2]})
        toggleLightValue({light[1] - 1, light[2]})
        toggleLightValue({light[1], light[2] - 1})
        toggleLightValue({light[1] + 1, light[2]})
        toggleLightValue({light[1], light[2] + 1})
      end
    end
  end
end
