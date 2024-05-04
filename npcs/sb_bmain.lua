local ini = init or function() end
local updat = update or function() end

function init() ini()
  sb_npcType = npc.npcType()
  sb_crouching = config.getParameter("sb_crouching")

  --Quest stuff
  --We need this since NPC's with `offeredQuests` in their file just stop moving for some reason
  --TODO: We should find the reason why (didn't we find the exact file before?) and fix it...?
  local quests = {config.getParameter("sb_offeredQuests"), config.getParameter("sb_turnInQuests")}
  if quests[1] then npc.setOfferedQuests(sb_mergeQuests(quests[1], config.getParameter("offeredQuests",{}))) end
  if quests[2] then npc.setTurnInQuests(sb_mergeQuests(quests[2], config.getParameter("turnInQuests",{}))) end

  --Book of Spirits check
  local booth = root.itemConfig("protectorateinfobooth").config
  if booth.npcName and booth.displayTitle then
    require("/npcs/bookofspirits_interact.lua")
  end

  --Stuff for employment beacons
  sb_beamIn = config.getParameter("sb_beamIn") and not status.statusProperty("sb_beamedIn")
  if sb_beamIn then
    status.setStatusProperty("sb_beamedIn", 1)
    status.addEphemeralEffect("beamin")
  end

  --Restore unused Esther dialogue
  if sb_npcType == "esther" then
    sb_interact = interact
    sb_skipNpcSay = false
    npc.sb_say = npc.say

    npc.say = function(...)
      if sb_skipNpcSay then
        sb_skipNpcSay = false
      else
        npc.sb_say(...)
      end
    end

    interact = function(args)
      if sb_skipNpcSay then
        sb_skipNpcSay = false
      end
      if world.universeFlagSet("final_gate_key") and world.entityCurrency(args.sourceId, "sb_questActive:destroyruin") == 1 then
        sayToEntity({
          dialogType = "dialog.arkOpened",
          dialog = nil,
          entity = args.sourceId,
          tags = {}
        })
        sb_skipNpcSay = true
      end
      sb_interact(args)
    end
  end
end

function update(dt) updat(dt)
  --NPC type checks. We need them in update since the player can update quest/universe state while in the target world
  if sb_npcType == "outpostfloranfan" then
    if world.universeFlagSet("sb_floranfan1") then
      local base = npc.getItemSlot("chest")
      params = base and base.parameters or {}
      npc.setItemSlot("chestCosmetic",{"coolchest",1,params})
      sb_npcType = 0
    end
  end

  --NPC crouching
  if sb_crouching then
    if self.primary and root.itemHasTag(self.primary.name, "ranged") then
      mcontroller.controlCrouch()
    end
  end
end

function sb_mergeQuests(a, b)
  for i = 1, #b do
    a[#a+1] = b[i]
  end
  return a
end