local ini = init
--disabled naming for mushroom/eye shields since merchants would keep regenerating them while the menu was open
function init() ini()
  if player and not sb_init then
    sb_resourceNames = {shieldStamina = 1, shieldStaminaRegenBlock = 1, shieldHealth = 1, perfectBlock = 1, perfectBlockLimit = 1} --TODO: move to config?
    sb_hand = activeItem.hand() == "alt" and "R" or "L"
    sb_statusEffects = config.getParameter("statusEffects")
  
    if self.perfectBlockDirectives == "?border=2;AACCFFFF;00000000" then
      self.perfectBlockDirectives = "?border=2;"..(sb_hand=="L" and "ACF" or "FCA").."F;0000"
    end
    
    status.sb_resource = status.resource
    status.resource = function(resourceName)
      resourceName = sb_resource(resourceName)
      return status.sb_resource(resourceName)
    end
    
    status.sb_resourcePositive = status.resourcePositive
    status.resourcePositive = function(resourceName)
      resourceName = sb_resource(resourceName)
      return status.sb_resourcePositive(resourceName)
    end
    
    status.sb_setPersistentEffects = status.setPersistentEffects
    status.setPersistentEffects = function(effectCategory, effects)
      effects[1].stat = sb_resource(effects[1].stat)
      return status.sb_setPersistentEffects(effectCategory, effects)
    end
    
    status.sb_overConsumeResource = status.overConsumeResource
    status.overConsumeResource = function(resourceName, value)
      resourceName = sb_resource(resourceName)
      return status.sb_overConsumeResource(resourceName, value)
    end
    
    status.sb_modifyResource = status.modifyResource
    status.modifyResource = function(resourceName, value)
      resourceName = sb_resource(resourceName)
      return status.sb_modifyResource(resourceName, value)
    end

  activeItem.sb_setItemDamageSources = activeItem.setItemDamageSources
  activeItem.setItemDamageSources = function(damageSources)
    if sb_statusEffects and damageSources then
      for i = 1, #damageSources do
        damageSources[i].statusEffects = damageSources[i].statusEffects or {}
        for j = 1, #sb_statusEffects do
          damageSources[i].statusEffects[#damageSources[i].statusEffects+1] = sb_statusEffects[j]
        end
      end
    end
    return activeItem.sb_setItemDamageSources(damageSources)
  end

  message.setHandler("sb_applyShieldDamage"..sb_hand, function(_,a)
    animator.setAnimationState("shield", "block")
    if status.sb_resourcePositive("sb_perfectBlock"..sb_hand) then
      animator.playSound("perfectBlock")
      animator.burstParticleEmitter("perfectBlock")
      refreshPerfectBlock()
    end
    if not status.sb_resourcePositive("sb_shieldStamina"..sb_hand) then
      animator.playSound("break")
    else
      animator.playSound("block")
    end
  end)
  sb_init = true
  end
end

function sb_resource(resourceName)
  return sb_resourceNames[resourceName] and "sb_"..resourceName..sb_hand or resourceName
end