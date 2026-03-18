function init()
  canvasRect = config.getParameter("gui.scriptCanvas.rect")
  cfg = config.getParameter("gameConfig")
  sfx = config.getParameter("gameSounds")
  input = config.getParameter("gameInput")

  introActive = true
  multiplayer = false
  gamePaused = true

  gameRect = {
    cfg.windowCenter[1] - cfg.gameDims[1] - cfg.ballDims[1],
    cfg.windowCenter[2] - cfg.gameDims[2] - cfg.ballDims[2],
    cfg.windowCenter[1] + cfg.gameDims[1] + cfg.ballDims[1],
    cfg.windowCenter[2] + cfg.gameDims[2] + cfg.ballDims[2]
  }

  p1, p2, ball = {}, {}, {}
  ballSfxCooldown, ballSfxCooldownTimer = 5, 0

  newGame()

  self.canvas = widget.bindCanvas("scriptCanvas")
  widget.focus("scriptCanvas")
  widget.playSound(sfx.start)
end

function newGame()
  p1.pos = {cfg.windowCenter[1] - cfg.gameDims[1] + 5, cfg.windowCenter[2]}
  p2.pos = {cfg.windowCenter[1] + cfg.gameDims[1] - 5, cfg.windowCenter[2]}
  p1.score = 0
  p2.score = 0
  p1.move = 0
  p2.move = 0

  resetBall()
end

function update(dt)
  if gamePaused then
    self.canvas:drawText(
      introActive and cfg.introText or cfg.pauseText,
      {position={cfg.windowCenter[1], cfg.windowCenter[2] + 20}, horizontalAnchor="mid", verticalAnchor="top"},
      16,
      {255, 255, 128}
    )
    return
  end

  self.canvas:clear()

  ballSfxCooldownTimer = math.max(ballSfxCooldownTimer - 1, 0)

  ball.pos = {ball.pos[1] + ball.vel[1] * dt, ball.pos[2] + ball.vel[2] * dt}

  if not multiplayer then
--  p2.move = (cfg.paddleSpeed / 1.6) * (ball.pos[2] > p2.pos[2] and 1 or -1)
--  p2.move = cfg.paddleSpeed * (ball.vel[2] > 0 and 1 or -1)
    p2.move = ball.pos[1] > cfg.windowCenter[1] + 55 and cfg.paddleSpeed * ((ball.pos[2] > p2.pos[2]) and 1 or -1) or 0
  end

  p1.pos[2] = math.max(math.min(p1.pos[2] + p1.move * dt, gameRect[4] - cfg.paddleDims[2]), gameRect[2] + cfg.paddleDims[2])
  p2.pos[2] = math.max(math.min(p2.pos[2] + p2.move * dt, gameRect[4] - cfg.paddleDims[2]), gameRect[2] + cfg.paddleDims[2])

  if ball.pos[2] >= cfg.windowCenter[2] + cfg.gameDims[2] or ball.pos[2] <= cfg.windowCenter[2] - cfg.gameDims[2] then
    ball.vel[2] = -ball.vel[2]
    playBallSfx(true)
  end

  if ballHitPaddle(p1) then
    ball.vel[1] = cfg.ballSpeed
    playBallSfx()
  elseif ballHitPaddle(p2) then
    ball.vel[1] = -cfg.ballSpeed
    playBallSfx()
  end

  if ball.pos[1] >= cfg.windowCenter[1] + cfg.gameDims[1] then
    p1.score = p1.score + 1
    resetBall()
  elseif ball.pos[1] <= cfg.windowCenter[1] - cfg.gameDims[1] then
    p2.score = p2.score + 1
    resetBall()
  end

  p1.move = input.p1_up and cfg.paddleSpeed or input.p1_down and -cfg.paddleSpeed or 0
  p2.move = input.p2_up and cfg.paddleSpeed or input.p2_down and -cfg.paddleSpeed or 0

  drawBorders()
  drawPaddle(p1)
  drawPaddle(p2)
  drawBall()
  drawScore()
  drawControls()
end

function resetBall()
  ball.pos = {cfg.windowCenter[1], cfg.windowCenter[2]}
  ball.vel = {cfg.ballSpeed * util.randomDirection(), cfg.ballSpeed * util.randomDirection()}
end

function ballHitPaddle(paddle)
  return math.abs(ball.pos[1] - paddle.pos[1]) < cfg.paddleDims[1] + cfg.ballDims[1] and math.abs(ball.pos[2] - paddle.pos[2]) < cfg.paddleDims[2]
end

function drawBorders()
  self.canvas:drawRect(canvasRect, {20, 20, 40})
  self.canvas:drawRect(gameRect, {0, 40, 0})
end

function drawBall()
  self.canvas:drawRect(
      {ball.pos[1] - cfg.ballDims[1], ball.pos[2] - cfg.ballDims[2], ball.pos[1] + cfg.ballDims[1], ball.pos[2] + cfg.ballDims[2]},
      {255, 255, 255}
    )
end

function drawPaddle(paddle)
  self.canvas:drawRect(
      {paddle.pos[1] - cfg.paddleDims[1], paddle.pos[2] - cfg.paddleDims[2], paddle.pos[1] + cfg.paddleDims[1], paddle.pos[2] + cfg.paddleDims[2]},
      {255, 255, 255}
    )
end

function drawScore()
  self.canvas:drawText(
    string.format(cfg.scoreText, p1.score, p2.score),
    {position={cfg.windowCenter[1], gameRect[4] + 20}, horizontalAnchor="mid", verticalAnchor="top"},
    14,
    {255, 255, 255}
  )
end

function drawControls()
  self.canvas:drawText(
    cfg.controlsText,
    {position={cfg.windowCenter[1], gameRect[4] - 155}, horizontalAnchor="mid", verticalAnchor="top"},
    8,
    {255, 255, 255}
  )
end

function playBallSfx(skipCooldown)
  if skipCooldown or ballSfxCooldownTimer == 0 then
    widget.playSound(sfx.ballHit)
    ballSfxCooldownTimer = ballSfxCooldown
  end
end

function canvasKeyEvent(key, isKeyDown)
  if isKeyDown then
    introActive = false

    if not gamePaused and key == input.key.reset then
      newGame()
    end

    gamePaused = (key == input.key.pause and not gamePaused)
  end

  if key == input.key.p1_up then
    input.p1_up = isKeyDown
  elseif key == input.key.p1_down then
    input.p1_down = isKeyDown
  elseif key == input.key.p2_up then
    input.p2_up = isKeyDown
    multiplayer = true
  elseif key == input.key.p2_down then
    input.p2_down = isKeyDown
    multiplayer = true
  end
end