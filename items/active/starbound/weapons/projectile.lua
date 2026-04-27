function projectileInit(self, primaryAbility)
  self.projectilePower = (self.damageConfig.baseDamage * config.getParameter("damageLevelMultiplier", 1)) * (self.projectileDamageMultiplier or 0.6)
  self.projectileType = primaryAbility.projectileType or false
  self.projectileId = world.spawnProjectile("invisibleprojectile", {0, -99})
  self.projectileConfig = primaryAbility.projectileConfig or {}
  self.projectileCount = self.projectileCount or 1
  if self.projectileType then self.projectileOffset = primaryAbility.projectileOffset or {0, 0.1} end
end

function projectileFire(self)
  if self.projectileType and self.projectileId and not world.entityExists(self.projectileId) then
    if animator.hasSound("projectileFire") then animator.playSound("projectileFire") end

    local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(self.inaccuracy, 0))
    aimVector[1] = aimVector[1] * mcontroller.facingDirection()

    local handPosition = self.handPositionOffset and activeItem.handPosition(self.handPositionOffset) or {0, 0}
    for i = 1, self.projectileCount do
      local position = mcontroller.position()
      position = {position[1], position[2] - (mcontroller.crouching() and 0.75 or 0)} --0.75 to keep starcleaver above ground
      position = self.holdDamageConfig and vec2.add(position, activeItem.handPosition({-3, 7}))
        or vec2.add(vec2.add(position, handPosition), {self.projectileOffset[1] * mcontroller.facingDirection(), (-1.5 + self.projectileOffset[2])})
      local params = sb.jsonMerge({
        powerMultiplier = math.min(activeItem.ownerPowerMultiplier() / 3, 1),
        power = self.projectilePower
--        damageType = "ignoresdef"
      }, self.projectileConfig)
      self.projectileId = world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), aimVector, false, params)
    end
  end
end