require "/scripts/sb_assetmissing.lua"

function init()
  storage.transformationGroupData = storage.transformationGroupData or {plate = {0, 0}, item = {0, 0}}
  animator.resetTransformationGroup("item")
  animator.resetTransformationGroup("plate")
  message.setHandler("sb_flipPlate", function()
    storage.flipped = not storage.flipped
    containerCallback()
  end)
end

function containerCallback() --By the way, is this called if something other than a player takes an item?
  local item = world.containerItemAt(entity.id(), 0)
  if item then
    thisIsUtterlyFuckingRetarded()
    itemConfig = root.itemConfig(item.name)
    directory = itemConfig.directory
    itemConfig = itemConfig.config
    local plateConfig = itemConfig.sb_plate
    if plateConfig then hasPlateConfig = true end
    plateConfig = plateConfig or {}
    plateImage = plateConfig.image or itemConfig.sb_plateImage
    plateOffset = plateConfig.offset or itemConfig.sb_plateOffset
    plateWidth = plateConfig.width or itemConfig.sb_plateWidth
    plateHidden = plateConfig.hidePlate or itemConfig.sb_plateHide or root.itemHasTag(item.name, "sb_plate_hide")
    flipImage = storage.flipped and true or plateConfig.flipImage or root.itemHasTag(item.name, "sb_plate_flipx")

    if plateImage then
      if type(plateImage) == "boolean" then
        plateImage = item.name
      end
      if type(plateImage) ~= "boolean" and plateImage:sub(0, 1) ~= "/" then
        plateImage = string.format("/objects/generic/sb_plate/%s", plateImage)
      end
      if not plateImage:find(".png") then
        plateImage = plateImage..".png"
      end
    end
    if
      plateImage or root.itemType(item.name) == "consumable" or root.itemType(item.name) == "generic" or
        hasPlateConfig or
        itemConfig.sb_forcePlate or
        root.itemHasTag(item.name, "sb_forcePlate")
    then
      local short = itemConfig.shortdescription
      local desc = itemConfig.description
      object.setConfigParameter(
        "description",
        (itemConfig.description or "This item needs to have a description set.")
      )
      local image =
        plateImage or item.parameters.inventoryIcon and sb_pathToImage(item.parameters.inventoryIcon, directory) or
        sb_pathToImage(itemConfig.inventoryIcon, directory)
      local points = root.nonEmptyRegion(image) or {0, 0, 16, 16}
      animator.resetTransformationGroup("item")
      animator.resetTransformationGroup("plate")
      if plateOffset then
        if type(plateOffset) == "number" then
          plateOffset = {plateOffset, 0}
        end
        updateTransformationGroup("item", -plateOffset[1], plateOffset[2])
        --animator.translateTransformationGroup("item", {-plateOffset[1], plateOffset[2]})
      end
        updateTransformationGroup("item", 0, plateImage and 0.25 or 0.133)
      --animator.translateTransformationGroup("item", {0, plateImage and 0.25 or 0.133}) --Yeah, yeah, it floats a few subpixels above the plate. I'm not very good with math
      animator.setGlobalTag(
        "item",
        string.format(
          (plateImage and "%s" or "%s?replace;000=0000;151515=0000;020202=0000;45421e=0000").."%s",
          --(plateImage and "%s" or "%s?replace;000=00000019;151515=15151519;020202=02020219;45421e=45421e19").."%s",
          image,
          flipImage and "" or "?flipx" --So funny story, it's kinda already flipped. Well, the item is, anyway, not the plate.
        )
      )
      animator.setGlobalTag("plate", "/objects/generic/sb_plate/plate.png")
      if plateWidth then
        animator.setGlobalTag(
          "plate",
          "/objects/generic/sb_plate/plate.png?scalenearest=1." .. plateWidth .. ";1"
        )
        object.say("H")
        animator.translateTransformationGroup("plate",{-0.125*(plateWidth/2),0})
        --animator.translateTransformationGroup("item",{0.125*(plateWidth/2),0})
        --[[animator.translateTransformationGroup(
          "item",
          {
            -0.125 *
              math.min(
                (points[1] % 2 == 1 and points[1] + 1 or points[1]),
                (points[3] % 2 == 1 and points[3] - points[1] or points[3])
              ) -
              0.250,
            -0.125 * math.min(points[2], points[4])
          }
        )]]
        --if not root.itemHasTag(item.name,"sb_plate_stay") then animator.translateTransformationGroup("item",{0.125*plateWidth,0}) end --this is unused, right?
        return
      end
      if itemConfig.category == "drink" or itemConfig.category == "medicine" or plateHidden then
        animator.setGlobalTag("plate", "")
        --[[animator.translateTransformationGroup(
          "item",
          {-0.125 * 2.5, -0.125 * (points[2] == 1 and 3 or 2 + points[2])}
        )]]
      else
        --animator.translateTransformationGroup("item", {-0.125 * 2, -0.125 * math.min(points[2], points[4])})
      end
    else
      animator.setAnimationState("plate", "perfectlygenericitem")
      animator.setGlobalTag("item", "")
      animator.setGlobalTag("plate", "/objects/generic/sb_plate/plate.png")
      resetPlate()
      return
    end
  else
    animator.setGlobalTag("item", "")
    animator.setGlobalTag("plate", "plate.png")
    resetPlate()
  end
  animator.setAnimationState("plate", "plate")
  translateTransformationGroups()
end

function resetPlate()
  storage.transformationGroupData = {plate = {0, 0}, item = {0, 0}}
  storage.flipped = false
  animator.resetTransformationGroup("item")
  animator.resetTransformationGroup("plate")
  object.setConfigParameter("description", root.itemConfig("sb_plate").config.description) --Better to just grab it as needed instead of storing 20 copies for each plate in that guy's base...
end

--This is for a stupid workaround for the plates shifting one pixel to the right after reloading the planet >:(
function translateTransformationGroups()
  local groupData = storage.transformationGroupData
  for k, v in pairs(groupData) do
    animator.translateTransformationGroup(k, v)
  end
end

function updateTransformationGroup(group, x, y)
  storage.transformationGroupData[group][1] = storage.transformationGroupData[group][1] + x
  storage.transformationGroupData[group][2] = storage.transformationGroupData[group][2] + y
end

function thisIsUtterlyFuckingRetarded()
  local groupData = storage.transformationGroupData
  for k, v in pairs(groupData) do
    animator.translateTransformationGroup(k, {-v[1], -v[2]})
  end
  storage.transformationGroupData = {plate = {0, 0}, item = {0, 0}}
end