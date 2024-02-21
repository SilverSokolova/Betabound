function init()
  effect.addStatModifierGroup({{stat="fallDamageMultiplier",effectiveMultiplier=0}})
end

function update()
  mcontroller.controlParameters({airJumpProfile={jumpSpeed=20,multiJump=true,autoJump=true}})
end