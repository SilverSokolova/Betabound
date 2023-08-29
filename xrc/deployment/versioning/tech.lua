local ini = init or function() end
function init() ini()
local a = player.equippedTech local t = {a("head"),a("body"),a("legs")}
for f = 1, 3 do if t[f] then if not root.hasTech(t[f]) then player.unequipTech(t[f]) end end end end