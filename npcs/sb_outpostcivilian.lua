local ini = init or function() end
local updat = update or function() end
--We need this since NPC's with quests just stop moving for some reason
--TODO: We should find the reason why (didn't we find the exact file before?) and fix it...?
function init() ini()
  sb_npcType = npc.npcType()
  local quests = {config.getParameter("sb_offeredQuests"),config.getParameter("sb_turnInQuests")}
  if quests[1] then npc.setOfferedQuests(sb_mergeQuests(quests[1],config.getParameter("offeredQuests",{}))) end
  if quests[2] then npc.setTurnInQuests(sb_mergeQuests(quests[2],config.getParameter("turnInQuests",{}))) end --though it'd be cool to just use [1] if [2] is a number, that'd screw over people trying to add quests since it wouldn't add ours
end

function update(...) updat(...)
  if sb_npcType == "outpostfloranfan" then
    if world.universeFlagSet("sb_floranfan1") then
      local base = npc.getItemSlot("chest")
      params = base and base.parameters or {}
      npc.setItemSlot("chestCosmetic",{"coolchest",1,params})
      sb_npcType = 0
    end
  end
end

function sb_mergeQuests(a, b)
  for i = 1, #b do
    a[#a+1] = b[i]
  end
  return a
end