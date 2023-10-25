function init()
  animationConfig = config.getParameter("animation")
  if animationConfig then
    local itemConfig = root.itemConfig(config.getParameter("itemName"))
    animationConfig = root.assetJson(animationConfig:sub(1,1) == "/" and animationConfig or itemConfig.directory..itemConfig.config.animation).extraSounds
  end
  activeItem.setArmAngle(-math.pi / 2)
  swingStart = config.getParameter("swingStart", -60) * math.pi / 180
  swingFinish = config.getParameter("swingFinish", 40) * math.pi / 180
  currentSwing = swingStart
  currentAngle = -swingStart

  useTime = config.getParameter("useTime",0.1)
  foodValue = config.getParameter("foodValue",0)
  ammoUsage = config.getParameter("ammoUsage",1)
  resource = config.getParameter("resource","food")
  returnItem = config.getParameter("returnItem")

  possibleEffects = config.getParameter("effects")
  selectEffects()
  blockingEffects = config.getParameter("blockingEffects")

  local category = config.getParameter("category","")
  if category == "preparedFood" then category = "food" end
  soundSet = config.getParameter("soundSet", animator.hasSound(category) and category or "none")
  emote = config.getParameter("emote", (category == "food" or category == "drink") and "eat" or nil)
  if emote == "" then emote = nil end

  giveWellfed = config.getParameter("giveWellfed",true) and resource == "food"
  autoFire = config.getParameter("autoFire")

  justUsed = false

  if emote and type(emote) == "string" then emote = {emote} end
  if type(soundSet) == "string" then soundSet = {soundSet} end
end

function update(dt, fireMode)
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(aimDirection)

  if not useTimer and fireMode == "primary" and player and not justUsed then
    if blockingEffects then for i = 1, #blockingEffects do if status.uniqueStatusEffectActive(blockingEffects[i]) then return end end end
    useTimer = useTime
    justUsed = autoFire and true or false
  end

  if useTimer then
    useTimer = useTimer - dt
    currentAngle = ((currentSwing - swingFinish) * useTimer / 0.15 * 1)/2.4
    activeItem.setArmAngle(currentAngle)

    if currentAngle >= swingFinish then -- and useTimer <= 0 then
      applyAdditionalEffects()
      local selectedSoundSet = soundSet[math.random(#soundSet)]
      if animationConfig[selectedSoundSet] then
        animator.playSound(selectedSoundSet)
        for i = 1, #animationConfig[selectedSoundSet] do
          animator.playSound(selectedSoundSet..animationConfig[selectedSoundSet][i])
        end
      else
        animator.playSound(selectedSoundSet)
      end
      if emote then activeItem.emote(emote[math.random(#emote)]) end
      if status.isResource(resource) then
        if giveWellfed and status.resourceMax(resource) <= foodValue + status.resource(resource) then
          status.addEphemeralEffect("wellfed")
        end
        status.modifyResource(resource,foodValue)
      elseif giveWellfed then
        status.addEphemeralEffect("wellfed")
      end

      if effects then status.addEphemeralEffects(effects) end

      item.consume(ammoUsage)
      activeItem.setArmAngle(-math.pi / 2)
      currentAngle = -swingStart
      currentSwing = swingStart
      useTimer = nil
      if returnItem then
        player.giveItem(returnItem)
      end
    end
  end
  justUsed = fireMode == "primary" and not autoFire
end

function selectEffects()
  effects = possibleEffects
  if effects and type(effects[1]) == "table" then
    effects = effects[math.random(#effects)]
  end
end
function applyAdditionalEffects() end