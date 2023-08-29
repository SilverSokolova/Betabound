function sb_cursor(n) if player.swapSlotItem()==nil then activeItem.setCursor("/cursors/"..n..".cursor") end end
function uninit() activeItem.setCursor() end