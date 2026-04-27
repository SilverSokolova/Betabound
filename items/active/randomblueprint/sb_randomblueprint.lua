local originalLearnBlueprint = learnBlueprint or function() end

function learnBlueprint(); originalLearnBlueprint()
--self.swingTime = 0
  self.swingTimer = false
  activeItem.setArmAngle(-math.pi / 2) --Same as in init
end