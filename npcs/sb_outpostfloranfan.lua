local updat = update or function() end

function update(...) updat(...)
  if world.universeFlagSet("sb_floranfan1") then
    local base = npc.getItemSlot("chest")
    params = base and base.parameters or {}
    npc.setItemSlot("chestCosmetic",{"coolchest",1,params})
  end
end