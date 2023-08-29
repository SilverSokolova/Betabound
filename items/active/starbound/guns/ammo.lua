require("/scripts/sb_assetmissing.lua")
function init()
  clearDrawables = localAnimator.clearDrawables
  ownerPosition = activeItemAnimation.ownerPosition
  addDrawable = localAnimator.addDrawable
  animationParameter = animationConfig.animationParameter
end

function update(dt)
  if animationParameter("npc") then script.setUpdateDelta(0) clearDrawables() return end
  local ammo = animationParameter("ammo",0)
  local name = animationParameter("name","standardbullet")
  if name then name = sb_assetmissing("/interface/sb_tooltips/"..name..".png", "/interface/sb_tooltips/assetmissing.png") end
  clearDrawables()
  if ammo > 0 then
    local pos = ownerPosition()
    pos[2]=pos[2]+animationParameter("hand",3)
    if name then addDrawable({image=name.."?scalenearest=1",scale=0.75,fullbright=true,position={pos[1]+(1/1.6),pos[2]}},"overlay") end
    pos[1]=pos[1]+1
    ammo = tostring(ammo)
    if #ammo > 4 then
      ammo = "9999"
      addDrawable({image="/interface/sb_numbers.png:12",fullbright=true,position={pos[1]+(5/1.6),pos[2]}},"overlay")
    end
    for i = 1, #ammo do
      addDrawable({image="/interface/sb_numbers.png:"..ammo:sub(i,i),fullbright=true,position={pos[1]+(i/1.6),pos[2]}},"overlay")
    end
  end
end
