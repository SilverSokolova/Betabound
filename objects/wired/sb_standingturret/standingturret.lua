require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
   mechArm = root.assetJson("/vehicles/modularmech/mechparts_arm.config")
   self.projectile = {"standardbullet",{},0} containerCallback()
   self.defaultProjectile = {"standardbullet",{},0}
   -- Positions and angles
   self.baseOffset = config.getParameter("baseOffset")
   self.basePosition = vec2.add(object.position(), self.baseOffset)
   self.tipOffset = config.getParameter("tipOffset") --This is offset from BASE position, not object origin

   self.rotationSpeed = util.toRadians(config.getParameter("rotationSpeed"))
   self.offAngle = util.toRadians(config.getParameter("offAngle", -30))

   -- Targeting
   self.targetQueryRange = config.getParameter("targetQueryRange")
   self.targetMinRange = config.getParameter("targetMinRange")
   self.targetMaxRange = config.getParameter("targetMaxRange")
   self.targetAngleRange = util.toRadians(config.getParameter("targetAngleRange"))

   -- Energy
   storage.energy = storage.energy or 0
   self.regenBlockTimer = 0
   self.energyRegen = config.getParameter("energyRegen")
   self.maxEnergy = config.getParameter("maxEnergy")
   self.energyRegenBlock = config.getParameter("energyRegenBlock")

   self.energyBarOffset = config.getParameter("energyBarOffset")
   self.verticalScaling = config.getParameter("verticalScaling")
   animator.translateTransformationGroup("energy", self.energyBarOffset)

   self.state = FSM:new()
   self.state:set(offState)
end

function update(dt)
   self.state:update(dt)

   world.debugPoint(firePosition(), "green")

   if storage.energy == 0 then
      self.blockEnergyUsage = true
   elseif storage.energy == self.maxEnergy then
      self.blockEnergyUsage = false
   end

   if self.regenBlockTimer > 0 then
      self.regenBlockTimer = math.max(0, self.regenBlockTimer - script.updateDt())
   else
      storage.energy = math.min(self.maxEnergy, storage.energy + self.energyRegen * script.updateDt())
   end

   local ratio = storage.energy / self.maxEnergy
   local animationState = "full"

   if ratio <= 0.75 then animationState = "high" end
   if ratio <= 0.5 then animationState = "medium" end
   if ratio <= 0.25 then animationState = "low" end
   if ratio <= 0 then animationState = "none" end

   local scale = self.verticalScaling and {1, ratio * 11} or {ratio * 11, 1}

   animator.resetTransformationGroup("energy")
   animator.scaleTransformationGroup("energy", scale)
   animator.translateTransformationGroup("energy", self.energyBarOffset)

   animator.setAnimationState("energy", animationState)
end

----------------------------------------------------------------------------------------------------------
-- States

function offState()
   animator.setAnimationState("attack", "dead")
   animator.playSound("powerDown")
   object.setAllOutputNodes(false)

   while true do
      animator.rotateGroup("gun", self.offAngle)

      if active() then break end
      coroutine.yield()
   end

   animator.playSound("powerUp")

   self.state:set(scanState)
end

function scanState()
   animator.setAnimationState("attack", "idle")
   util.wait(0.5)
   animator.playSound("scan")
   object.setAllOutputNodes(false)

   local timer = 0

   local scanInterval = config.getParameter("scanInterval")
   local scanAngle = util.toRadians(config.getParameter("scanAngle"))

   local scan = coroutine.wrap(function()
   while true do
      local target = findTarget()
      if target then return self.state:set(fireState, target) end
      util.wait(1.0)
   end
   end)

   while true do
      timer = timer + script.updateDt() / scanInterval
      if timer > 1 then timer = 0 end
      animator.rotateGroup("gun", scanAngle * math.sin(timer * math.pi*2))

      scan()

      if not active() then break end
      coroutine.yield()
   end

   self.state:set(offState)
end

function fireState(targetId)
   animator.setAnimationState("attack", "attack")
   animator.playSound("foundTarget")
   object.setAllOutputNodes(true)

   local maxFireAngle = util.toRadians(config.getParameter("maxFireAngle"))
   local fire = coroutine.wrap(autoFire)

   while true do
      if not active() then return self.state:set(offState) end

      if not world.entityExists(targetId) then break end

      local targetPosition = world.entityPosition(targetId)
      local toTarget = world.distance(targetPosition, self.basePosition)
      local targetDistance = world.magnitude(toTarget)
      local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])

      if targetDistance > self.targetMaxRange or targetDistance < self.targetMinRange or world.lineTileCollision(self.basePosition, targetPosition) then break end
      if math.abs(targetAngle) > self.targetAngleRange then break end

      animator.rotateGroup("gun", targetAngle)

      local rotation = animator.currentRotationAngle("gun")
      if math.abs(util.angleDiff(targetAngle, rotation)) < maxFireAngle then
         fire()
      end
      coroutine.yield()
   end

   util.wait(1.0)

   self.state:set(scanState)
end

----------------------------------------------------------------------------------------------------------
-- Helping functions, not states

function consumeEnergy(amount)
   if storage.energy <= 0 or self.blockEnergyUsage then return false end
   storage.energy = storage.energy - amount
   self.regenBlockTimer = self.energyRegenBlock
   return true
end

function active()
   if object.isInputNodeConnected(0) then
      return object.getInputNodeLevel(0)
   end

   storage.active = storage.active ~= nil and storage.active or true
   return storage.active
end

function firePosition()
   local animationPosition = vec2.div(config.getParameter("animationPosition"), 8)
   local fireOffset = vec2.add(animationPosition, animator.partPoint("gun", "projectileSource"))
   return vec2.add(object.position(), fireOffset)
end

function containerCallback()
   local level = math.max(1.0, world.threatLevel())
   local power = config.getParameter("power", 2)
   power = root.evalFunction("monsterLevelPowerMultiplier", level) * power
   --power, firetime
   self.misc = {power,config.getParameter("fireTime", 0.1),config.getParameter("energyUsage")}
   local contents = world.containerItems(entity.id())
   if contents ~= nil then
      if contents[1] ~= nil then
         local projectile = {contents[1].parameters or {}, root.itemConfig(contents[1].name).config}
         if projectile[2].mechPart and projectile[2].mechPart[1] == "arm" then
            local mechName = projectile[2].mechPart[2]
            local mechParams = mechArm[mechName].partParameters
            if mechParams.armClass == "GunArm" then self.projectile = {mechParams.projectileType,mechParams.projectileParameters,0}
            return end
         end
         projectile[3] = projectile[2].ammoUsage or 0
         projectile[1].primaryAbility = projectile[1].primaryAbility or {} --self.projectile[1]
         projectile[2].primaryAbility = projectile[2].primaryAbility or {} --self.projectile[1]
         projectile[1].projectileType = projectile[1].projectileType or nil
         projectile[2].projectileType = projectile[2].projectileType or nil
         self.projectile = {projectile[1].projectileType or
         projectile[2].projectileType or
         projectile[1].primaryAbility.projectileType or
         projectile[2].primaryAbility.projectileType or
         self.defaultProjectile[1],projectile[1].primaryAbility.projectileParameters or
         projectile[2].primaryAbility.projectileParameters or
         projectile[1].projectileParameters or projectile[2].projectileParameters or {}}
         self.projectile[3] = projectile[3] or 0
         local o = self.misc
         --TODO: should probably do something about the bubble gun not working because the projectile speed is a range
         self.misc[1] = projectile[1].primaryAbility.baseDamageFactor or projectile[2].primaryAbility.baseDamageFactor or self.misc[1]
         --self.misc[2] = projectile[1].primaryAbility.fireTimeFactor or projectile[2].primaryAbility.fireTimeFactor or self.misc[2]
         self.misc[3] = projectile[1].primaryAbility.energyUsageFactor or projectile[2].primaryAbility.energyUsageFactor or self.misc[3]
         for i = 1, 3 do if self.misc[i] ~= o[i] then self.misc[i] = (root.evalFunction("monsterLevelPowerMultiplier", level) * power) * 90 end end

      else self.projectile = self.defaultProjectile end end
      end

      function getProjectiles(a)
         if type(a) == "table" then return a[math.random(1,#a)] else return a end
      end

      -- Coroutine
      function autoFire()
         self.projectile[2].power = self.misc[1]

         while true do
            while not consumeEnergy(self.misc[3]) do coroutine.yield() end

               local rotation = animator.currentRotationAngle("gun")
               local aimVector = {object.direction() * math.cos(rotation), math.sin(rotation)}
               world.spawnProjectile(getProjectiles(self.projectile[1]), firePosition(), entity.id(), aimVector, false, self.projectile[2])
               if self.projectile[3] > 0 then world.containerTakeNumItemsAt(entity.id(),0,self.projectile[3]) end
               animator.playSound("fire")
               util.wait(self.misc[2])
            end
         end

         -- Coroutine
         function findTarget()
            local nearEntities = world.entityQuery(self.basePosition, self.targetQueryRange, { includedTypes = { "monster", "npc", "player" } })
            return util.find(nearEntities,  function(entityId)
            local targetPosition = world.entityPosition(entityId)
            if not entity.isValidTarget(entityId) or world.lineTileCollision(self.basePosition, targetPosition) then return false end

            local toTarget = world.distance(targetPosition, self.basePosition)
            local targetAngle = math.atan(toTarget[2], object.direction() * toTarget[1])
            return world.magnitude(toTarget) > self.targetMinRange and math.abs(targetAngle) < self.targetAngleRange
            end)
         end
