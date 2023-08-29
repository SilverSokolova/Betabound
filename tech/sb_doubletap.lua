require "/scripts/util.lua"

DoubleTap = {}

function DoubleTap:new(validKeys, doubleTapTime, tapCallback)
  local newDoubleTap = {
    doubleTapTime = doubleTapTime,
    validKeys = validKeys,
    tapCallback = tapCallback,
    previousKeys = {},
    tapTimer = 0
  }
  setmetatable(newDoubleTap, extend(self))
  return newDoubleTap
end

function DoubleTap:reset()
  self.previousKeys = {}
  self.currentKey = nil
  self.tapTimer = 0
end

function DoubleTap:update(dt, newKeys)
  if self.currentKey then
    self.tapTimer = math.max(0, self.tapTimer - dt)
    if self.tapTimer == 0 then
      self.currentKey = nil
    elseif newKeys[self.currentKey] and not self.previousKeys[self.currentKey] then
      self.tapCallback(self.currentKey)
      self.currentKey = nil
      return
    end
  end

  for _, key in pairs(self.validKeys) do
    if newKeys[key] and not self.previousKeys[key] then
      self.currentKey = key
      self.tapTimer = self.doubleTapTime
    end
  end

  self.previousKeys = newKeys
end
