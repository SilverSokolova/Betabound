function init()
  h = animationConfig.animationParameter("hand") == "alt" and 3 or 2
  midday = root.assetJson("/scripts/fishing/fishingspawner.config")
  midday = (midday.dayRange[2]+midday.nightRange[1])/2
end

function update(dt)
  local d = world.timeOfDay()
  local t = d * 24 * 3600 or 0
  local m = tostring(math.floor((t/60)%60))
  local h = string.format("%02d",math.floor(((t/3600)+6)%24))
  read(d,h,m)
end

function read(d,hr,m)
  localAnimator.clearDrawables()
  local pos = activeItemAnimation.ownerPosition()
  pos[2]=pos[2]+h
  d = d <= midday
  m = m:reverse()
  local time = {hr:sub(1,1),hr:sub(2,2),11,#m==2 and m:sub(2,2) or 0, m:sub(1,1)}
  for i = 1, #time do
    localAnimator.addDrawable({image="/interface/sb_numbers.png:"..time[i],fullbright=true,position={pos[1]+(i/1.6),pos[2]}},"overlay")
  end
  localAnimator.addDrawable({image=d and "/interface/tooltips/warmth.png?replace;454545=0000" or "/interface/bookmarks/icons/moon.png",fullbright=true,position={pos[1]+((#time+1.5)/1.6),pos[2]+0.125},scale=0.5},"overlay")
end