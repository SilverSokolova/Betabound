local appl = apply or function(a) return a end
function apply(input)
  local output = Item.new(input)
  local used = false
  if output:instanceValue("sb_dyeable", false) then
    local dyeDirectives = not config.getParameter("dyeColorIndex", true) and config.getParameter("dyeDirectives", {}) or config.getParameter("sb_dyeDirectives") or 0
    if type(dyeDirectives) == "table" then
      dyeDirectives = "?"..paletteSwapDirective(dyeDirectives) 
    end
    if dyeDirectives == 0 then
      local defaultDirectives = root.itemConfig(output:descriptor().name).config.directives or ""
      used = output:instanceValue("directives") ~= defaultDirectives
      if used then
        output:setInstanceValue("directives", defaultDirectives)
      end
      goto finished
    end
    local newDirectives = output:instanceValue("sb_backingDirectives", "")..dyeDirectives..output:instanceValue("sb_extraDirectives", "")
    if dyeDirectives and newDirectives ~= output:instanceValue("directives", "") then
      output:setInstanceValue("directives", newDirectives)
      used = true
    end
  else
    return appl(input)
  end
  ::finished::
  return output:descriptor(), config.getParameter("sb_reusable", used) and 1 or 0
end