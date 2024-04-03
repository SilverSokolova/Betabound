local ini = init or function() end
local updat = update or function() end

function init() ini()
  if config.getParameter("sb_doNotUpdateInventoryIcon") then
    update = updat
    return
  end
  sb_lastSize = config.getParameter("scriptStorage", {})
  sb_lastSize = #(sb_lastSize.storedMonsters or '')
end

function update(...) updat(...)
  local currentSize = config.getParameter("scriptStorage", {})
  currentSize = #(currentSize.storedMonsters or '')
  if currentSize ~= sb_lastSize then
    local icon = config.getParameter("inventoryIcon")
    --So activeItem.setInventoryIcon, along with not accepting anything but strings, also requires an absolute path, even though inventory icons can use local paths
    --https://www.youtube.com/watch?v=S-ZeYX53ZY0 <- I listened to this while programming this part
    if icon then
      activeItem.setInventoryIcon((icon:sub(1, 1) ~= "/" and root.itemConfig(config.getParameter("itemName")).directory or "")..icon:gsub(":"..sb_lastSize, ":"..currentSize))
    end
  end
  sb_lastSize = currentSize
end