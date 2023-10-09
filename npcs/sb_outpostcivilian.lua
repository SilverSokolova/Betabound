local ini = init or function() end
--We need this since NPC's with quests just stop moving for some reason
--TODO: We should find the reason why (didn't we find the exact file before?) and fix it. Setting quests like this will undo other mod's quests
function init() ini()
  local quests = {config.getParameter("sb_offeredQuests"),config.getParameter("sb_turnInQuests")}
  if quests[1] then npc.setOfferedQuests(quests[1]) end
  if quests[2] then npc.setTurnInQuests(quests[2]) end --though it'd be cool to just use [1] if [2] is a number, that'd screw over people trying to add quests since it wouldn't add ours
end