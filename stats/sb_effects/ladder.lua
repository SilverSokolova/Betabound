local controlParameters
function init()
  controlParameters = mcontroller.controlParameters
  effect.addStatModifierGroup({{stat="fallDamageMultiplier",effectiveMultiplier=0}})
end

function update()
  controlParameters({airJumpProfile={jumpSpeed=20,multiJump=true,autoJump=true}})
end