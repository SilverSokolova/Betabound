function sb_uiMessage(msg)
  player.giveItem({
    name = "sb_uimessage:" .. msg,
    count = 1,
    parameters = { --TODO: pretty sure parameters aren't even applied
      value = 0,
      timeToLive = 1,
      consumeOnPickup = true
    }
  })
end