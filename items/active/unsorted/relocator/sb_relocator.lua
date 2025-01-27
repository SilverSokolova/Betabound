local originalInit = init or function() end
local originalUpdate = update or function() end

function init() originalInit()
  if config.getParameter("sb_doNotUpdateInventoryIcon") then
    update = originalUpdate
    return
  end
  sb_lastSize = config.getParameter("scriptStorage", {})
  sb_lastSize = #(sb_lastSize.storedMonsters or '')
  sb_directory = root.itemConfig(config.getParameter("itemName")).directory
end

function update(...) originalUpdate(...)
  local currentSize = config.getParameter("scriptStorage", {})
  currentSize = #(currentSize.storedMonsters or '')
  if currentSize ~= sb_lastSize then
    local icon = config.getParameter("inventoryIcon")
    --So activeItem.setInventoryIcon, along with not accepting anything but strings, also requires an absolute path, even though inventory icons can use local paths. Lovely.
    if icon then
      activeItem.setInventoryIcon((icon:sub(1, 1) ~= "/" and sb_directory or "")..icon:gsub(":"..sb_lastSize, ":"..currentSize))
    end
  end
  sb_lastSize = currentSize
end