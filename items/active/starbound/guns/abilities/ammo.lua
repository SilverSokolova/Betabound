require("/scripts/sb_assetmissing.lua")

function update(dt)
  if animationConfig.animationParameter("npc") then script.setUpdateDelta(0) localAnimator.clearDrawables() return end
  local showPlus = false
  local ammo = animationConfig.animationParameter("ammo",0)
  local totalAmmo = animationConfig.animationParameter("totalAmmo",0)
  local name = animationConfig.animationParameter("name","standardbullet")
  if name then name = sb_assetmissing("/interface/sb_tooltips/"..name..".png", "/interface/sb_tooltips/assetmissing.png") end
  localAnimator.clearDrawables()
  if ammo > 0 then
    local pos = activeItemAnimation.ownerPosition()
    pos[2]=pos[2]+animationConfig.animationParameter("hand",2)
    if name then localAnimator.addDrawable({image=name.."?scalenearest=1",scale=0.75,fullbright=true,position={pos[1]+(1/1.6),pos[2]}},"overlay") end
    pos[1]=pos[1]+1.13
    local bigStack = ammo > 9999
    if (totalAmmo > tonumber(ammo)) or bigStack then
      ammo = math.min(9999, ammo)
      showPlus = true
    end
    ammo = tostring(ammo)
    for i = 1, #ammo do
      localAnimator.addDrawable({image="/interface/sb_numbers.png:"..ammo:sub(i,i).."?replace;000=0000?border;1;333;0000",fullbright=true,position={pos[1]+(i/1.6),pos[2]}},"overlay")
    end
    if showPlus then
      localAnimator.addDrawable({image="/interface/sb_numbers.png:12?replace;000=0000?border;1;333;0000",color=bigStack and "yellow" or "white",fullbright=true,position={pos[1]+((#ammo+1)/1.6),pos[2]}},"overlay")
    end
  end
end
