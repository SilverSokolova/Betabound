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
      self.weapon:setDamage(self.damageConfigVacuum, animator.partPoly("vacuumCone", "vacuumPoly"), 0.25)
      local aimAngle, facingDir = activeItem.aimAngleAndDirection(0, vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset)))
      local withAngle = vec2.withAngle(aimAngle)
      local xVelocity = forceVector[1] - withAngle[1]
      local yVelocity = (-forceVector[2] + withAngle[2]) * aimAngle < 0 and 1 or -1
      aimAngle = aimAngle * facingDir

      if aimAngle < 0 and yVelocity <= 0 then
        yVelocity = -yVelocity
      end
      yVelocity = yVelocity * facingDir
      --world.debugText("^shadow,red;Aim: %s\nX: %s\nY: %s\nF: %s", aimAngle, xVelocity, yVelocity, facingDir, {mcontroller.position()[1]-2, mcontroller.position()[2]+2}, "red")
      activeItem.setItemForceRegions({
        {
          type = "DirectionalForceRegion",
          polyRegion = animator.partPoly("vacuumCone", "vacuumPoly"),
          xTargetVelocity = xVelocity,
          yTargetVelocity = yVelocity,
          controlForce = self.coneForce,
          categoryWhitelist = self.categoryWhitelist
        }, self.vacuumPoint
      })
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