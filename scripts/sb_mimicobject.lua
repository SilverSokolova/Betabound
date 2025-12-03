--TODO: move to `/scripts/objects`?
function init()
  if config.getParameter("sb_objectName") then return end
  local newParameters = root.itemConfig(config.getParameter("objectName"):sub(4)).config
  for k, v in pairs(newParameters) do
    object.setConfigParameter(k, v)
  end
  object.setConfigParameter("sb_objectName", config.getParameter("objectName"))
end