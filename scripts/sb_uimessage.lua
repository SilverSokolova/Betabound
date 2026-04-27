function sb_uiMessage(n)
  player.giveItem({
    name = "sb_uimessage:" .. n,
    count = 1,
    parameters = { --TODO: pretty sure parameters aren't even applied
      value = 0,
      timeToLive = 1,
      consumeOnPickup = true
    }
  })
end