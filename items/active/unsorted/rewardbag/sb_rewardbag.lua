local ini = init or 0

function init() if type(ini) == "function" then ini() end
  sb_techTier = player.getProperty("sb_techTier")
  if config.getParameter("sb_useTechTier",false) then
    root.sb_createTreasure = root.createTreasure
    root.createTreasure = function(pool, level, seed) return root.sb_createTreasure(pool, sb_techTier or level, seed) end
  end
end