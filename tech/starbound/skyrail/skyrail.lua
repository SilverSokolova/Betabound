require "/scripts/vec2.lua"
require "/scripts/rails.lua"
require "/scripts/util.lua"
railFunctions = {}
--nextNode = {position: {1: 1878.5, 2: 696.5}, direction: 5, material: skyrailbreak, type: continue}
--how about making the switchers cause the player to jump/fall and automatically reactivate their skyrail?
function init()
  script.setUpdateDelta(1)
  local railConfig = config.getParameter("railConfig")
  railConfig.onEngage = function() animator.playSound("engage") end
  self.railRider = Rails.createRider(railConfig)
  local railTypes = config.getParameter("railTypes")
  if railTypes then
    self.railRider.railTypes = railTypes
  end
  self.railRider.connectionOffset = config.getParameter("hookOffset")
  self.railRider.update = rider_update
  self.railRider:init()

  onRail = false
  volumeAdjustTimer = 0
  volumeAdjustTime = 0.1
  railLeaveTimeAscension = config.getParameter("railLeaveTimeAscension")
  railLeaveTimeDescension = config.getParameter("railLeaveTimeDescension")
  railLeaveTimer = 0
  jumpHeightBoost = config.getParameter("jumpHeightBoost")
  acsensionJumpHeight = config.getParameter("acsensionJumpHeight")
  bounceFactor = config.getParameter("bounceFactor")
  collisionSearchSet = config.getParameter("collisionSearchSet", {"Null", "Block", "Dynamic", "Platform"})

  active = false
  lastAction = false
end

railFunctions.jump = function()
  railLeaveTimer = railLeaveTimeAscension
  mcontroller.addMomentum({0, acsensionJumpHeight})
  disengageHook()
end

railFunctions.fall = function()
  railLeaveTimer = railLeaveTimeDescension
  disengageHook()
end

function update(args)
  if railLeaveTimer > 0 then
    railLeaveTimer = math.max(0, railLeaveTimer - args.dt)
    if railLeaveTimer == 0 then
      args.moves["special1"] = true
    end
  end

  if active and tech.parentLounging() then
    active = false
  end

  if args.moves["special1"] and not lastAction and not tech.parentLounging() and not mcontroller.onGround() then
    active = not active
    reset()
  end
  local animationKey = active and "on" or "off"
  animator.setAnimationState("skyrailhook", animationKey)
  animator.setAnimationState("skyrailbg", animationKey)
  animator.setAnimationState("skyrailfg", animationKey)

  if active then
    mcontroller.controlDown()
    if mcontroller.isColliding() then
      disengageHook()
    else --if not status.statPositive("activeMovementAbilities") then
      animator.setFlipped(mcontroller.facingDirection() == -1)
      self.railRider:updateConnectionOffset(self.railRider.connectionOffset)
      self.railRider:update(args.dt, args.moves)
      if self.railRider:onRail() then
        if args.moves["jump"] and not mcontroller.jumping() then
          if not args.moves["down"] then
              mcontroller.controlModifiers({airJumpModifier = jumpHeightBoost})
              mcontroller.controlJump(true)
          end
          disengageHook()
        else
          mcontroller.controlModifiers({jumpingSuppressed = true, movementSuppressed = true})
          mcontroller.controlParameters({airForce = 0, gravityEnabled = false, bounceFactor = bounceFactor})
        end
      end
    end
  else
    reset()
  end

  if self.railRider:onRail() then
    status.setPersistentEffects("sb_skyrail", {{stat = "activeMovementAbilities", amount = 1}})
  else
    status.clearPersistentEffects("sb_skyrail")
  end

  if self.railRider:onRail() and self.railRider.moving and self.railRider.speed > 0.01 then
    animator.setParticleEmitterActive("sparks", true)
    animator.setParticleEmitterEmissionRate("sparks", math.floor(self.railRider.speed) * 2)

    local volumeAdjustment = math.max(0.5, math.min(1, self.railRider.speed / 20))

    if not onRail then
      onRail = true
      animator.playSound("grind", -1)
      animator.setSoundVolume("grind", volumeAdjustment, 0)
    end

    volumeAdjustTimer = math.max(0, volumeAdjustTimer - args.dt)
    if volumeAdjustTimer == 0 then
      animator.setSoundVolume("grind", volumeAdjustment, volumeAdjustTime)
      volumeAdjustTimer = volumeAdjustTime
    end
  else
    animator.setParticleEmitterActive("sparks", false)

    onRail = false
    volumeAdjustTimer = volumeAdjustTime
    animator.stopAllSounds("grind")
  end

  lastAction = args.moves["special1"]
end

function disengageHook()
  active = false
  onRail = false
  reset()
end

function reset()
  self.railRider.speed = 10
  self.railRider:reset()
end

function applyNewDirection(newDirection)
  if newDirection then
    if self.railRider.speed < 10 then
      self.railRider.speed = 15
    end
    self.railRider:findNextNode(vec2.add(self.railRider.lastNode.position, Rails.dirVectors[newDirection]), self.railRider.lastNode.direction, newDirection)
  end
end

function shouldReverse(node)
  return node.type == "reverse" or (node.material == "skyrail_diodeR" and self.railRider.direction == 5) or (node.material == "skyrail_diodeL" and self.railRider.direction == 1)
end

function rider_update(_, dt, moves)
  if railLeaveTimer ~= 0 then return end
  if self.railRider.moving then
    -- if we don't have any active nodes, we're falling
    if not self.railRider.nextNode and not self.railRider.lastNode then
      -- choose the nearest appropriate rail direction based on our falling velocity
      local vel = mcontroller.velocity()
      local angle = math.atan(vel[2], vel[1])
      local dir = math.floor(((4 * angle) / math.pi) + 0.5) % 8 + 1
      if dir == 7 then
        -- never face straight down since we need to bias direction when falling onto horizontal rails
        if vel[1] == 0 then
          dir = self.railRider.facing < 0 and 6 or 8
        else
          dir = vel[1] < 0 and 6 or 8
        end
      end
      self.railRider.direction = dir

      -- check for rails at any tiles we cross and attempt to snap onto them
      local pos = vec2.floor(self.railRider:position())
      if not vec2.eq(pos, self.railRider.lastFallCheck) then
        -- if we might cross multiple tiles, use a more thorough search
        if vec2.mag(vel) >= 1.0 / dt then
          local searchSet = world.collisionBlocksAlongLine(self.railRider.lastFallCheck, pos, collisionSearchSet)
          if #searchSet >= 2 then
            for i = 2, #searchSet do
              -- search inclusively to avoid passing through diagonal rails
              if searchSet[i][1] ~= searchSet[i - 1][1] and searchSet[i][2] ~= searchSet[i - 1][2] then
                if self.railRider:findInitialNode({searchSet[i - 1][1], searchSet[i][2]}) then
                  break
                end
              end

              if self.railRider:findInitialNode(searchSet[i]) then
                break
              end
            end
          end
        else
          if not self.railRider:findInitialNode(pos) then
            -- search inclusively to avoid passing through diagonal rails
            if pos[1] ~= self.railRider.lastFallCheck[1] and pos[2] ~= self.railRider.lastFallCheck[2] then
              self.railRider:findInitialNode({self.railRider.lastFallCheck[1], pos[2]})
            end
          end
        end
        self.railRider.lastFallCheck = pos
      end
    end

    -- complete previous node if necessary
    if self.railRider.lastNode then
      if self.railRider.lastNode.type == "end" then
        self.railRider.onRailType = nil
        self.railRider.lastFallCheck = vec2.floor(self.railRider:position())

        -- trigger disengage callback
        if self.railRider.onDisengage then self.railRider:onDisengage() end
      elseif self.railRider.lastNode.type == "stop" then
        -- double check to make sure there's still a rail stop here (and that it's still stopped)
        if self.railRider:checkTile(self.railRider.lastNode.position) == "metamaterial:railstop" then
          mcontroller.setVelocity({0, 0})
          self.railRider.moving = false
        else
          self.railRider:railResume(self.railRider.lastNode.position)
        end
      elseif shouldReverse(self.railRider.lastNode) then
        self.railRider.direction = (self.railRider.direction + 3) % 8 + 1
        self.railRider:findNextNode(vec2.add(self.railRider.lastNode.position, Rails.dirVectors[self.railRider.direction]), self.railRider.lastNode.direction, self.railRider.direction)
      end
      self.railRider.lastNode = nil
    end

    -- notify any objects we crossed this tick
    for _, objectId in pairs(self.railRider.crossedObjects) do
      world.sendEntityMessage(objectId, "railRiderPresent")
    end
    self.railRider.crossedObjects = {}

    -- determine which nodes we'll cross next tick
    if self.railRider.nextNode then
      --NEW: kick player off up/down rails
      if self.railRider.nextNode.direction == 3 or self.railRider.nextNode.direction == 7 then
        self.railRider.nextNode.type = "end"
      end

      if self.railRider.nextNode.type ~= "stop" then
        world.debugLine(self.railRider.nextNode.position, vec2.add(self.railRider.nextNode.position, Rails.dirVectors[self.railRider.nextNode.direction]), "cyan")
      end
      world.debugPoint(self.railRider.nextNode.position, "blue")

      --NEW: check for special rail effects
      if self.railRider.nextNode.material then
        self.railRider.onRailType = self.railRider.nextNode.material
        local railType = self.railRider.railTypes[self.railRider.onRailType]
        if railType then
          for k, v in pairs(railType) do
            if k == "speedIncrement" then
              self.railRider.speed = self.railRider.speed + v
            end
            if k == "function" and railFunctions[v] then
              return railFunctions[v]()
            end
          end
        end
      end

      -- calculate speed change due to gravity and friction if applicable
      if self.railRider.useGravity and self.railRider.onRailType then
        -- apply gravity
        local gravityEffect = vec2.dot({0, -self.railRider.gravity}, self.railRider:dirVector()) / vec2.mag(self.railRider:dirVector()) * dt
        self.railRider.speed = self.railRider.speed + gravityEffect

        -- reverse direction if needed
        if self.railRider.speed < 0 then
          self.railRider.direction = (((self.railRider.direction - 1) + 4) % 8) + 1
          self.railRider.speed = -self.railRider.speed
          self.railRider:findNextNode(vec2.add(self.railRider.nextNode.position, self.railRider:dirVector()))
        end

        -- apply friction
        local frictionEffect = self.railRider.railTypes[self.railRider.onRailType].friction * dt
        self.railRider.speed = self.railRider.speed - frictionEffect

        -- respect speed limits for the type of rail we're on
        self.railRider.speed = util.clamp(self.railRider.speed, 0, self.railRider.railTypes[self.railRider.onRailType].speedLimit)
      end

      -- position to move toward if we need to cut a corner or stop at a given point
      local targetPosition

      -- check whether we will cross the node next tick
      local toTravel = self.railRider.speed * dt
      local crossDist = Rails.crossDist(self.railRider.nextNode.position, self.railRider:position(), toTravel)
      while crossDist do
        if self.railRider.nextNode.type == "turn" then
          self.railRider.direction = self.railRider.nextNode.direction
          targetPosition = vec2.add(self.railRider.nextNode.position, vec2.mul(vec2.norm(self.railRider:dirVector()), crossDist))
        elseif self.railRider.nextNode.type == "stop" or self.railRider.nextNode.type == "reverse" then
          targetPosition = self.railRider.nextNode.position
        end

        self.railRider.lastNode = self.railRider.nextNode
        if self.railRider.lastNode.objectId then
          table.insert(self.railRider.crossedObjects, self.railRider.lastNode.objectId)
        end

        if self.railRider.lastNode.type == "reverse" then
          -- riders must stop for at least one tick on a reverse node
          break
        elseif self.railRider.lastNode.type ~= "stop" and self.railRider.lastNode.type ~= "end" then
          self.railRider:findNextNode(vec2.add(self.railRider.lastNode.position, Rails.dirVectors[self.railRider.lastNode.direction]), self.railRider.lastNode.direction)

          toTravel = crossDist
          crossDist = Rails.crossDist(self.railRider.nextNode.position, self.railRider.lastNode.position, toTravel)
        else
          self.railRider:setNextNode(nil)
          break
        end
      end

      if targetPosition then
        mcontroller.setVelocity(vec2.mul(world.distance(targetPosition, self.railRider:position()), 1 / dt))
      else
        mcontroller.setVelocity(self.railRider:onRailVelocity())
      end
    end

    -- update 'facing' which is used to bias search order
    if self.railRider:dirVector()[1] ~= 0 then
      self.railRider.facing = self.railRider:dirVector()[1]
    end
  else
    -- stopped; wait for signal
  end

  self.railRider:applyGravity()
end