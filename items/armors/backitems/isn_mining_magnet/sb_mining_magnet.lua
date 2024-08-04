local originalInit = init or function() end
local originalIsn_oreExchang = isn_oreExchange or function(a) return a end

function init() originalInit() sb_ores = root.assetJson("/sb_oreexchange.config") end
function isn_oreExchange(a) return sb_ores[a] or originalIsn_oreExchang(a) end