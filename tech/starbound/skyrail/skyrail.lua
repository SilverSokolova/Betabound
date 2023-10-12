require "/scripts/vec2.lua"
require "/scripts/rails.lua"
require "/scripts/util.lua"

function init()
--INPUT ACTION CONSTANTS

    --Input Related (Tracks Action)
    self.inputAction = { false, false, false, false, false, false }
    self.lastAction = { false, false, false, false, false, false }
    self.lastAction2 = false

    --Basic Tech Stats
    self.active = false --Tech On/Off
    animator.setAnimationState("skyrail", "off")
    animator.setAnimationState("skyrailbg", "off")

    --Rail Rider Stats
    self.onRail = false
    self.lastPosition = nil
    self.measuredVelocity = {0, 0}
    self.direction = 0    --Direction of motion (-1 = left, +1 = right 0 = still)
    self.speed = 0        --Speed of motion, should always be +tive.
    self.currentRail = nil --Current rail object:
        --Rail Form: {Position=<Vec2>, Type=<String>, Left=<Neighbours>, Right=<Neigbours>}
        --Neighbour Form: { Down=<String>, Level=<String>, Up=<String>, Offset=<xOffset float> }
    self.leaveTimer = 0    --Timer triggered to prevent immediate re-attaching to rails after jumping.
    self.railSearchOrder = "MBT" --Priority of rail neighbours when moving from one rail to another (M=Middle, B=Bottom, T=Top).
    self.resetRailSearchOrder = true --Used to mark if default railSearchOrder has been overidden by a special rail type
    self.maxspeed = 600 --was 60 xrc    --Default maxspeed (should be overidden before use)
    self.acceleration = 15 --Default acceleration (should be overidden before use)
end

function uninit()
    init()
end

------------------------------------------------------------------------------------------
--INPUT HANDLING
------------------------------------------------------------------------------------------


function input(args)

  input_markInput(args.moves["jump"],	  args.moves["jump"],	  true)
  input_markInput(args.moves["special1"], args.moves["special1"], true)
  input_markInput(args.moves["left"],	  args.moves["left"],	  false)
  input_markInput(args.moves["right"],	  args.moves["right"],	  false)
  input_markInput(args.moves["up"],	  args.moves["up"],	  false)
  input_markInput(args.moves["down"],	  args.moves["down"],	  false)
  return "step"
end

function input_markInput(move, moveIndex, pressOnly)
    if move and not self.lastAction[moveIndex] then
        moveIndex = true
    end
    self.lastAction[moveIndex] = move and pressOnly
end

function input_resetInput()
    self.inputAction = { false, false, false, false, false, false }
end

------------------------------------------------------------------------------------------
--UPDATE HANDLING: General & Offrail
------------------------------------------------------------------------------------------
function update(args)
  if self.active and tech.parentLounging() then
    self.active = false
  end

    --Handle active/unactive state of skyrail rider + calling onrail / offrail update.
    --if args.moves["special1"] then
    if args.moves["special1"] and not self.lastAction2 and not tech.parentLounging() then
        self.active = not self.active
        if self.onRail then
            leaveRail()
        end
    end

	self.lastAction2 = args.moves["special1"]

    if self.active then
        animator.setAnimationState("skyrail", "on")
        animator.setAnimationState("skyrailbg", "on")
        if self.onRail then
            update_onrail(args) tech.setParentState("Fly")
        else
            update_offrail(args)
            tech.setParentState()
        end
    else
        tech.setParentState()
        animator.setAnimationState("skyrail", "off")
        animator.setAnimationState("skyrailbg", "off")
    end

    input_resetInput()

    if self.lastPosition == nil then
      self.lastPosition = mcontroller.position()
    end

    local currentPosiiton = mcontroller.position()
    local movement = world.distance(currentPosiiton, self.lastPosition)
    self.measuredVelocity = {movement[1] / args.dt, movement[2] / args.dt}
    self.lastPosition = currentPosition
end

--Search for a rail to join (Uses hookOffset & railtestStartOffset)
function update_offrail(args)
  --If recently left a rail, don't immediately rejoin the rail
  if self.leaveTimer > 0 then
        self.leaveTimer = self.leaveTimer - args.dt
        return nil
  end

  --Otherwise, look for rails to join
  local hookOffset = config.getParameter("hookOffset")
  local testOffset = config.getParameter("railtestStartOffset")
  local hookX = { mcontroller.position()[1] + hookOffset[1], mcontroller.position()[2] + hookOffset[2]}
  local testStartX = { hookX[1] + testOffset[1], hookX[2] + testOffset[2] }
  local rails = getOverheadRails(testStartX)

  --If there is a platform to join, prioritise starting rail based on vertical direction.
  local nrails = #rails
  if nrails > 0 then
        self.leaveTimer = 0
        if self.measuredVelocity[2] > 0 then
            --Upwards motion, prioritise lowest rail (first contact)
            joinRail(rails[1],"TMB")
        else
            --Downwards motion, prioritise highest rail (first contact)
            joinRail(rails[nrails],"BMT")
        end
  end
end

------------------------------------------------------------------------------------------
--UPDATE HANDLING: Riding a Rail
------------------------------------------------------------------------------------------

--Update step whilst riding a rail
function update_onrail(args)
    update_fixWallCollision(args);

    --Jumping from the rail
    if args.moves["jump"] then
        leaveRail()
        self.leaveTimer = config.getParameter("railLeaveTime");
        if not args.moves["down"] then
            mcontroller.controlJump(true)
        end
        return
    end

    --Rail Search Order
    if args.moves["up"] then
        self.railSearchOrder = "TMB"
    elseif args.moves["down"] then
        self.railSearchOrder = "BMT"
    else
        if self.resetRailSearchOrder == true then
            self.railSearchOrder = "MBT"
        else
            self.resetRailSearchOrder = true
        end
    end

    --Determine the current rail above the player's head
    update_currentRail(args)

    if self.onRail then
        --Rail specific behaviours which affect movement
        surfaces = config.getParameter("surfaceBehaviour")
        update_preapplyRailSurface(args,surfaces["default"])
        update_preapplyRailSurface(args,surfaces[self.currentRail.Type])

        --Left/Right Motion
        if args.moves["left"] then
            update_railSpeed(-self.acceleration * 5 * args.dt)
        elseif args.moves["right"] then
            update_railSpeed(self.acceleration * 5 * args.dt)
        end

        --Remaining Rail specific behaviours
        update_postapplyRailSurface(args,surfaces[self.currentRail.Type])

        --Update Motion
        update_railMotion(args)
    end
end

--Simple wall collision prior test by considering measured velocity. Bounce if going fast enough.
--Todo - fix stuck case with hill motion. (Do a lookahead collision test (speed * dt)?)
function update_fixWallCollision(args)
  local minspeed = config.getParameter("minSpeed")
  local bouncespeed = config.getParameter("minBounceSpeed")
  local bouncefactor = config.getParameter("bounceFactor")

  if world.magnitude(self.measuredVelocity) < minspeed then
    if self.speed > bouncespeed then
        self.direction = -self.direction
        self.speed = self.speed * bouncefactor
    end
  end
end

--Calculate the current rail peice above the player's head
function update_currentRail(args)
  local hookOffset = config.getParameter("hookOffset")
  local testOffset = config.getParameter("railtestStartOffset")
  local hookX = { mcontroller.position()[1] + hookOffset[1], mcontroller.position()[2] + hookOffset[2]}
  local testStartX = { hookX[1] + testOffset[1], hookX[2] + testOffset[2] }

  --Determine Rails Above the player's head. Exit if no rails are there.
  local rails = getOverheadRails(testStartX)
  local nrails = #rails
  if nrails <= 0 or self.currentRail == nil then
    leaveRail()
    return
  end

  --Determine if a Rail above the player's head is same the current rail
  if not railListContains(rails,self.currentRail) then
      --Build neighbour rails as a raillist
    leftRails = getOverheadNeighboursFromRail(self.currentRail,-1)
    rightRails = getOverheadNeighboursFromRail(self.currentRail,1)

    --Determine if the overhead rails contain a neighbour
    if railListContains(rails,leftRails[1]) or
       railListContains(rails,leftRails[2]) or
       railListContains(rails,leftRails[3]) then

       --Rail is to the left of current position, select rail by traversal order...
       --world.logInfo("LN: " .. self.railSearchOrder)
       bestNeighbour = getBestNeighbour(self.currentRail.Left, self.railSearchOrder)
       self.currentRail = leftRails[bestNeighbour.yOffset + 2]

    elseif railListContains(rails,rightRails[1]) or
           railListContains(rails,rightRails[2]) or
           railListContains(rails,rightRails[3]) then

        --Rail is to the right of current position, select rail by traversal order...
        --world.logInfo("RN" .. self.railSearchOrder)
        bestNeighbour = getBestNeighbour(self.currentRail.Right, self.railSearchOrder)
        self.currentRail = rightRails[bestNeighbour.yOffset + 2]
    else
        --Overhead rails are not neighbours or above. Pick according traversal order.
        --This should only happen if you are travelling over the world wrap boundry
        local char = self.railSearchOrder:sub(1,1)
        if char == "B" then
            self.currentRail = rails[1]
        elseif char == "M" then
            self.currentRail = rails[math.ceil(nrails / 2)]
        else
            self.currentRail = rails[nrails]
        end
    end
  end

end

--Apply a railSurfaces set of parameter settings (before movement update)
function update_preapplyRailSurface(args, surface)
  if not surface then return end
    for k ,v in pairs(surface) do
        if     k=="maxSpeed"     then self.maxspeed = v --Set max speed
        elseif k=="acceleration" then self.acceleration = v --Set acceleration
        elseif k=="searchOrder"  then
            self.railSearchOrder = v --Set rail search order
            self.resetRailSearchOrder = false --Prevent holding no keys from resetting SO
        end
    end
end

--Apply a railSurfaces set of parameter settings (after movement update)
function update_postapplyRailSurface(args, surface)
  if not surface then return end
    for k ,v in pairs(surface) do
        if k=="speedMulDt" then --Apply timestep scaled multipler
            self.speed = self.speed + (self.speed * v - self.speed) * args.dt
        elseif k=="speedMul" then --Apply flat multipler
            self.speed = self.speed * v
        elseif k=="speedMulDir" then --Apply flat multiplier if traveling in dir specified.
            if v[1] == self.direction then self.speed = self.speed * v[2] end
        elseif k=="speedIncDt" then -- Apply timestep scaled inc
            self.speed = dataspeed + v * args.dt
        elseif k=="speedSet" then -- Set speed
            self.speed = v
        elseif k=="dirSet"   then -- Set direction
            self.direction = v
        end
    end
end

--Applys timestep scaled acceleration to speed (may also affect direction)
function update_railSpeed(acceleration)
  local minspeed = config.getParameter("minSpeed")

  self.speed = self.speed + acceleration * 5 * self.direction

  if self.speed < minspeed then
    self.speed = minspeed
    self.direction = -self.direction
  end

end

--Apply gravity, speed clamping & perform snapping to the current rail peice
function update_railMotion(args)
  local ir2 = 1 / math.sqrt(2)
  local minspeed = config.getParameter("minSpeed")
  local gravity = world.gravity(mcontroller.position());
  local hookOffset = config.getParameter("hookOffset")
  local hookX = { mcontroller.position()[1] + hookOffset[1], mcontroller.position()[2] + hookOffset[2]}

  --Determine rail gradient
  local grad = getRailGradient(self.currentRail,self.direction,self.railSearchOrder)

  --Apply Gravity w.r.t rail gradient
  self.speed = self.speed - gravity * grad * ir2 * args.dt

  --Clamp speed (gravity should not reverse player motion!)
  if self.speed < minspeed then
      self.speed = minspeed
  elseif self.speed > self.maxspeed then
      self.speed = self.maxspeed
  end

  --Set player body velocity using speed, direction & rail gradient

  if grad == 0 then
      mcontroller.setXVelocity(self.speed * self.direction)
      mcontroller.setYVelocity(0)
  else
      mcontroller.setXVelocity(self.speed * self.direction * ir2)
      mcontroller.setYVelocity(self.speed * grad * ir2)
  end

  --Snap player position to rail
  local dx = hookX[1]- self.currentRail.Position[1] --sub-tile x position along railing
  local ypos = self.currentRail.Position[2] - hookOffset[2] --y position for snapping to railing

  if self.direction < 0 then
    dx = 1-dx --Moving backwards, so slope factoring should be reversed.
  end

  if grad > 0 then
    ypos = ypos + dx - 1    --Uphill starts at +1 altitude already!
  else
    ypos = ypos + dx*grad    --Downhill/flat operates at current yposition!
  end

  mcontroller.setPosition({mcontroller.position()[1],ypos})
end

------------------------------------------------------------------------------------------
--RAIL CONTROL
------------------------------------------------------------------------------------------

--Join a rail (uses minspeed parameter)
function joinRail(rail, searchOrder)
  if rail == nil then
        sb.logInfo("SKYRAIL: error - attempted to join nil rail!")
        return
  end

  --Mark rail as joined & turn on the rail riding mechanic, then put momentum onto rail
  self.onRail = true
  self.direction =0
  self.speed =0
  self.currentRail = rail

  --Determine initial direction of motion from xspeed
  if self.measuredVelocity[1] > 0 then
        self.direction = 1
  elseif self.measuredVelocity[1] < 0 then
        self.direction = -1
  end

  --Determine speed by projecting motion onto rail
  local grad = getRailGradient(rail,self.direction,searchOrder)
  if grad == 0 then
        --Special case: falling onto horizontal surface
        self.speed=math.abs(self.measuredVelocity[1])
  else
        --Taking into account vspeed * gradient of platform
        self.speed= (math.abs(self.measuredVelocity[1]) + self.measuredVelocity[2] * grad) / math.sqrt(2)

    if self.speed < 0 then
        --Moving backwards along rail -> Forwards in the opposite direction
        self.speed = -self.speed
        self.direction = -self.direction
    elseif self.speed < 0.001 then
        --Barely moving -> Assume stationary
        self.direction = 0
    end
  end

  --If stationary on the rail, apply minimum speed & utilise facing direction instead
  if self.direction == 0 then
        self.speed = config.getParameter("minSpeed")
        self.direction = mcontroller.facingDirection()
  end
end

--Leave current rail
function leaveRail()
    self.currentRail = nil
    self.onRail = false
end

------------------------------------------------------------------------------------------
--RAIL BLOCK HELPERS
------------------------------------------------------------------------------------------

--Return all rails above a current position (Uses tech parameter railTestLength)
function getOverheadRails(position)
    local testLength = config.getParameter("railtestLength")
    local lineStart = position
    local lineEnd = {position[1], position[2] + testLength}
    local rails = {}

    local collisionSet = {"Null", "Block", "Dynamic", "Platform"} --XRC well, adding 'none' to this breaks it, but also makes it work with hook rails. maybe check for something else? "isRail"?
    if world.lineTileCollision(lineStart, lineEnd, collisionSet) then
        local blocksX = world.collisionBlocksAlongLine(lineStart, lineEnd, collisionSet, -1)

        --Find all skyrails above the player which are not blocked by a non-rail solid
        for _, tileX in pairs(blocksX) do
            local blockType = world.material(tileX,"foreground")

            if blockIsRail(blockType) then
                local ln = getRailNeighbours(tileX, -1)
                local rn = getRailNeighbours(tileX, 1)
                table.insert(rails,{Position=tileX, Type=blockType, Left=ln, Right=rn})
            else
                break
            end
        end
    end

    return rails
end

--Returns all neighbouring tiles of a rail, given an xOffset
function getRailNeighbours(position, xOffset)
    local bot = world.material({position[1] + xOffset, position[2] - 1},"foreground")
    local mid = world.material({position[1] + xOffset, position[2]},"foreground")
    local top = world.material({position[1] + xOffset, position[2] + 1},"foreground")
    return { Down=bot, Level=mid, Up=top, Offset=xOffset };
end

--Returns all neighbour tiles (left/right neighbour specified by offset of a rail) as rails
function getOverheadNeighboursFromRail(rail, xOffset)
    blocksX = { { rail.Position[1] + xOffset, rail.Position[2] - 1 },
                { rail.Position[1] + xOffset, rail.Position[2]     },
                { rail.Position[1] + xOffset, rail.Position[2] + 1 } }

    local rails = {}
    for _, tileX in pairs(blocksX) do
        local blockType = world.material(tileX,"foreground")
        local ln = getRailNeighbours(tileX, -1)
        local rn = getRailNeighbours(tileX, 1)
        table.insert(rails,{Position=tileX, Type=blockType, Left=ln, Right=rn})
    end

    return rails
end

--Determines best matching neighbour given search order
function getBestNeighbour(neighbour, searchOrder)
    for i=1, #searchOrder do
        local char = searchOrder:sub(i,i)
        if char == "B" then
            if blockIsRail(neighbour.Down) then
                return {xOffset=neighbour.xOffset, yOffset=-1, Type=neighbour.Down}
            end
        elseif char =="M" then
            if blockIsRail(neighbour.Level) then
                return {xOffset=neighbour.xOffset, yOffset=0, Type=neighbour.Level}
            end
        elseif char =="T" then
            if blockIsRail(neighbour.Up) then
                return {xOffset=neighbour.xOffset, yOffset=1, Type=neighbour.Up}
            end
        end
    end
    return {xOffset=0,yOffset=0,Type=neighbour.Level}
end

--Gets gradient of a rail given approach direction & search order
function getRailGradient(rail, approachDirection, searchOrder)

    --Determine previous & next rails to traverse to given
    --motion direction and rail priority (E.g. bottom first / mid first / top first )
    local prevN = nil
    local nextN = nil
    if approachDirection > 0 then
        prevN = getBestNeighbour(rail.Left,searchOrder)
        nextN = getBestNeighbour(rail.Right,searchOrder)
    else
        prevN = getBestNeighbour(rail.Right,searchOrder)
        nextN = getBestNeighbour(rail.Left,searchOrder)
    end

   --Using determined next & previous neighbour rails, determine gradient
   if nextN==nil then
        if prevN == nil then
            gradient = 0    --Single rail, assume straight.
        else
            gradient = -prevN.yOffset --End of line: Use gradient w/ previous rail.
        end
  else
        if prevN==nil then
            gradient=nextN.yOffset --Start of line: Use next rail for gradient.
        elseif nextN.yOffset==prevN.yOffset then
            gradient=0  --Straight Line
        elseif nextN.yOffset<0 then
            gradient=-1 --Downhill
        elseif prevN.yOffset<0 then
            gradient=1 --Uphill
        else
            gradient=0 --Approaching hill or disjoint rail.
        end
  end
  return gradient

end

--Returns true if the block is a rail
function blockIsRail(blockType)
    local validSurfaces = config.getParameter("railSurfaces")

    if blockType ~= nil then
        for _, value in pairs(validSurfaces) do
            if value == blockType then
                return true
            end
        end
    end
    return false
end

--Returns true if a given rail is contained in a list of rails
function railListContains(railList, rail)

    for _ ,v in pairs(railList) do
        if (v.Position[1] == rail.Position[1]) and (v.Position[2] == rail.Position[2]) then
            return true
        end
    end
    return false
end