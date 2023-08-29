require "/scripts/augments/item.lua"

function apply(input)
  local output = Item.new(input)
  local amount = 0
  if output.name ~= "sb_itembox" then
    parcel = {}
    parcel["items"] = {output:descriptor()}
    output.name = "sb_itembox"
    output.count = 1
    output.parameters = parcel
    amount = 1
  end
  return output:descriptor(), amount
end