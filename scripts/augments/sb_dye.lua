require "/scripts/augments/item.lua"
local appl = apply or function(a) return a end
function apply(input)
  local output = Item.new(input)
  local used = false
  if output:instanceValue("sb_dyeable",false) then
    local dyeDirectives = not config.getParameter("dyeColorIndex",true) and config.getParameter("dyeDirectives",{}) or config.getParameter("sb_dyeDirectives") or 0
    if type(dyeDirectives) == "table" then dyeDirectives = "?"..paletteSwapDirective(dyeDirectives) end
    if dyeDirectives == 0 then
      local defaultDirectives = root.itemConfig(output:descriptor().name).config.directives or ""
      used = output:instanceValue("directives")~=defaultDirectives
      output:setInstanceValue("directives",defaultDirectives) goto a end
      if dyeDirectives and output:instanceValue("sb_backingDirectives","")..dyeDirectives..output:instanceValue("sb_extraDirectives","") ~= output:instanceValue("directives","") then
        output:setInstanceValue("directives", output:instanceValue("sb_backingDirectives","")..dyeDirectives..output:instanceValue("sb_extraDirectives",""))
        local inventoryIcon = output:instanceValue("inventoryIcon")
        used = true
      end else return appl(input) end
  ::a::
  return output:descriptor(), config.getParameter("sb_reusable",used) and 1 or 0
end