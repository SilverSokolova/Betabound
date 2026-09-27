function init()
  gameList = "gameScrollArea.gameList"
  games = config.getParameter("games")
  gameNameFormat = config.getParameter("gameNameFormat")
  table.sort(games, function(a, b)
    return a[1] < b[1]
  end)
  populateList()
end

function populateList()
  widget.clearListItems(gameList)
  for i = 1, #games do
    local listItem = widget.addListItem(gameList)
    widget.setText(string.format("%s.%s.gameName", gameList, listItem), string.format(games[i][1], gameNameFormat))
    widget.setData(string.format("%s.%s", gameList, listItem), games[i][2])
  end
end

function itemSelected()
  widget.setButtonEnabled("play", true)
  local listItem = widget.getListSelected(gameList)
  if listItem then
    selectedGame = widget.getData(string.format("%s.%s", gameList, listItem))
  end
end

function play()
  player.interact("ScriptPane", selectedGame, player.id())
  pane.dismiss()
end