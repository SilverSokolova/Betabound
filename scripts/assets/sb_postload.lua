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

--dyes
local files = assets.byExtension("augment")
local path = "/betabound/dye.patch"
local dyePatch = assets.json("/items/generic/dyes/sb_dye.patch")

local paletteSwapDirective = function(color)
  local directive = "?replace"
  for key, val in pairs(color) do
    directive = directive .. ";" .. key .. "=" .. val
  end
  return directive
end

for i = 1, #files do
  local isDye = false
  local dyeDirectives = false
  if files[i]:find("dye") then
    local itemData = assets.json(files[i])
    if itemData.scripts then
      for j = 1, #itemData.scripts do
        if itemData.scripts[j] == "/scripts/augments/dye.lua" then
          isDye = true
          dyeDirectives = itemData.dyeDirectives or false
        elseif itemData.scripts[j] == "/scripts/augments/sb_dye.lua" then
          isDye = false
          break
        end
      end

      if isDye and type(dyeDirectives) == "table" then
        local pathName = path..itemData.itemName
        assets.add(pathName, dyePatch)
        assets.patch(files[i], pathName)
      end
    end
  end
end