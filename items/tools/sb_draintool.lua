function init()
  player = math.betabound_player
  giveItem = player and function(c) player.giveItem({name=c[1],count=1,parameters=c[2]}) end or function(c) world.spawnItem(c[1],fireableItem.ownerAimPosition(),1,c[2]) end
end

function update(_,a)
  if a == "alt" then
    local b = world.material(fireableItem.ownerAimPosition(),"foreground")
      if b and not world.isTileProtected(fireableItem.ownerAimPosition()) and
      world.materialHueShift(fireableItem.ownerAimPosition(),"foreground") ~= 0 then
      giveItem({"sb_paint",{sb_paintData={root.materialConfig(b).config.itemDrop,math.floor(world.materialHueShift(fireableItem.ownerAimPosition(),"foreground") * 360/255)+1}}})
      world.setMaterialColor(fireableItem.ownerAimPosition(),"foreground",0)
    end
  end
end