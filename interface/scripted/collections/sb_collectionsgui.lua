--Won't add stars to custom collections because
--widget.active("scrollAreaCustom") will pass
--when swapping out of customs to non-customs
--Can be worked around, but not up to it today

local originalInit = init or function() end

function init(); originalInit()
  local tabs = config.getParameter("gui.collectionTabs.buttons")
  local starWidget = config.getParameter("sb_starWidget")

  for k, v in pairs(tabs) do
    if v.data then
      local valid, collectables = pcall(function() return root.collectables(v.data) end)
      if valid then
        local addStar = true
        local playerCollectables = player.collectables(v.data)
        local indexedPlayerCollectables = {}

        for i = 1, #playerCollectables do
          indexedPlayerCollectables[playerCollectables[i]] = true
        end

        for _, c in pairs(collectables) do
          if c.name and not indexedPlayerCollectables[c.name] then
            addStar = false
            break
          end
        end
      
        if addStar then
          starWidget.position = v.position
          widget.addChild("collectionTabs", starWidget, "sb_star" .. k)
        end
      end
    end
  end
end