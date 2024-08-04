local originalIsEppWithAugment = isEppWithAugment or function() end

function isEppWithAugment(i)
  if not i then return false end
  local j = root.itemConfig(i)
  return i.parameters.acceptsAugmentType=="back" or originalIsEppWithAugment(i)
end