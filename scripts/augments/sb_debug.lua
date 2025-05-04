require "/scripts/augments/item.lua"
require "/scripts/sb_assetmissing.lua"

sb_functions = {}

sb_functions["log"] = function(output)
  sb.logInfo(sb.printJson(output, 1))
  return output
end

sb_functions["reset"] = function(output)
  return Item.new(root.createItem({name = output.name, count = output.count}))
end

function apply(input)
  output = Item.new(input)
  local sb_debug = config.getParameter("sb_debug", {})

  if sb_debug["functionToRun"] then
    output = sb_functions[sb_debug["functionToRun"]](output)
  end

  if sb_debug["newParameters"] then
    for k, v in pairs(sb_debug["newParameters"]) do output:setInstanceValue(k, v) end
  end

  return output:descriptor(), 0
end