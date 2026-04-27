--TODO: move this to objects folder?
local originalInit = init or function() end
function init()
  originalInit()
  sb_spawnProjectile = world.spawnProjectile
  world.spawnProjectile = function(projectileName, position, sourceEntityId, direction, trackSourceEntity, parameters)
    if parameters and parameters.sb_positionOffset and position then
      position = {position[1] + parameters.sb_positionOffset[1], position[2] + parameters.sb_positionOffset[2]}
    end
    return sb_spawnProjectile(projectileName, position, sourceEntityId, direction, trackSourceEntity, parameters)
  end
end