require "/scripts/util.lua"
require "/scripts/companions/capturable.lua"
require "/scripts/messageutil.lua"

function update(dt)
  promises:update()
end

function hit(entityId)
  if self.hit then return end
  if world.isMonster(entityId) then
    self.hit = true
self.id = entityId

    promises:add(world.sendEntityMessage(entityId, "betabound_pet.attemptCapture", 0.5), function (pet)
        self.pet = pet
      end)
  end
end

function shouldDestroy()
  return projectile.timeToLive() <= 0 and promises:empty()
end

function destroy()
  if self.pet then
    spawnFilledPod(self.pet)
  else
    spawnEmptyPod()
  end
end

function spawnEmptyPod()
  world.spawnItem("sb_capturepod", mcontroller.position(), 1)
end


function spawnFilledPod(pet)
local pet = createFilledPod(pet)
pet2 = pet.parameters.pets[1]
local pod = {}
pod.parameters = {}
pod.parameters.statusSettings = {}
pod.parameters.statusSettings.stats = {}
pod.parameters.status = pet2.status
local statsA, statsB = pod.parameters.status.stats, pod.parameters.statusSettings.stats
for a,b in pairs(statsA) do
--if a ~= "health" and a~= "maxHealth" and not statsB[a] then statsB[a] = {baseValue=b} end
end
pod.parameters.statusSettings.stats = statsB
pod.parameters.aggressive = true
pod.parameters.damageTeamType = "friendly"
pod.parameters.wasRelocated = true
pod.config = {}
pod.config.seed = pet.parameters.pets[1].config.parameters.seed or 1
pod.seed = pet.parameters.pets[1].config.parameters.seed or 1
pod.parameters.seed = pet.parameters.pets[1].config.parameters.seed or 1
pod.config.type = pet2.config.type or "punchy"
pod.parameters.persistent = true
pod.config.persistent = true
pod.config.uuid = pod.parameters.podUuid or sb.makeUuid()
pod.config.level = pet2.config.level or pet2.status.stats.sb_level or pet2.config.level or pet.parameters.pets[1].sb_level or 0
pod.parameters.level = pet2.config.level or pet2.status.stats.sb_level or pet2.config.level or pet.parameters.pets[1].sb_level or 0

if pet.parameters.description == "Some indescribable horror" then pet.parameters.description = pet.parameters.description.."." end



pod.parameters.level = pet2.level or pet2.status.stats.sb_level or pet2.config.level or pet.parameters.pets[1].sb_level or 0
  world.spawnItem("sb_filledcapturepod", mcontroller.position(), 1, {
      description = pet.parameters.description,
      tooltipFields = pet.parameters.tooltipFields,
      projectileConfig = {
        speed = 40,
	level = 7,
        actionOnReap = {
          {
	    action = "spawnmonster",
	    offset = { 0, 0 },
	    type =  pod.config.type or "punchy",
	    arguments = pod.parameters,
	    seed = pet.parameters.pets[1].config.parameters.seed or 1,
	    level = (pod.parameters.level or pet2.config.level or 0)
          },
          {
            action = "item",
            offset = { 0, 0 },
            name = "sb_capturepod"
          },
          {
            action = "projectile",
            type = "sb_statusapplier",
	    config = {statusEffects = {"sb_capturedmonster"}}
          }
        }
      }
    })

end