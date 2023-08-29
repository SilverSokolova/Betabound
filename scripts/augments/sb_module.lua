require "/scripts/augments/item.lua"
require "/scripts/sb_assetmissing.lua"

function apply(input)
  local output = Item.new(input)
  if output.name == config.getParameter("sb_moduleDont",{}) then return output:descriptor(), 0 end
	if output and config.getParameter("sb_module") then local p = config.getParameter("sb_module") for i, v in pairs(p) do output:setInstanceValue(i,v) end end
	if config.getParameter("sb_moduleFind") then if not string.find(output.name,config.getParameter("sb_moduleFind")) then return output:descriptor(), 0 end end
	if config.getParameter("sb_moduleRequires") then if not root.itemConfig(output.name).config[config.getParameter("sb_moduleRequires")] then return output:descriptor(), 0 end end
	if config.getParameter("sb_moduleRequiresName") then if output.name ~= config.getParameter("sb_moduleRequiresName") then return output:descriptor(), 0 end end
	if config.getParameter("sb_moduleSkipIfParameter") then if output.parameters[config.getParameter("sb_moduleSkipIfParameter",null)]~=null then return output:descriptor(), 0 end end
	if config.getParameter("sb_moduleFullbright") then output:setInstanceValue("inventoryIcon",output.config.inventoryIcon.."?multiply=fffffffe") end --yes, this doesn't check if we've already done it
	if config.getParameter("sb_moduleItemStack") then output.count=output.count+config.getParameter("price",0)+1 end
	if config.getParameter("sb_modulePreserveIcon") then output:setInstanceValue("inventoryIcon",output.config.codexIcon or sb_assetmissing(sb_pathToImage(output.config.inventoryIcon,root.itemConfig(output.name).directory))) end
	if config.getParameter("sb_level") then output:setInstanceValue("level",output:instanceValue("level",0)+config.getParameter("price",0)) end
	if config.getParameter("sb_moduleItemAppend") then output.name = sb_itemExists(output.name..config.getParameter("sb_moduleItemAppend")) and output.name..config.getParameter("sb_moduleItemAppend") or output.name end
	if config.getParameter("sb_moduleLog") then sb.logInfo(sb.printJson(output,1)) end
	if config.getParameter("sb_moduleItem") then output.name=config.getParameter("sb_moduleItem") output:setInstanceValue("itemName",config.getParameter("sb_moduleItem")) end
	if config.getParameter("sb_moduleNoParams") then local c = config.getParameter("sb_moduleForceCount",output.count) output = Item.new(root.createItem(output.name)) output.count = c output:setInstanceValue("itemName",config.getParameter("sb_moduleItem")) end
	if config.getParameter("sb_moduleReset") then local c = output.count output = Item.new(root.createItem(output.name)) output.count = c end
--for i = 1, #p do output:setInstanceValue(p[i][1],p[i][2]) end
--sb.logInfo(sb.print(output))
--sb.logInfo(sb.print(output:descriptor()))
   return output:descriptor(), 0
end