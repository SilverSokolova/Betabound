function build(directory, config, parameters)
  local m = month()
  local a = parameters.sb_timecapsuleConfig or config.sb_timecapsuleConfig
  config.itemName = 0 ~= a[2][m] and (type(a[2][m]) == "table" and a[2][m][math.random(1,#a[2][m])] or a[2][m]) or a[1]
  return config, {}
end

function month() local a=(os.time()-os.time{year=2000,month=1,day=1})/31557600 return math.ceil((a-math.floor(a))*12) end