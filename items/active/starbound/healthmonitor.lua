function init()
  h = animationConfig.animationParameter("hand") == "alt" and 3 or 2
  colors = animationConfig.animationParameter("colors")
end

function update(dt)
  localAnimator.clearDrawables()
  local c, m = animationConfig.animationParameter("c"), animationConfig.animationParameter("m")
  for i = 1, #c do
    c[i]=tostring(math.floor(c[i]))
    m[i]=tostring(math.floor(m[i]))
  end
  if ((tonumber(c[3]) == tonumber(m[3])-1) or (c[3] == m[3])) then c[3] = m[3] end
  local pos = activeItemAnimation.ownerPosition(); pos[2]=pos[2]+h
  k = 1
  for i = 1, #c do
    for j = 1, #c[i] do
      localAnimator.addDrawable({image="/interface/sb_numbers.png:"..c[i]:sub(j,j).."?replace;fff="..colors[c[i]==m[i] and 1 or 2][i],fullbright=true,position={pos[1]+(k/1.6),pos[2]}},"overlay")
      k=k+1
    end
    if i ~= #c then
      localAnimator.addDrawable({image="/interface/sb_numbers.png:13",fullbright=true,position={pos[1]+(k/1.6),pos[2]}},"overlay")
      k=k+1
    end
  end
end