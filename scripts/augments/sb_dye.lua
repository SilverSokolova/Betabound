local originalApply = apply or function(input) return input end

function apply(input)
  local output = Item.new(input)
  local directivesWouldChange

  if output:instanceValue("sb_dyeable") then
    local dyeDirectives = (config.getParameter("dyeColorIndex", true) and config.getParameter("sb_dyeDirectives")) or config.getParameter("dyeDirectives") or "dyeRemover"

    if type(dyeDirectives) == "table" then
      dyeDirectives = "?" .. paletteSwapDirective(dyeDirectives) 
    end

    --reset dye
    if dyeDirectives == "dyeRemover" then
      local itemData = root.itemConfig(output:descriptor().name).config
      local definition = itemData.definition or itemData.sb_definition

      if definition then
        if type(definition) == "string" then
          definition = {definition}
        end

        for i = 1, #definition do
          itemData.directives = root.assetJson(string.format("/sb_definitions/%s.config", definition[i])).directives
          if itemData.directives then
            break
          end
        end
      end

      local defaultDirectives = itemData.directives or ""
      directivesWouldChange = output:instanceValue("directives") ~= defaultDirectives
      if directivesWouldChange then
        output:setInstanceValue("directives", defaultDirectives)
      end
    else
      --apply dye
      local newDirectives = output:instanceValue("sb_backingDirectives", "")..dyeDirectives..output:instanceValue("sb_extraDirectives", "")
      if dyeDirectives and newDirectives ~= output:instanceValue("directives", "") then
        output:setInstanceValue("directives", newDirectives)
        directivesWouldChange = true
      end
    end
  else
    --not sb_dyeable; run vanilla script
    return originalApply(input)
  end
  return output:descriptor(), config.getParameter("sb_reusable", directivesWouldChange) and 1 or 0
end