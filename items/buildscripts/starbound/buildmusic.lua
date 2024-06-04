function build(directory, config, parameters)
  musicData = root.assetJson("/collections/sb_music.collection").collectables
  musicList = {}; for k, _ in pairs(musicData) do if not musicData[k].special then musicList[#musicList+1] = k end end
  local music = parameters.music
  music = musicData[music] and music or musicList[math.random(#musicList)]
  parameters = root.assetJson("/collections/sb_music.config")[music] or {}
  parameters.music = music
  musicData = musicData[music]
  config.shortdescription = musicData.title or config.shortdescription
  config.rarity = musicData.special and "rare" or config.rarity
  config.collectablesOnPickup = {sb_music = music}
  return config, parameters
end