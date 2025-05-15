function init()
  local techConfig = root.techConfig(config.getParameter("tech"))

  controlModifiers = techConfig["controlModifiers"]
  local statModifierGroup = techConfig["statModifierGroup"]

  if statModifierGroup then
    effect.addStatModifierGroup(statModifierGroup)
  end
end

function update()
  mcontroller.controlModifiers(controlModifiers)
end