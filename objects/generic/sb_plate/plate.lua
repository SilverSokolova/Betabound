require "/scripts/sb_assetmissing.lua"

function init()
  message.setHandler("sb_flipPlate", function()
    storage.flipped = not storage.flipped
    containerCallback()
  end)

  --This helps counter the stupid plate offset thing
  animator.sb_translateTransformationGroup = animator.translateTransformationGroup
  animator.translateTransformationGroup = function(transformationGroup, translate, movePlate)
    movePlate = movePlate or false
    if plateHidden and transformationGroup == "item" and movePlate then
      animator.sb_translateTransformationGroup("item", translate)
      animator.sb_translateTransformationGroup("plate", translate)
    else
      animator.sb_translateTransformationGroup(transformationGroup, translate)
    end
  end
  containerCallback()
end

function containerCallback()
  local item = world.containerItemAt(entity.id(), 0)
  if item then
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
    flipImage = (storage.flipped and true) or plateConfig.flipImage or root.itemHasTag(item.name, "sb_plate_flipx")

    if plateImage then
      if type(plateImage) == "boolean" then
        plateImage = item.name
      end
      if type(plateImage) ~= "boolean" and plateImage:sub(0, 1) ~= "/" then
        plateImage = string.format("/objects/generic/sb_plate/%s", plateImage)
      end
      if not plateImage:find(".png") then
        plateImage = plateImage..".png"..(storage.flipped and "?flipx" or "")
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
      image =
        plateImage or item.parameters.inventoryIcon and sb_pathToImage(item.parameters.inventoryIcon, directory) or
        sb_pathToImage(itemConfig.inventoryIcon, directory)
      local points = root.nonEmptyRegion(image) or {0, 0, 16, 16}
      animator.resetTransformationGroup("item")
      animator.resetTransformationGroup("plate")
      if plateOffset then
        if type(plateOffset) == "number" then
          plateOffset = {plateOffset, 0}
        end
        animator.translateTransformationGroup("item", {-plateOffset[1], plateOffset[2]})
      end
      animator.translateTransformationGroup("item", {0, plateImage and 0.25 or 0.133}) --Yeah, yeah, it floats a few subpixels above the plate
      animator.setGlobalTag(
        "item",
        string.format(
          (plateImage and "%s" or "%s?replace;000=0000;151515=0000;020202=0000;45421e=0000").."%s",
          --(plateImage and "%s" or "%s?replace;000=00000019;151515=15151519;020202=02020219;45421e=45421e19").."%s",
          image,
          flipImage and "" or "?flipx" --So funny story, it's kinda already flipped. Well, the item is, anyway, not the plate.
        )
      )
      animator.setGlobalTag("plate", "plate.png"..(storage.flipped and "?flipx" or ""))
      animator.setAnimationState("object", "visible")
      if plateWidth then
        animator.setGlobalTag(
          "plate",
          "/objects/generic/sb_plate/plate.png?scalenearest=1." .. plateWidth .. ";1"..(storage.flipped and "?flipx" or "")
        )
        animator.translateTransformationGroup("plate",{-0.125*(plateWidth/2),0})
        animator.translateTransformationGroup("item",{0.125*(plateWidth/2),0})
        animator.translateTransformationGroup(
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
        )
        --if not root.itemHasTag(item.name,"sb_plate_stay") then --animator.translateTransformationGroup("item",{0.125*plateWidth,0}) end --this is unused, right?
        return
      end
      if itemConfig.category == "drink" or itemConfig.category == "medicine" or plateHidden then
        animator.setAnimationState("object", "hidden")
        --animator.setGlobalTag("plate", plateImage) --Setting the plate image to the item's image helps prevent it from being rendered TOO FAR away from its actual tile position upon reloading the world i hate this bug so fucking much this doesn't completely fix it it still moves a few subpixels for some items i fucking hate it die die die die
        animator.translateTransformationGroup("item", {-0.125 * 2.5, -0.125 * (points[2] == 1 and 3 or 2 + points[2]), true})
        --animator.translateTransformationGroup("plate", {-4.125, -4}) --Fix for stupid plate issue
      else
        animator.translateTransformationGroup("item", {-0.125 * 2, -0.125 * math.min(points[2], points[4])})
      end
    else
      animator.setGlobalTag("item", "perfectlygenericitem.png")
      animator.setGlobalTag("plate", "/objects/generic/sb_plate/plate.png"..(storage.flipped and "?flipx" or ""))
      resetPlate()
      return
    end
  else
    animator.setGlobalTag("item", "")
    animator.setGlobalTag("plate", "plate.png"..(storage.flipped and "?flipx" or ""))
    resetPlate()
  end
end

function resetPlate()
  animator.setAnimationState("object", "visible")
  animator.resetTransformationGroup("item")
  animator.resetTransformationGroup("plate")
  object.setConfigParameter("description", root.itemConfig("sb_plate").config.description) --Better to just grab it as needed instead of storing a ton of copies
end