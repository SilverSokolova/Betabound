doPlay = {}
function init()
  songList = "songScrollArea.songList"
  songs = root.collectables("sb_music")
  knownSongs, KS = {}, player.collectables("sb_music"); for _,v in pairs(KS) do knownSongs[v] = true end
  widget.setText("lblCount", "^#ddd;"..math.min(#KS, #songs).."/"..#songs)
  KS, query, lastQuery, admin = nil, nil, nil, player.isAdmin() or config.getParameter("everythingUnlocked")
  description, objectStorage, id = config.getParameter("description"), config.getParameter("objectStorage", {}), config.getParameter("id")
--local musicData = root.assetJson("/collections/sb_music.collection").collectables
--for k,v in pairs(songs) do if musicData[v.name].special then songs[k].title = songs[k].title.." ^yellow;^reset;" end end
  radioType = config.getParameter("radioType", "portable")
  defaultArtist = config.getParameter("defaultArtistName")

  local DS = config.getParameter("defaultSongs")
  for i = 1, #DS do
    local uuid = sb.makeUuid()
    DS[i].name = uuid
    DS[i].title = string.format("^yellow;%s^reset;", DS[i].title)
    songs[#songs+1] = DS[i]
    knownSongs[uuid] = true
  end

  table.sort(songs, function(a, b)
    a.icon = doPath(a.icon)
    b.icon = doPath(b.icon)
    return cutColors(a.title) < cutColors(b.title)
  end)

  widget.setText("lblDescription", config.getParameter("descriptions")[#songs == 0 and 1 or 2])

  if radioType == "stationary" then
    local r = objectStorage.range
    widget.setText("lblRange", r); widget.setSliderValue("range", r)
    local w = {"lblR", "imgR", "r"}; for i = 1, #w do widget.setVisible(w[i].."ange", true) end
    w = {"searchBarBG", "searchBar"}
    for i = 1, #w do
      local p = widget.getPosition(w[i])
      widget.setPosition(w[i], {p[1]-35, p[2]})
    end
  end
  populateList()
end

function itemSelected()
  local listItem = widget.getListSelected(songList)
  if listItem then
    selectedSong = widget.getData(string.format("%s.%s", songList, listItem))
    local desc = songs[selectedSong].description; desc = desc ~= "" and desc or defaultArtist
    widget.setText("lblDescription", string.format(description, cutColors(songs[selectedSong].title), desc))
  end
end

function play(a) doPlay[radioType](a) end
doPlay["portable"] = function(a)
  local stop = a == "stop"
  if not stop and not selectedSong then return end
  world.sendEntityMessage(player.id(),stop and "stopAltMusic" or "playAltMusic",stop and 1 or {songs[selectedSong].icon},1)
end

doPlay["stationary"] = function(a)
  local stop = a == "stop"
  if not stop and not selectedSong then return end
  local song = selectedSong and songs[selectedSong].icon
  world.sendEntityMessage(id, "sb_radio:update", {song = stop and "" or song, range = widget.getSliderValue("range")})
end

function doPath(directory) return directory:sub(1,1) == "/" and directory or "/music/"..directory..".ogg" end
function searchBar() query = widget.getText("searchBar"):lower() end

function setRange()
  widget.setText("lblRange",""..widget.getSliderValue("range"))
  world.sendEntityMessage(id,"sb_radio",nil,widget.getSliderValue("range"))
end

function update(dt)
  if query ~= lastQuery then populateList() end
  lastQuery = query
end

function populateList()
  widget.clearListItems(songList)
  for k, songName in pairs(songs) do
    local song = songs[k]
    if admin or (song and knownSongs[songName.name]) then
      if (not query and true) or (query and song.title:lower():find(query)) then
        local listItem = widget.addListItem(songList)
        widget.setText(string.format("%s.%s.songName", songList, listItem), song.title)
        widget.setData(string.format("%s.%s", songList, listItem), k)
        if objectStorage.song == song.icon then
          widget.setListSelected(songList, listItem)
        end
        --local icon = song.icon; if icon then widget.setImage(string.format("%s.%s.songIcon", songList, listItem), icon) end
      end
    end
  end
end

function cutColors(str)
  return str:gsub("(%^.-%;)", "")
end