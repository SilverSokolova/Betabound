local originalInit = init or function() end

function init(); originalInit()
  local tabs = config.getParameter("gui.collectionTabs.buttons")
  local starWidget = config.getParameter("sb_starWidget")

  for k, v in pairs(tabs) do
    if v.data then
      local addStar = true
      local collectables = root.collectables(v.data)
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