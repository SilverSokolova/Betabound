function init()
  local quests = config.getParameter("sb_quests")

  for k, v in pairs(quests) do
    if world.type() == k then --Wanna add quests that work on all planets? Add that here, before world.type!
      if v.offeredQuests then
        sb_addQuests(v.offeredQuests, config.getParameter("offeredQuests", {}))
      end

      if v.turnInQuests then
        sb_addQuests(v.turnInQuests, config.getParameter("turnInQuests", {}))
      end
    end
  end
end

function sb_addQuests(a, b)
  for i = 1, #b do
    a[#a + 1] = b[i]
  end

  object.setInteractive(true)
  object.setOfferedQuests(a)
  return a
end