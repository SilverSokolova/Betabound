local ini = init or function() end

function init()
  handOffset = animationConfig.animationParameter("hand") == "alt" and 3 or 2
  textDirectives = root.assetJson("/betabound.config:infoItemTextDirectives")
  ini()
end

function addText(text, position, backingDirectives, textOffset)
  local textOffset = textOffset or 1
  for i = 1, #text do
    local character = text:sub(i, i)
    if character ~= " " then
      localAnimator.addDrawable(
        {
          image = string.format("/interface/sb_font.png:%s%s%s", character, backingDirectives or "", textDirectives),
          fullbright = true,
          position = {position[1] + (textOffset/1.6), position[2] + handOffset}
        },
        "overlay"
      )
    end
    textOffset = textOffset + 1
  end
  return textOffset
end