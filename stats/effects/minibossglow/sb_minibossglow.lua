local ini = init or function() end
function init() ini()
  animator.setParticleEmitterOffsetRegion("sb_minibossparticles", mcontroller.boundBox())
end