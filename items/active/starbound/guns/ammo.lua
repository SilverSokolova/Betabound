require("/scripts/sb_assetmissing.lua")
function init()
  clearDrawables = localAnimator.clearDrawables
  ownerPosition = activeItemAnimation.ownerPosition
  addDrawable = localAnimator.addDrawable
  animationParameter = animationConfig.animationParameter
end

function update(dt)
  if animationParameter("npc") then script.setUpdateDelta(0) clearDrawables() return end
  local showPlus = false
  local ammo = animationParameter("ammo",0)
  local totalAmmo = animationParameter("totalAmmo",0)
  local name = animationParameter("name","standardbullet")
  if name then name = sb_assetmissing("/interface/sb_tooltips/"..name..".png", "/interface/sb_tooltips/assetmissing.png") end
  clearDrawables()
  if ammo > 0 then
    local pos = ownerPosition()
    pos[2]=pos[2]+animationParameter("hand",2)
    if name then addDrawable({image=name.."?scalenearest=1",scale=0.75,fullbright=true,position={pos[1]+(1/1.6),pos[2]}},"overlay") end
    pos[1]=pos[1]+1.13
    local bigStack = ammo > 9999
    if (totalAmmo > tonumber(ammo)) or bigStack then
      ammo = math.min(9999, ammo)
      showPlus = true
    end
    ammo = tostring(ammo)
    for i = 1, #ammo do
      addDrawable({image="/interface/sb_numbers.png:"..ammo:sub(i,i).."?replace;000=0000?border;1;333;0000",fullbright=true,position={pos[1]+(i/1.6),pos[2]}},"overlay")
    end
    if showPlus then
      addDrawable({image="/interface/sb_numbers.png:12?replace;000=0000?border;1;333;0000",color=bigStack and "yellow" or "white",fullbright=true,position={pos[1]+((#ammo+1)/1.6),pos[2]}},"overlay")
    end
  end
end
