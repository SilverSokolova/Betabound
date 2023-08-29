require "/scripts/activeitem/sb_cursors.lua"
function init() sb_cursor("chat") activeItem.setHoldingItem(false) end

function activate()
  local quest = config.getParameter("quest")
  if player and quest then
    if not player.hasQuest(quest) or (player.hasQuest(quest) and not player.hasCompletedQuest(quest)) then
      player.startQuest(quest)
      item.consume(1)
    end
  end
end