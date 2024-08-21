require("/scripts/sb_assetmissing.lua")
function init()
  local defaultItemPrice = 50
  local BPF = root.assetJson("/items/defaultParameters.config:blueprintPriceFactor")
  data = root.assetJson(config.getParameter("interactData"))
  data.gui.categories.buttons = {}
  local button = config.getParameter("categoryButton")
  data.recipes = {}
  local groups = {} --groups["all"] = {}
  local items = config.getParameter("offeredItems")
  local buyFactor = config.getParameter("buyFactor",3)
  local append = config.getParameter("append","-recipe")
  for k, v in pairs(items) do
    groups[#groups+1] = k
    for i = 1, #v do
      local j = v[i]..append
      if sb_itemExists(j) then
        local price = root.itemConfig(j).config.price or 0
        data.recipes[#data.recipes+1] = {
          input = {
            "sb_blankblueprint",
            {"money",math.floor((price ~= 0 and price or defaultItemPrice)*BPF*buyFactor)}
          },
          output = j,
          groups = {k}
        }
      else
        sb.logInfo("Betabound: No such item for Research Station: "..j)
      end
    end
  end
  local spacing, offset = #groups < 9 and 20 or 18, 0
  table.sort(groups, function(a, b) return a < b end)
  for i = 1, #groups do
    local b = button
    b.position[1] = b.position[1]+offset --I wanted to move it by `offset * groups` but I can't seem to get it to work wtf
    offset = offset + spacing
    b.baseImage = string.format(b.baseImage,groups[i])
    b.baseImageChecked = string.format(b.baseImageChecked,groups[i])
    b.data = groups[i]
    data.gui.categories.buttons[i] = b
    button = config.getParameter("categoryButton") --TODO: change this to use copy from util
  end
end

function onInteraction(args)
  return {config.getParameter("interactAction"),data}
end