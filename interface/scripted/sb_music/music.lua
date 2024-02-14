doPlay = {}
function init()
  songList = "songScrollArea.songList"
  songs = root.collectables("sb_music"); table.sort(songs, function(a, b) return a.title < b.title end)
  knownSongs, KS = {}, player.collectables("sb_music"); for _,v in pairs(KS) do knownSongs[v] = true end
  widget.setText("lblCount","^#ddd;"..#KS.."/"..#songs)
  widget.setText("lblDescription", config.getParameter("descriptions")[#KS == 0 and 1 or 2])
  KS, query, lastQuery, admin = nil, nil, nil, player.isAdmin() or config.getParameter("everythingUnlocked")
  description, mode, id = config.getParameter("description"), config.getParameter("mode",1), config.getParameter("id")
--local musicData = root.assetJson("/collections/sb_music.collection").collectables
--for k,v in pairs(songs) do if musicData[v.name].special then songs[k].title = songs[k].title.." ^yellow;^reset;" end end

  local DS = config.getParameter("defaultSongs"); table.sort(DS, function(a, b) return a.title < b.title end) --This seems to run more than #DS
  for i = 1, #DS do
    local UUID = sb.makeUuid()
    DS[i].name = UUID; songs[UUID] = DS[i]
    knownSongs[UUID] = true
  end

  if mode == 2 then
    local r = config.getParameter("range",60)
    widget.setText("lblRange",r); widget.setSliderValue("range",r)
    local w = {"lblR","imgR","r"}; for i = 1, #w do widget.setVisible(w[i].."ange",true) end
    w = {"searchBarBG","searchBar"}
    for i = 1, #w do
      local p = widget.getPosition(w[i])
      widget.setPosition(w[i],{p[1]-35,p[2]})
    end
  end
  populateList()
end

function itemSelected()
  local listItem = widget.getListSelected(songList)
  if listItem then
    selectedSong = widget.getData(string.format("%s.%s", songList, listItem))
    local desc = songs[selectedSong].description; desc = desc ~= "" and desc or "Curtis Schweitzer"
    widget.setText("lblDescription",string.format(description,songs[selectedSong].title,desc))
  end
end

function play(a) doPlay[mode](a) end
doPlay[1] = function(a)
  local stop = a == "stop"
  if not stop and not selectedSong then return end
  world.sendEntityMessage(player.id(),stop and "stopAltMusic" or "playAltMusic",stop and 1 or {doPath(songs[selectedSong].icon)},1)
end

doPlay[2] = function(a)
  local stop = a == "stop"
  if not stop and not selectedSong then return end
  if not stop then
    world.sendEntityMessage(id,"sb_radio",{doPath(songs[selectedSong].icon)},widget.getSliderValue("range"))
  else
    world.sendEntityMessage(id,"sb_radioStop")
  end
end

function doPath(a) return a:sub(1,1) == "/" and a or "/music/"..a..".ogg" end --wav?
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
      local title = song.title
      if (not query and true) or (query and song.title:lower():find(query)) then
  local listItem = widget.addListItem(songList)
  widget.setText(string.format("%s.%s.songName", songList, listItem), title)
  widget.setData(string.format("%s.%s", songList, listItem), k)
  --local icon = song.icon; if icon then widget.setImage(string.format("%s.%s.songIcon", songList, listItem), icon) end
      end
    end
  end
end