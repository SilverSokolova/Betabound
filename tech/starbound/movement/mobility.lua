function init() effect.addStatModifierGroup({{stat="jumpModifier",amount=0.5}}) end
function update(dt) mcontroller.controlModifiers({speedModifier=1.5,airJumpModifier=1.5}) end