local updat = update or function() end

function update(dt) updat(dt)
    if self.primary and root.itemHasTag(self.primary.name, "ranged") then
      mcontroller.controlCrouch()
    end
end