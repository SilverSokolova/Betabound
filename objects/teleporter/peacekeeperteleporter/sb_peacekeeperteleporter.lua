function onInteraction(args)
  world.sendEntityMessage(args.sourceId, "sb_peacekeeperteleporter", {
    interactAction = config.getParameter("interactAction"),
    interactData = config.getParameter("interactData"),
    canBookmark = config.getParameter("canBookmark"),
    teleporterEntityId = entity.id()
  })
end

function onInputNodeChange(args)
  object.setConfigParameter("canBookmark", args.level)
end