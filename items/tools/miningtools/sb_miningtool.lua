require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

MiningTool = WeaponAbility:new()
function MiningTool:init()
  self.toolRange = root.assetJson("/player.config:interactRadius")
  local client = root.assetJson("/client.config")
  self.defaultFootstepSound = client.defaultFootstepSound
  self.defaultDingSound = client.defaultDingSound

  --Define these in the item's root instead of in both ability slots
  self.durability = config.getParameter("durability")
  self.durabilityPerUse = config.getParameter("durabilityPerUse", self.durabilityPerUse)
  self.canBeRepaired = config.getParameter("canBeRepaired", self.canBeRepaired)

  self.blockRadius = config.getParameter("blockRadius", self.blockRadius)
  self.altBlockRadius = config.getParameter("altBlockRadius", self.altBlockRadius)
  self.tileDamageType = config.getParameter("tileDamageType", self.tileDamageType)
  self.tileDamage = config.getParameter("tileDamage", 1.5)
  self.tileDamageBlunted = config.getParameter("tileDamageBlunted", 0.1)
  self.animated = config.getParameter("animated", self.animated)
  self.hitObjects = config.getParameter("hitObjects", self.hitObjects)

  local sfx = root.assetJson("/sfx.config")
  animator.setSoundVolume("fire", sfx.miningToolVolume)
  animator.setSoundVolume("blockSound", sfx.miningBlockVolume)

  animationActive = self.animated and "inactive" or "idle"
  self.weapon:setStance(self.stances.idle)
  animator.setAnimationState("tool", animationActive)

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
    animator.setAnimationState("tool", animationActive)
  end
end

function MiningTool:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if not self.weapon.currentAbility and self:shouldFire() then
    self:setState(self.windup)
  end
end

function MiningTool:shouldFire()
  return self.fireMode == self.activatingFireMode
end

function MiningTool:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  if self:shouldFire() then
    self:setState(self.fire)
  end
end

function MiningTool:fire()
  if self.animated then animator.setAnimationState("tool", "active") end
  entityPosition = world.entityPosition(activeItem.ownerEntityId())
  self.hitPosition = activeItem.ownerAimPosition()
  local distance = vec2.mag(world.distance(entityPosition, self.hitPosition))
  if not player.isAdmin() and distance > self.toolRange then
    return
  end

  local radius = self.shiftHeld and self.altBlockRadius or self.blockRadius
  local brushArea = self:tileAreaBrush(radius, self.hitPosition)
  local valid = false
  for i = 1, #brushArea do
    valid = world.material(brushArea[i], self.layer) or (self.hitObjects and world.tileIsOccupied(brushArea[i]))
    if valid then break end
  end
  if not valid then return end

  if self.tileDamageType == "tilling" then
    self:till(brushArea)
  else
    world.damageTiles(brushArea, self.layer, entityPosition, self.tileDamageType, self:getTileDamage(), self.harvestLevel, activeItem.ownerEntityId())
    self:changeDurability()
    --so 'perUse' was literal... I thought it was per block, since you use it on multiple blocks at once...
    --Anyway, hoes take damage in the till function
  end

  animator.setSoundPool("blockSound", {self:getBlockSound(brushArea)})
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  coroutine.yield()

  animator.playSound("blockSound")
  animator.playSound("fire")

  util.wait(self.stances.fire.duration)

  if self:shouldFire() then
    self:setState(self.fire)
  end
end

function MiningTool:getTileDamage()
  return self.durability and config.getParameter("durabilityHit", 1) <= 0 and self.tileDamageBlunted or self.tileDamage
end

function MiningTool:till(brushArea)
  for i = 1, #brushArea do
    if not world.material({brushArea[1][1], brushArea[1][2] + 1}, self.layer) then
      local target = world.material(brushArea[i], self.layer)
      if target and target:sub(1, 13) ~= "metamaterial:" then
        target = root.materialConfig(target).config
        local newMod = self.tilledMods[tostring(target.tillableMod)] or "tilleddry"
        if (world.mod(brushArea[i], self.layer) or "") ~= newMod then
          world.damageTiles({brushArea[i]}, self.layer, entityPosition, self.tileDamageType, self:getTileDamage(), self.harvestLevel, activeItem.ownerEntityId())
          if not world.mod(brushArea[i], self.layer) then --placeMod erases whatever was there, so make sure whatever was there is now gone
            if target.tillableMod and target.soil then --root.modConfig only accepts strings while root.liquidConfig accepts strings and ID's my BELOATHED
              world.placeMod(brushArea[i], self.layer, newMod, 0, true)
              self:changeDurability()
            end
          end
        end
      end
    end
  end
end

function MiningTool:changeDurability(amount)
  if self.durability and not player.isAdmin() then
    activeItem.setInstanceValue("durabilityHit", config.getParameter("durabilityHit", self.durability) - self.durabilityPerUse)
    if config.getParameter("durabilityHit") <= 0 and not self.canBeRepaired then
      animator.playSound("break")
      item.consume(1)
    end
  end
end

function MiningTool:getBlockSound(brushArea)
  for _,pos in pairs(brushArea) do
    if world.isTileProtected(pos) then
      return self.defaultDingSound
    else
      local material = world.material(pos, self.layer)
      local mod = world.mod(pos, self.layer)
      if type(material) ~= "string" then return nil end
      local blockSound = material and root.materialMiningSound(material, mod) or root.materialFootstepSound(material, mod)
      return (type(blockSound) == "string" and blockSound ~= self.defaultFootstepSound and blockSound) or nil
    end
  end
end

function MiningTool:tileAreaBrush(radius, centerPosition)
  local result = jarray()
  local offset = {-radius/2, -radius/2}
  local intOffset = util.map(vec2.add(offset, centerPosition), util.round)

  for x = 0, radius-1 do
    for y = 0, radius-1 do
      local intPos = util.map({x, y}, util.round)
      table.insert(result, vec2.add(intPos, intOffset))
    end
  end
  return result
end

function MiningTool:uninit()
  self.weapon:setStance(self.stances.idle)
  animator.setAnimationState("tool", animationActive)
end
