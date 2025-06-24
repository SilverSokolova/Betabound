function sb_techType()
  root.sb_techType = root.techType
  root.techType = function(t)
    return root.techConfig(t).sb_effect and "Suit" or root.sb_techType(t)
  end
end

function sb_assetmissing(asset, fallbackAsset)
  local defaultFallbackAsset = "/sb_assetmissing.png"
  return (root.nonEmptyRegion(asset or defaultFallbackAsset) ~= nil) and asset or fallbackAsset or defaultFallbackAsset
end

function sb_itemExists(item) return root.itemConfig(item)~=nil end

function sb_pathToImage(images, path, index) return (type(images) == "table" and sb_pathToImage(images[index and #images or 1].image, path)) or images:sub(0, 1) ~= "/" and path..images or images end
--function sb_pathtoimage(a,b,c) a=a or "/assetmissing.png" return (type(a)=="table" and sb_pathtoimage(a[c and #a or 1].image,b)) or a:sub(0,1)~="/" and b..a or a end

function sb_checkClient()
  if type(math.betabound_client) == "nil" then
    math.betabound_client = root.assetJson("/player.config:genericScriptContexts").OpenStarbound and "OpenSB" or starExtensions and "StarExtensions" or "Vanilla"
  end
  return math.betabound_client
end