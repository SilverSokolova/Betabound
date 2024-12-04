require("/scripts/sb_assetmissing.lua")
require("/scripts/animations/sb_info.lua")

function update(dt)
  if animationConfig.animationParameter("npc") then script.setUpdateDelta(0) localAnimator.clearDrawables() return end
  local showPlus = false
  local ammo = animationConfig.animationParameter("ammo", 0)
  local totalAmmo = animationConfig.animationParameter("totalAmmo", 0)
  local name = animationConfig.animationParameter("name", "standardbullet")
  if name then name = sb_assetmissing("/items/generic/other/sb_ammo/"..name..".png") end
  localAnimator.clearDrawables()
  if ammo > 0 then
    local pos = activeItemAnimation.ownerPosition()
    local textOffset = 3
    localAnimator.addDrawable(
      {
        image = name.."?scalenearest=1",
        scale = 0.75,
        fullbright = true,
        position = {pos[1] + (1/1.6), pos[2]+handOffset}
      },
      "overlay"
    )
    local bigStack = ammo > 9999
    if (totalAmmo > ammo) or bigStack then
      ammo = math.min(9999, ammo)
      showPlus = true
    end
    ammo = tostring(ammo)
    textOffset = addText(ammo, pos, nil, textOffset)
    if showPlus then
      addText("+", pos, bigStack and "?replace;fff=FDED1E" or nil, textOffset)
    end
  end
end
