function sb_cursor(cursor)
  if player.swapSlotItem() == nil then
    activeItem.setCursor("/cursors/"..cursor..".cursor")
  end
end