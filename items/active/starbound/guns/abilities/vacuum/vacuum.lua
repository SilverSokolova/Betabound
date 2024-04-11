require "/scripts/poly.lua"
require "/scripts/vec2.lua"

SB_Vacuum = WeaponAbility:new()

function SB_Vacuum:init()
    self.vacuumPoint = {
      type = "RadialForceRegion",
      center = self.weapon.muzzleOffset,
      targetRadialVelocity = self.pointSpeed,
      outerRadius = self.outerRadius,
      innerRadius = self.innerRadius,
      controlForce = self.pointForce,
      categoryWhitelist = self.categoryWhitelist
    }
    self.damageConfigDamage.baseDamage = self.baseDps
    self.cooldownTimer = 0
    self:reset()
end

function SB_Vacuum:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.active
    and not world.lineTileCollision(mcontroller.position(), vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset)))
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy") then

    self:setState(self.fire)
  end
end

function SB_Vacuum:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon.aimAngle = 0
  self.weapon:updateAim()
  animator.setAnimationState("vacuum", "active")
  animator.playSound("vacuumStart")
  animator.playSound("vacuumLoop", -1)

  self.active = true

  while self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and status.overConsumeResource("energy", self.energyUsage * self.dt)
    and not world.lineTileCollision(mcontroller.position(), vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))) do
    if self.walkWhileFiring then
      mcontroller.controlModifiers({runningSuppressed = true})
    end

    local forceVector = vec2.rotate(self.coneSpeed, self.weapon.aimAngle)
    forceVector[1] = forceVector[1] * self.weapon.aimDirection

    if world.isTileProtected(mcontroller.position()) then
      self.weapon:setDamage(self.damageConfigDamage, animator.partPoly("vacuumCone", "vacuumPoly"), 0.25)
    else
      --self.weapon:setDamage(self.damageConfigVacuum, animator.partPoly("vacuumCone", "vacuumPoly"), 0.25)
      --world.spawnProjectile(self.projectileType, vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset)))
      local aimAngle, facingDir = activeItem.aimAngleAndDirection(0, vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset)))
      local originalAimAngle = aimAngle
      aimAngle = aimAngle * facingDir
      local vacuumEnd = vec2.add(mcontroller.position(), {(self.weapon.muzzleOffset[1] + 13) * facingDir, self.weapon.muzzleOffset[2]})
      world.debugText("^shadow,red;%s", "*", vacuumEnd, "red")
    local agony = vec2.withAngle(aimAngle)
      local xVector = (forceVector[1] - agony[1])
      local yVector = (-forceVector[2] + agony[2]) * (originalAimAngle < 0 and 1 or -1)
      if aimAngle < 0 and yVector <= 0 then
        yVector = -yVector
      elseif aimAngle < 0 and yVector <= 0 and facingDir == -1 then
        --yVector = -yVector
      end
      if facingDir == -1 then
        yVector = -yVector
      end
      world.debugText("^shadow,red;Aim: %s\nX: %s\nY: %s\nF: %s", originalAimAngle, xVector, yVector, facingDir, {mcontroller.position()[1]-2, mcontroller.position()[2]+2}, "red")
    --What do you MEAN GradientForceRegions don't work for activeItems
    activeItem.setItemForceRegions({
      {
        type = "DirectionalForceRegion",
        polyRegion = animator.partPoly("vacuumCone", "vacuumPolyTop"),
        xTargetVelocity = xVector,
        yTargetVelocity = yVector,
        controlForce = self.coneForce,
        categoryWhitelist = self.categoryWhitelist
      }
      --[[{
        type = "DirectionalForceRegion",
        polyRegion = animator.partPoly("vacuumCone", "vacuumPolyBottom"),
        xTargetVelocity = forceVector[1],
        yTargetVelocity = forceVector[2],
        controlForce = self.coneForce,
        categoryWhitelist = self.categoryWhitelist
      }]]
      --self.vacuumPoint
      }
      )
    end

    coroutine.yield()
  end

  activeItem.setItemForceRegions({})

  animator.setAnimationState("vacuum", "idle")
  animator.stopAllSounds("vacuumLoop")

  self.cooldownTimer = self.cooldownTime

  self.active = false
end

function SB_Vacuum:reset()
  animator.setAnimationState("vacuum", "idle")
  animator.stopAllSounds("vacuumLoop")
  activeItem.setItemForceRegions({})
  self.active = false
end

function SB_Vacuum:uninit()
  self:reset()
end