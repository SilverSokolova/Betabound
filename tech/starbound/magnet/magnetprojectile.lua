function init() message.setHandler("die", function() mcontroller.setPosition{0,-999999} end) end
function update() projectile.setTimeToLive(1) end