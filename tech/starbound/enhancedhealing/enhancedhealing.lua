function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  efficiency, resource = techConfig["efficiency"] or 2, techConfig["resource"] or "health"
  old, last = status.resource(resource), status.resourceMax(resource)
end

function update(dt)
  local new, current = status.resource(resource), status.resourceMax(resource)
  if old < new and current == last then
    status.modifyResource(resource, (new - old) / efficiency)
  end
  old = status.resource(resource)
end