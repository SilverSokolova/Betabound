require "/scripts/activeitem/sb_swing.lua"

function init(); swingInit()
  playerId = player and player.id()
  recipe = config.getParameter("recipe")
  reset()
end

function reset()
  reusable, consume, used = config.getParameter("reusable", false), false, false
end

function swingAction()
  if not player then return end

  --[[
    Send an entity message regardless if the player knows the recipe to allow
    relearning objects deleted from the Lagless Pixel Printer mod. Also provide
    the player's entity ID as natural objectScanned's provide an entity ID.
  ]]--
  world.sendEntityMessage(playerId, "objectScanned", recipe, playerId)
  local used = world.sendEntityMessage(playerId, "sb_addScandata", recipe):result() --Luckily self-messages are instant as they are not networked

  if used then
    consume = not reusable
    if consume then
      item.consume(1)
    end
  end

  reset()
end