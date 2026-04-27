--[[Documentation
Change behavior of NPC spawner objects to spawn the NPC on interaction rather than on unload
]]
--I think it might be better to hook rather than change which script the object runs since other mods may try to hook into the object, expecting the original script
local originalInit = init or function() end
local originalOnInteraction = onInteraction or function() end

function init() originalInit()
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
    parameters.scriptConfig.sb_initialStatusEffects = parameters.scriptConfig.sb_initialStatusEffects or {"beamin"}
    return sb_spawnNpc(position, species, npcType, level, seed, parameters)
  end
end

function onInteraction(args)
  originalOnInteraction(args) 
  update()
end