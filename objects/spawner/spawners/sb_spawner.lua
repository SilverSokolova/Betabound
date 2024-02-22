local ini = init or function() end
local sb_onInteraction = onInteraction or function() end

function init() ini()
  script.setUpdateDelta(0)
  object.setInteractive(true)
  sb_scriptConfig = config.getParameter("spawner.sb_scriptConfig")

  sb_smash = object.smash
  object.smash = function() sb_smash(true) end

  sb_toAbsolutePosition = object.toAbsolutePosition
  object.toAbsolutePosition = function(z) return sb_toAbsolutePosition{z[1],z[2]+1} end

  world.isVisibleToPlayer = function() return false end

  sb_spawnNpc = world.spawnNpc
  world.spawnNpc = function(position, species, npcType, level, seed, parameters)
    if parameters and sb_scriptConfig then
      parameters.scriptConfig = sb.jsonMerge(sb_scriptConfig, parameters.scriptConfig)
    end
    parameters.scriptConfig.sb_beamIn = true
    return sb_spawnNpc(position, species, npcType, level, seed, parameters)
  end
end

function onInteraction(args)
  sb_onInteraction(args) 
  update()
end