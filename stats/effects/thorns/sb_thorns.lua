local ini = init or function() end
function init() ini()
  local fade = config.getParameter("sb_fadeColor")
  local border = config.getParameter("border")
  local directives = ""
  if fade then directives = directives.."?fade="..fade..";0.1" end
  if border then directives = directives.."?border="..border end
  if directives then effect.setParentDirectives(directives) end --Don't undo directives set in thorns.lua
end