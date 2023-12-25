require "/scripts/status.lua"
require "/scripts/achievements.lua"
require "/scripts/sb_uimessage.lua"

local ini = init or function() end
local updat = update or function() end
local applyDamageReques = applyDamageRequest or function() end
local overheadBar = overheadBars or function() end

function init() ini()
  player = math.betabound_player
  sb_shieldAlpha = {0,0,0}
  sb_lastHunger = math.floor(status.resourcePercentage("food")*100)
  sb_lastHungerMessage = "d100"
  sb_hungerBenchmarks = {2,5,10,15,25,50,75,100}
  sb_hungerPopups = root.assetJson("/betabound.config:hungerPopups")
end

function update(dt) updat(dt)
  if player then
    animator.setAnimationState("sb_flames", not player.isLounging() and not mcontroller.zeroG() and mcontroller.yVelocity() <= -170 and "flames" or "none")
  end
  if not status.resourcePositive("sb_shieldStaminaRegenBlockL") then
    status.modifyResourcePercentage("sb_shieldStaminaL", status.stat("shieldStaminaRegen") * dt)
    status.modifyResourcePercentage("sb_perfectBlockLimitL", status.stat("perfectBlockLimitRegen") * dt)
  end
  if not status.resourcePositive("sb_shieldStaminaRegenBlockR") then
    status.modifyResourcePercentage("sb_shieldStaminaR", status.stat("shieldStaminaRegen") * dt)
    status.modifyResourcePercentage("sb_perfectBlockLimitR", status.stat("perfectBlockLimitRegen") * dt)
  end

  if sb_hungerPopups then
    local hunger = math.floor(status.resourcePercentage("food")*100)
    if hunger ~= sb_lastHunger then
      for i = 1, #sb_hungerBenchmarks-1 do
        if hunger > sb_hungerBenchmarks[i] and hunger < sb_hungerBenchmarks[i+1] then
          local id = (hunger > sb_lastHunger and "u" or "d")..sb_hungerBenchmarks[i+1]
          if sb_lastHungerMessage ~= id then
            if player then sb_uiMessage(id) end
            sb_lastHungerMessage = id
          end
        end
      end
    end
    sb_lastHunger = math.floor(status.resourcePercentage("food")*100)
  end
end

function applyDamageRequest(damageRequest)
  if (world.getProperty("invinciblePlayers",false) or world.getProperty("nonCombat",false)) then return {} end
  if not player then player = math.betabound_player end
  if status.resource("sb_forceFieldStrength") > 0 and status.resourcePositive("energy") and not status.resourceLocked("energy") then --resourcePositive rounds or smth
    local forceFieldStrength = status.resource("sb_forceFieldStrength")
    local maxReduction = math.min(damageRequest.damage, (status.resource("energy")/2) * forceFieldStrength)
    if maxReduction ~= damageRequest.damage then
      maxReduction = maxReduction/forceFieldStrength
      damageRequest.damage = damageRequest.damage - maxReduction
      status.overConsumeResource("energy", maxReduction)
    end
    return applyDamageReques(damageRequest)
  end

  if status.resourcePositive("sb_shieldStaminaT") then
    if damageRequest.sourceEntityId == -65536 then --NOTE: this does not block self-inflicted projectile damage such as bombs
      applyDamageReques(damageRequest)
    else
      damageRequest.damage = 0
      return applyDamageReques(damageRequest)
    end
  end
  if damageRequest.hitType ~= "ShieldHit" or damageRequest.sourceEntityId == -65536 then return applyDamageReques(damageRequest) end
  local oldDamage = damageRequest.damage
    damageRequest.damage = damageRequest.damage + root.evalFunction2("protection", damageRequest.damage, status.stat("protection"))/4
  if damageRequest.damage <= 0 then return {} end
  if status.statPositive("sb_shieldHealthL") then
    return sb_applyShieldDamage("L",damageRequest)
  elseif status.statPositive("sb_shieldHealthR") then
    return sb_applyShieldDamage("R",damageRequest)
  else
    damageRequest.damage = oldDamage
    return applyDamageReques(damageRequest)
  end
end

function sb_applyShieldDamage(hand,damageRequest)
  if self.shieldHitInvulnerabilityTime == 0 then
    local preShieldDamageHealthPercentage = damageRequest.damage / status.resourceMax("health")
    self.shieldHitInvulnerabilityTime = status.statusProperty("shieldHitInvulnerabilityTime") * math.min(preShieldDamageHealthPercentage, 1.0)
    if not status.resourcePositive("sb_perfectBlock"..hand) then
      status.overConsumeResource("sb_shieldStamina"..hand, (damageRequest.damage/status.stat("sb_shieldHealth"..hand))/2)
    end
    world.sendEntityMessage(player.id(), "sb_applyShieldDamage"..hand)
  end

  status.setResourcePercentage("sb_shieldStaminaRegenBlock"..hand, 1.0)
  damageRequest.damage = 0
  return {}
end

function overheadBars()
  if not player then player = math.betabound_player end
  local bars = overheadBar()
  sb.setLogMap("sb_shields","%s (%s), %s (%s), %s",status.resource("sb_shieldStaminaL"),status.stat("sb_shieldHealthL"),status.resource("sb_shieldStaminaR"),status.stat("sb_shieldHealthR"),status.resource("sb_forceFieldStrength"))
  sb.setLogMap("sb_techtier","%s",player and player.getProperty("sb_techTier","-") or "UNAVAILABLE")

  sb_shieldAlpha[1] = status.resourcePercentage("sb_shieldStaminaL") == 1 and math.max(0,sb_shieldAlpha[1]-15) or 255
  sb_shieldAlpha[2] = status.resourcePercentage("sb_shieldStaminaR") == 1 and math.max(0,sb_shieldAlpha[2]-15) or 255
  sb_shieldAlpha[3] = status.resourcePercentage("sb_shieldStaminaT") == 0 and math.max(0,sb_shieldAlpha[3]-15) or 255

  if sb_shieldAlpha[1] > 0 or status.statPositive("sb_shieldHealthL") or status.resourcePercentage("sb_shieldStaminaL") < 1 then
    table.insert(bars, {
      icon = "/interface/sb_shieldL.png?multiply=FFFFFF"..string.format("%02X", sb_shieldAlpha[1]),
      percentage = status.resource("sb_shieldStaminaL"),
      color = {30, 121, status.resourcePositive("sb_perfectBlockL") and 255 or 188, sb_shieldAlpha[1]}
    })
  end
  if sb_shieldAlpha[2] > 0 or status.statPositive("sb_shieldHealthR") or status.resourcePercentage("sb_shieldStaminaR") < 1 then
    table.insert(bars, {
      icon = "/interface/sb_shieldR.png?multiply=FFFFFF"..string.format("%02X", sb_shieldAlpha[2]),
      percentage = status.resource("sb_shieldStaminaR"),
      color = {status.resourcePositive("sb_perfectBlockR") and 255 or 177, 42, 48, sb_shieldAlpha[2]}
    })
  end
  if sb_shieldAlpha[3] > 0 or status.resourcePercentage("sb_shieldStaminaT") > 0 then
    table.insert(bars, {
      percentage = status.resource("sb_shieldStaminaT"),
      color = {106, 225, 255, sb_shieldAlpha[3]}
    })
  end

  return bars
end