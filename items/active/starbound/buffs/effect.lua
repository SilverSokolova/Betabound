function init()
--a = config.getParameter(activeItem.hand().."Effects",config.getParameter("effects",{}))
  a = config.getParameter("effects",{})
  local b = {}
  for i = 1, #a do
    b[i] = {effect=a[i],duration=0.1}
  end
  a = b
end

function update() status.addEphemeralEffects(a) end