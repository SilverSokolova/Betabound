function init()
  local techConfig = root.techConfig(config.getParameter("tech"))

  local stat = techConfig["stat"]
  local newMultiplier = techConfig["multiplier"] * (mcontroller.baseParameters()[stat] or 1)

  --mcontroller.controlParameters doesn't like strings as keys
  controlParameters = {}
  controlParameters[stat] = newMultiplier
end

function update(dt)
  mcontroller.controlParameters(
    controlParameters
  )
end