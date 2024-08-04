local originalInit = init or function() end
function init() originalInit()
  animator.setParticleEmitterOffsetRegion("sb_minibossparticles", mcontroller.boundBox())
end