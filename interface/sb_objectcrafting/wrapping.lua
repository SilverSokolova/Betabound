function init()
  desc = root.itemConfig("sb_itembox").config.description..config.getParameter("desc")
  id = pane.containerEntityId()
end

function update()
  widget.setButtonEnabled("wrap", player.isAdmin() or player.hasItem("sb_wrappingpaper"))
end

function wrap()
  local contents = world.containerItems(id)
  local items = {}
  for k, v in pairs(contents) do
    if v.name ~= "sb_itembox" and v.name ~= "sb_wrappingpaper" then
      world.containerConsumeAt(id, k-1, v.count)
      items[#items+1] = contents[k]
    end
  end
  if #items > 0 and (player.isAdmin() or player.consumeItem("sb_wrappingpaper")) then
    local params = {items=items}
    if #items > 1 then params.description = string.format(desc,#items) end
    player.giveItem({"sb_itembox",1,params})
  end
end