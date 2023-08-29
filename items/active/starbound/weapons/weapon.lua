require "/scripts/util.lua"

-- handles weapon stances, animations, and abilities
Weapon = {}

function Weapon:new(weaponConfig)
  local newWeapon = weaponConfig or {}
  newWeapon.damageLevelMultiplier = config.getParameter("damageLevelMultiplier", root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1)))
  newWeapon.elementalType = config.getParameter("elementalType")
  newWeapon.muzzleOffset = config.getParameter("muzzleOffset") or {0,0}
  newWeapon.aimOffset = config.getParameter("aimOffset") or (newWeapon.muzzleOffset[2] - 0.25)
  newWeapon.abilities = {}
  newWeapon.transformationGroups = {}
  newWeapon.handGrip = config.getParameter("handGrip", "inside")
  setmetatable(newWeapon, extend(self))
  return newWeapon
end

function Weapon:init()
  attackTimer = 0
  aimAngle = 0
  aimDirection = 1

  animator.setGlobalTag("elementalType", elementalType or "")

  for _,ability in pairs(abilities) do
    ability:init()
  end
end

function Weapon:update(dt, fireMode, shiftHeld)
  attackTimer = math.max(0, attackTimer - dt)

  for _,ability in pairs(abilities) do
    ability:update(dt, fireMode, shiftHeld)
  end

  if currentState then
    if coroutine.status(stateThread) ~= "dead" then
      local status, result = coroutine.resume(stateThread)
      if not status then error(result) end
    else
      currentAbility:uninit()
      currentAbility = nil
      currentState = nil
      stateThread = nil
      if onLeaveAbility then
        onLeaveAbility()
      end
    end
  end

  if stance then
    self:updateAim()
    relativeArmRotation = relativeArmRotation + armAngularVelocity * dt
    relativeWeaponRotation = relativeWeaponRotation + weaponAngularVelocity * dt
  end

  if handGrip == "wrap" then
    activeItem.setOutsideOfHand(self:isFrontHand())
  elseif handGrip == "embed" then
    activeItem.setOutsideOfHand(not self:isFrontHand())
  elseif handGrip == "outside" then
    activeItem.setOutsideOfHand(true)
  elseif handGrip == "inside" then
    activeItem.setOutsideOfHand(false)
  end

  self:clearDamageSources()
end

function Weapon:uninit()
  for _,ability in pairs(abilities) do
    if ability.uninit then
      ability:uninit(true)
    end
  end
end

function Weapon:clearDamageSources()
  if not damageWasSet and not damageCleared then
    activeItem.setItemDamageSources({})
    damageCleared = true
  end

  if not ownerDamageWasSet and not ownerDamageCleared then
    activeItem.setDamageSources({})
    ownerDamageCleared = true
  end

  damageWasSet = false
  ownerDamageWasSet = false
end

function Weapon:setAbilityState(ability, state, ...)
  currentAbility = ability
  currentState = state
  stateThread = coroutine.create(state)
  local status, result = coroutine.resume(stateThread, ability, ...)
  if not status then
    error(result)
  end
end

function Weapon:addAbility(newAbility)
  newAbility.weapon = self
  table.insert(abilities, newAbility)
end

function Weapon:addTransformationGroup(name, offset, rotation, rotationCenter)
  transformationGroups = transformationGroups or {}
  table.insert(transformationGroups, {name = name, offset = offset, rotation = rotation, rotationCenter = rotationCenter})
end

function Weapon:updateAim()
  for _,group in pairs(transformationGroups) do
    animator.resetTransformationGroup(group.name)
    animator.translateTransformationGroup(group.name, group.offset)
    animator.rotateTransformationGroup(group.name, group.rotation, group.rotationCenter)
    animator.translateTransformationGroup(group.name, weaponOffset)
    animator.rotateTransformationGroup(group.name, relativeWeaponRotation, relativeWeaponRotationCenter)
  end

  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(aimOffset, activeItem.ownerAimPosition())

  if stance.allowRotate then
    aimAngle = aimAngle
  elseif stance.aimAngle then
    aimAngle = stance.aimAngle
  end
  activeItem.setArmAngle(aimAngle + relativeArmRotation)

  local isPrimary = activeItem.hand() == "primary"
  if isPrimary then
    -- primary hand weapons should set their aim direction whenever they can be flipped,
    -- unless paired with an alt hand that CAN'T flip, in which case they should use that
    -- weapon's aim direction
    if stance.allowFlip then
      if activeItem.callOtherHandScript("dwDisallowFlip") then
        local altAimDirection = activeItem.callOtherHandScript("dwAimDirection")
        if altAimDirection then
          aimDirection = altAimDirection
        end
      else
        aimDirection = aimDirection
      end
    end
  elseif stance.allowFlip then
    -- alt hand weapons should be slaved to the primary whenever they can be flipped
    local primaryAimDirection = activeItem.callOtherHandScript("dwAimDirection")
    if primaryAimDirection then
      aimDirection = primaryAimDirection
    else
      aimDirection = aimDirection
    end
  end

  activeItem.setFacingDirection(aimDirection)

  activeItem.setFrontArmFrame(stance.frontArmFrame)
  activeItem.setBackArmFrame(stance.backArmFrame)
end

function Weapon:setOwnerDamage(damageConfig, damageArea, damageTimeout)
  ownerDamageWasSet = true
  ownerDamageCleared = false
  activeItem.setDamageSources({ self:damageSource(damageConfig, damageArea, damageTimeout) })
end

function Weapon:setOwnerDamageAreas(damageConfig, damageAreas, damageTimeout)
  ownerDamageWasSet = true
  ownerDamageCleared = false
  local damageSources = {}
  for i, area in ipairs(damageAreas) do
    table.insert(damageSources, self:damageSource(damageConfig, area, damageTimeout))
  end
  activeItem.setDamageSources(damageSources)
end

function Weapon:setDamage(damageConfig, damageArea, damageTimeout)
  damageWasSet = true
  damageCleared = false
  activeItem.setItemDamageSources({ self:damageSource(damageConfig, damageArea, damageTimeout) })
end

function Weapon:setDamageAreas(damageConfig, damageAreas, damageTimeout)
  damageWasSet = true
  damageCleared = false
  local damageSources = {}
  for i, area in ipairs(damageAreas) do
    table.insert(damageSources, self:damageSource(damageConfig, area, damageTimeout))
  end
  activeItem.setItemDamageSources(damageSources)
end

function Weapon:damageSource(damageConfig, damageArea, damageTimeout)
  if damageArea then
    local knockback = damageConfig.knockback
    if knockback and damageConfig.knockbackDirectional ~= false then
      knockback = knockbackMomentum(damageConfig.knockback, damageConfig.knockbackMode, aimAngle, aimDirection)
    end
    local damage = damageConfig.baseDamage * damageLevelMultiplier * activeItem.ownerPowerMultiplier()

    local damageLine, damagePoly
    if #damageArea == 2 then
      damageLine = damageArea
    else
      damagePoly = damageArea
    end

    return {
      poly = damagePoly,
      line = damageLine,
      damage = damage,
      trackSourceEntity = damageConfig.trackSourceEntity,
      sourceEntity = activeItem.ownerEntityId(),
      team = activeItem.ownerTeam(),
      damageSourceKind = damageConfig.damageSourceKind,
      statusEffects = damageConfig.statusEffects,
      knockback = knockback or 0,
      rayCheck = true,
      damageRepeatGroup = damageRepeatGroup(damageConfig.timeoutGroup),
      damageRepeatTimeout = damageTimeout or damageConfig.timeout
    }
  end
end

function Weapon:setStance(stance)
  stance = stance
  weaponOffset = stance.weaponOffset or {0,0}
  relativeWeaponRotation = util.toRadians(stance.weaponRotation or 0)
  relativeWeaponRotationCenter = stance.weaponRotationCenter or {0, 0}
  relativeArmRotation = util.toRadians(stance.armRotation or 0)
  armAngularVelocity = util.toRadians(stance.armAngularVelocity or 0)
  weaponAngularVelocity = util.toRadians(stance.weaponAngularVelocity or 0)

  for stateType, state in pairs(stance.animationStates or {}) do
    animator.setAnimationState(stateType, state)
  end

  for _, soundName in pairs(stance.playSounds or {}) do
    animator.playSound(soundName)
  end

  for _, particleEmitterName in pairs(stance.burstParticleEmitters or {}) do
    animator.burstParticleEmitter(particleEmitterName)
  end

  activeItem.setFrontArmFrame(stance.frontArmFrame)
  activeItem.setBackArmFrame(stance.backArmFrame)
  activeItem.setTwoHandedGrip(stance.twoHanded or false)
  activeItem.setRecoil(stance.recoil == true)
end

function Weapon:isFrontHand()
  return (activeItem.hand() == "primary") == (aimDirection < 0)
end

function Weapon:faceVector(vector)
  return {vector[1] * aimDirection, vector[2]}
end

-- Weapon abilities, state machines for weapon functionality

WeaponAbility = {}

function WeaponAbility:new(abilityConfig)
  local newAbility = abilityConfig or {}
  newAbility.stances = newAbility.stances or {}
  setmetatable(newAbility, extend(self))
  return newAbility
end

function WeaponAbility:update(dt, fireMode, shiftHeld)
  dt, fireMode, shiftHeld = dt, fireMode, shiftHeld
end

function WeaponAbility:setState(state, ...)
  weapon:setAbilityState(self, state, ...)
end

function getAbility(abilitySlot, abilityConfig)
  for _, script in ipairs(abilityConfig.scripts) do
    require(script)
  end
  local class = _ENV[abilityConfig.class]
  abilityConfig.abilitySlot = abilitySlot
  return class:new(abilityConfig)
end

function getPrimaryAbility()
  local primaryAbilityConfig = config.getParameter("primaryAbility")
  return getAbility("primary", primaryAbilityConfig)
end

function getAltAbility()
  local altAbilityConfig = config.getParameter("altAbility")
  if altAbilityConfig then
    return getAbility("alt", altAbilityConfig)
  end
end

function partDamageArea(partName, polyName)
  return animator.partPoly(partName, polyName or "damageArea")
end

function damageRepeatGroup(mode)
  mode = mode or ""
  return activeItem.ownerEntityId() .. config.getParameter("itemName") .. activeItem.hand() .. mode
end

function knockbackMomentum(knockback, knockbackMode, aimAngle, aimDirection)
  knockbackMode = knockbackMode or "aim"

  if type(knockback) == "table" then
    return knockback
  end

  if knockbackMode == "facing" then
    return {aimDirection * knockback, 0}
  elseif knockbackMode == "aim" then
    local aimVector = vec2.rotate({knockback, 0}, aimAngle)
    aimVector[1] = aimDirection * aimVector[1]
    return aimVector
  end
  return knockback
end

-- used for cross-hand communication while dual wielding
function dwAimDirection()
  if self and weapon then
    return weapon.aimDirection
  end
end

function dwDisallowFlip()
  if weapon and weapon.stance then
    return not weapon.stance.allowFlip
  end

  return false
end
