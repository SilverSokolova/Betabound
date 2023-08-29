function init()
  local d = effect.duration()
  local e = config.getParameter("effects")
  for i = 1, #e do
    status.addEphemeralEffect(e[i],d)
  end
  effect.expire()
end