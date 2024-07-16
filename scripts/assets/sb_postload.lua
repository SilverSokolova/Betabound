--mining tools
local files = assets.byExtension("miningtool")
local path = "/betabound/d1e48968b51d4616893aac83fe0c509c.patch"
assets.add(path, '{"canBeRepaired":true}')

for i = 1, #files do
  local durabilityPerUse = assets.json(files[i]).durabilityPerUse or 1
  if durabilityPerUse > 0 and type(assets.json(files[i]).canBeRepaired) ~= "boolean" then
    assets.patch(files[i], path)
  end
end

--food buff recipe groups (TODO)