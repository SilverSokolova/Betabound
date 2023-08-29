function init()
  h = animationConfig.animationParameter("hand") == "alt" and 3 or 2
end

function update(dt)
  localAnimator.clearDrawables()
  local c = animationConfig.animationParameter("c"); c={tostring(math.floor(c[1])),tostring(math.floor(c[2]))}
  local pos = activeItemAnimation.ownerPosition(); pos[2]=pos[2]+h
  k = 1
  for i = 1, 2 do
    for j = 1, #c[i] do
      localAnimator.addDrawable({image="/interface/sb_numbers.png:"..c[i]:sub(j,j),fullbright=true,position={pos[1]+(k/1.6),pos[2]}},"overlay")
      k=k+1
    end
    if i == 1 then
      localAnimator.addDrawable({image="/interface/sb_numbers.png:13",fullbright=true,position={pos[1]+(k/1.6),pos[2]}},"overlay")
      k=k+1
    end
  end
end