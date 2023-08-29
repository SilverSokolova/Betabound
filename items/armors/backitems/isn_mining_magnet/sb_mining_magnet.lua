local ini = init or function() end
local isn_oreExchang = isn_oreExchange or function(a) end
function init() ini() sb_ores = root.assetJson("/sb_oreexchange.config") end
function isn_oreExchange(a) return sb_ores[a] or isn_oreExchang(a) end