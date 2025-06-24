local originalInit = init or function() end
--disabled naming for mushroom/eye shields since merchants would keep regenerating them while the menu was open
function init() originalInit()
  if player and not sb_init then
    sb_hand = activeItem.hand() == "alt" and "R" or "L"
    sb_statusEffects = config.getParameter("statusEffects")
  
    if self.perfectBlockDirectives == "?border=2;AACCFFFF;00000000" then
      self.perfectBlockDirectives = "?border=2;"..(sb_hand=="L" and "ACF" or "FCA").."F;0000"
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
  sb_init = true
  end
end