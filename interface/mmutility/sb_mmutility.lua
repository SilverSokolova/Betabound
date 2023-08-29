local sb_init = init or function() end
function sb_itemType()
  sb_root_itemType = root.itemType
  root.itemType = function(n)
    if root.itemHasTag(n,"miningtool") then return "beamminingtool" end
    return sb_root_itemType(n)
  end
end
function init() sb_itemType() sb_init() end