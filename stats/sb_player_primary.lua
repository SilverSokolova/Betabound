require "/scripts/sb_uimessage.lua"

local originalInit = init or function() end
local originalUpdate = update or function() end
local originalApplyDamageRequest = applyDamageRequest or function() end
local originalOverheadBars = overheadBars or function() end

function init() originalInit()
  player = math.betabound_player
  math.betabound_mcontroller = _ENV.mcontroller

  sb_hungerPopups = root.assetJson("/betabound.config:hungerPopups")
  if sb_hungerPopups then
    sb_lastHunger = math.floor(status.resourcePercentage("food") * 100)
    sb_lastHungerMessage = "d100"
    sb_hungerBenchmarks = {2, 5, 10, 15, 25, 50, 75, 100}
  end
end

function update(dt) originalUpdate(dt)
--sb.setLogMap("sb_shield", "%s/%s%%", status.stat("shieldHealth"), status.resource("shieldStamina"))
--sb.setLogMap("sb_techtier","%s", player and player.getProperty("sb_techTier","-") or "UNAVAILABLE")
  if not player then
    player = math.betabound_player
  end

  --reentry
  if not starExtensions then
    animator.setAnimationState("sb_flames", not player.isLounging() and not mcontroller.zeroG() and mcontroller.yVelocity() <= -170 and "flames" or "none")
  end

  --hunger
  if sb_hungerPopups then
    local maxHunger = status.resourceMax("food") --grab this in update in case it changes
    local hunger = math.floor(status.resourcePercentage("food") * maxHunger)
    if hunger ~= sb_lastHunger then
      for i = 1, #sb_hungerBenchmarks - 1 do
        if hunger > sb_hungerBenchmarks[i] and hunger < sb_hungerBenchmarks[i+1] then
          local id = (hunger > sb_lastHunger and "u" or "d")..sb_hungerBenchmarks[i+1]
          if sb_lastHungerMessage ~= id then
            if player then sb_uiMessage(id) end
            sb_lastHungerMessage = id
          end
        end
      end
    end
    sb_lastHunger = math.floor(status.resourcePercentage("food") * maxHunger)
  end
end

function applyDamageRequest(damageRequest)
  if (world.getProperty("invinciblePlayers", false) or world.getProperty("nonCombat", false)) then return {} end

  --force field tech
    if status.resource("sb_forceFieldStrength") > 0 and status.resourcePositive("energy") and not status.resourceLocked("energy") then --resourcePositive rounds or smth
    local forceFieldStrength = status.resource("sb_forceFieldStrength")
    local maxReduction = math.max(math.min(damageRequest.damage, (status.resource("energy")/1.5) * forceFieldStrength), 0)
    status.overConsumeResource("energy", maxReduction)
    damageRequest.damage = damageRequest.damage - maxReduction
    return originalApplyDamageRequest(damageRequest)
  end
  --[[
  if status.resource("sb_forceFieldStrength") > 0 and status.resourcePositive("energy") and not status.resourceLocked("energy") then --resourcePositive rounds or smth
    local forceFieldStrength = status.resource("sb_forceFieldStrength")
    local maxReduction = math.min(math.min(damageRequest.damage, (status.resource("energy")/2) * forceFieldStrength), 0)
    status.overConsumeResource("energy", maxReduction)
    damageRequest.damage = damageRequest.damage - maxReduction
    player.say(damageRequest.damage)
    return originalApplyDamageRequest(damageRequest)
  end]]

  --shield tech
  if status.resourcePositive("sb_shieldStaminaT") then
    if damageRequest.sourceEntityId == -65536 then --NOTE: this does not block self-inflicted projectile damage such as bombs
      originalApplyDamageRequest(damageRequest)
    else
      damageRequest.damage = 0
      return originalApplyDamageRequest(damageRequest)
    end
  end

  return originalApplyDamageRequest(damageRequest)
end

function overheadBars()
  local bars = originalOverheadBars()

  if status.resourcePercentage("sb_shieldStaminaT") > 0 then
    bars[#bars+1] = {
      percentage = status.resource("sb_shieldStaminaT"),
      color = {106, 225, 255}
    }
  end

  return bars
end