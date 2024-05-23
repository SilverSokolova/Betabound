function init()
  action = config.getParameter("interactAction")
end

function activate() activeItem.interact(action[1], action[2], player.id()) end