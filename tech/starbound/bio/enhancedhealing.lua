function init()
  local techConfig = root.techConfig(config.getParameter("tech"))
  e, r = techConfig["efficiency"] or 2, techConfig["resource"] or "health"
  old, last = status.resource(r), status.resourceMax(r)
end

function update(dt)
  local new, current = status.resource(r), status.resourceMax(r)
  if old < new and current == last then
    status.modifyResource(r, (new-old)/e)
  end
  old = status.resource(r)
end