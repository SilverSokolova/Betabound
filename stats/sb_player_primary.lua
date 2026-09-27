require "/scripts/sb_uimessage.lua"

local originalInit = init or function() end
local originalUpdate = update or function() end
local originalApplyDamageRequest = applyDamageRequest or function() end
local originalOverheadBars = overheadBars or function() end

function init(); originalInit()
  player = math.betabound_player
  math.betabound_mcontroller = _ENV.mcontroller

  if type(math.betabound_applyProtectionOverride) == "nil" and not root.assetJson("/betabound.config:allowTotalPlayerDamageReduction") then
    sb_checkProtectionForOverride()
  end

  if math.betabound_applyProtectionOverride then
    root.sb_evalFunction2 = root.evalFunction2
    root.evalFunction2 = function(functionName, input1, input2)
      return root.sb_evalFunction2(functionName, input1, functionName == "protection" and math.min(math.betabound_applyProtectionOverride, input2) or input2)
    end
  end

  sb_hungerPopups = root.assetJson("/betabound.config:hungerPopups")
  if sb_hungerPopups then
    sb_lastHunger = math.floor(status.resourcePercentage("food") * 100)
    sb_lastHungerMessage = "d100"
    sb_hungerBenchmarks = {2, 5, 10, 15, 25, 50, 75, 100}
  end
end

function update(dt); originalUpdate(dt)
--sb.setLogMap("sb_shield", "%s/%s%%", status.stat("shieldHealth"), status.resource("shieldStamina"))
--sb.setLogMap("sb_techtier","%s", player and player.getProperty("sb_techTier","-") or "UNAVAILABLE")
--sb.setLogMap("sb_apo", "%s", tostring(math.betabound_applyProtectionOverride))

  if not player then
    player = math.betabound_player
  end

  --reentry
  if not starExtensions then
    animator.setAnimationState("sb_flames", not player.isLounging() and not mcontroller.zeroG() and mcontroller.yVelocity() <= -170 and "flames" or "none")
  end

  --hunger
  if sb_hungerPopups then
    local hunger = math.floor(status.resourcePercentage("food") * 100)
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
    sb_lastHunger = math.floor(status.resourcePercentage("food") * 100)
  end
end

function applyDamageRequest(damageRequest)
  if (world.getProperty("invinciblePlayers", false) or world.getProperty("nonCombat", false)) then return {} end

  --force field tech
  if status.resource("sb_forceFieldStrength") > 0 and status.resourcePositive("energy") and not status.resourceLocked("energy") then --resourcePositive rounds or smth
    local forceFieldStrength = status.resource("sb_forceFieldStrength")
    local maxReduction = math.max(math.min(damageRequest.damage, (status.resource("energy")/2) * forceFieldStrength), 0)
    status.overConsumeResource("energy", maxReduction)
    damageRequest.damage = damageRequest.damage - maxReduction
    return originalApplyDamageRequest(damageRequest)
  end

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

function sb_checkProtectionForOverride()
  local sum = 0
  local protection = root.assetJson("/leveling/protection.2functions")["protection"]
  for i = 1, #protection[3][#protection[3]][2] do
    sum = sum + protection[3][#protection[3]][2][i]
  end

  if sum == 0 then
    math.betabound_applyProtectionOverride = protection[3][#protection[3]][1] - 0.5
--  sb.logInfo("[Betabound] The player protection override was applied with a value of %s.", protection[3][#protection[3]][1])
  else
    math.betabound_applyProtectionOverride = false
--  sb.logInfo("[Betabound] The player protection override was not applied.")
  end
end