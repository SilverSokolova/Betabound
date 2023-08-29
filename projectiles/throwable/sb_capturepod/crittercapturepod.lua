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

    -- If a monster doesn't implement pet.attemptCapture or its response is nil
    -- then it isn't caught.
    promises:add(world.sendEntityMessage(entityId, "betabound_pet.attemptCritterCapture", 9876543210), function (pet)
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
  world.spawnItem("sb_crittercapturepod", mcontroller.position(), 1)
end

function spawnFilledPod(pet)
  local pod = createFilledPod(pet)
--pod.name
--pod.parameters
if pod.parameters.description == "Some indescribable horror" then pod.parameters.description = "Throw it down to release the critter captured inside!" end
pod.parameters.pets[1].damageTeamType = "friendly"
pod.parameters.pets[1].persistent = true
pod.parameters.pets[1].wasRelocated = true
  world.spawnItem("sb_filledcrittercapturepod", mcontroller.position(), pod.count, {
      description = pod.parameters.description,
      tooltipFields = pod.parameters.tooltipFields,
      projectileConfig = {
        speed = 40,
        level = 7,
        actionOnReap = {
          {
            action = "spawnmonster",
            offset = { 0, 0 },
            type = pod.parameters.pets[1].config.type,
            arguments = pod.parameters.pets[1],
            level = pod.parameters.pets[1].level or 2
          },
          {
            action = "item",
            offset = { 0, 0 },
            name = "sb_crittercapturepod"
          }
        }
      }
    })
end
