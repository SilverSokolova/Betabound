local previewImage, previewPosition, previewPosition, directives, ladderCount

function init()
  directives = ""
  floor = math.floor
  clearDrawables = localAnimator.clearDrawables
  addDrawable = localAnimator.addDrawable
end

function update()
  clearDrawables()
  ladderCount = animationConfig.animationParameter("ladderCount") - 2

  previewImage = animationConfig.animationParameter("previewImage")
  previewPosition = animationConfig.animationParameter("previewPosition")

  for i = 1, #previewPosition do
    previewPosition[i] = floor(previewPosition[i])
  end

  previewPosition[2] = previewPosition[2] + 0.5

  if previewPosition then --Okay, but what about earlier??
    directives = animationConfig.animationParameter("previewValid") and "?fade=5F50;0.25?border=2;6F67;0000" or "?fade=F550;0.25?border=2;F667;0000"
    addLadder(":bottom")
    for i = 1, ladderCount do
      addLadder(":middle")
    end
    addLadder(":top")
  end
end

function addLadder(frame)
  addDrawable({
    image = previewImage .. frame .. directives,
    position = previewPosition,
    fullbright = true
  })
  previewPosition[2] = previewPosition[2] + 1
end