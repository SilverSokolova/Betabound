--mining tools
local files = assets.byExtension("miningtool")
local path = "/betabound/miningtool.patch"
assets.add(path, '{"canBeRepaired":true}')

for i = 1, #files do
  local valid, data = pcall(function() return assets.json(files[i]) end)
  if valid then
    local durabilityPerUse = data.durabilityPerUse or 1
    if durabilityPerUse > 0 and type(data.canBeRepaired) ~= "boolean" then
      assets.patch(files[i], path)
    end
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
  local valid, data = pcall(function() return assets.json(files[i]) end)
  if valid then
    if data.scripts then
      for j = 1, #data.scripts do
        if data.scripts[j] == "/scripts/augments/dye.lua" then
          isDye = true
          dyeDirectives = data.dyeDirectives or false
        elseif data.scripts[j] == "/scripts/augments/sb_dye.lua" then
          isDye = false
          break
        end
      end

      if isDye and type(dyeDirectives) == "table" then
        local pathName = path..data.itemName
        assets.add(pathName, dyePatch)
        assets.patch(files[i], pathName)
      end
    end
  end
end

--Remove suit tech icons from status bar if inventory display is enabled
local files = assets.byExtension("tech")
local path = "/betabound/statuseffectForSuitTech.patch"
assets.add(path, '[[{"op":"test","path":"/icon"},{"op":"remove","path":"/icon"}]]')

local effectsToPatch = {}

if assets.json("/interface/windowconfig/playerinventory.config:sb_techDisplay").enabled then
  for i = 1, #files do
    local valid, data = pcall(function() return assets.json(files[i]) end)
    if valid then
      if data.sb_effect then
        if type(data.sb_effect) == "string" then
          effectsToPatch[data.sb_effect] = true
        else
          for j = 1, #data.sb_effect do
            if type(data.sb_effect[j]) == "string" then
              effectsToPatch[data.sb_effect[j]] = true
            end
          end
        end
      end
    end
  end

  files = assets.byExtension("statuseffect")

  for i = 1, #files do
    local valid, data = pcall(function() return assets.json(files[i]) end)
    if valid then
      if effectsToPatch[data.name] then
        assets.patch(files[i], path)
      end
    end
  end
end