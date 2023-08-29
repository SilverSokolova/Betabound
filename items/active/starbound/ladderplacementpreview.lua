local previewImage, previewPosition, previewPosition, directives, ladderCount

function init()
  directives = ""
  floor = math.floor
  clearDrawables = localAnimator.clearDrawables
  addDrawable = localAnimator.addDrawable
  ladderCount = animationConfig.animationParameter("ladderCount")-2
end

function update()
  previewImage = animationConfig.animationParameter("previewImage")
  previewPosition = animationConfig.animationParameter("previewPosition")

  clearDrawables()
  for i = 1, #previewPosition do
    previewPosition[i] = floor(previewPosition[i])
  end
  previewPosition[2] = previewPosition[2]+0.5
  if previewPosition then
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
    image = previewImage..frame..directives,
    position = previewPosition,
    fullbright = true
  })
  previewPosition[2] = previewPosition[2] + 1
end