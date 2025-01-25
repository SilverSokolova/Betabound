function init()
  local questData = root.questConfig(quest.questId())
  if questData.newId then
    local newQuest = {}
    local questId = questData.newId
    newQuest.parameters = quest.parameters() or {}
    newQuest.questId = questId
    newQuest.templateId = questId
    player.startQuest(newQuest)
  end
  quest.fail()
end