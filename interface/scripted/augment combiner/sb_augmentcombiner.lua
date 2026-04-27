local originalIsEppWithAugment = isEppWithAugment or function() end

function isEppWithAugment(i)
  if not i then return false end
  local j = root.itemConfig(i) --TODO: what. this is unused right. verify
  return i.parameters.acceptsAugmentType == "back" or originalIsEppWithAugment(i)
end