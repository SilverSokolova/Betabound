local originalInit = init or function() end

function init() originalInit()
  sb_techTier = player.getProperty("sb_techTier") --TODO: could we move this to the if statement below? or the return?
  if config.getParameter("sb_useTechTier", false) then
    root.sb_createTreasure = root.createTreasure
    root.createTreasure = function(pool, level, seed) return root.sb_createTreasure(pool, sb_techTier or level, seed) end
  end
end