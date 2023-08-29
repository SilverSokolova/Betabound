function update(dt)
  local item = world.containerItemAt(entity.id(), 0)
  if item then
    local itemType = root.itemType(item.name)
    if itemType == "consumable" then
      animator.setAnimationState("bowl", "full")
      return
    end
  end

  animator.setAnimationState("bowl", "empty")
end