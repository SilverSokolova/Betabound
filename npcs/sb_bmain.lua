local ini = init or function() end
local updat = update or function() end

function init() ini()
  sb_crouching = config.getParameter("sb_crouching")
  --Book of Spirits check prevents us from merging the scripts we have
  local booth = root.itemConfig("protectorateinfobooth").config
  if booth.npcName and booth.displayTitle then
    require("/npcs/bookofspirits_interact.lua")
  end
end

function update(dt) updat(dt)
  if sb_crouching then
    if self.primary and root.itemHasTag(self.primary.name, "ranged") then
      mcontroller.controlCrouch()
    end
  end
end