--SIP doesn't support custom items (items with custom parameters) despite having a file for them...

sip.callback = sip.callback or {}
local sb_sip_callback_selectItem = sip.callback.selectItem or function() end

function sip.callback.selectItem(); sb_sip_callback_selectItem()
  sip.item = sip.getSelectedItem()
  local config, parameters = {}, {}

  if sip.item then
    config = sip.item.parameters or {}
  else
    return
  end

  if sip.item.parameters ~= nil then
    parameters = root.itemConfig({sip.item.name,1,config}).config
  end

  --Check sip.item.<field> for Shattered Alchemy
  local shortdescription, description = sip.item.shortdescription or parameters.shortdescription, sip.item.description or parameters.description

  if shortdescription then
    widget.setText(sip.widgets.itemName, shortdescription)
  end

  if description then
    widget.setText(sip.widgets.itemDescription, description)
  end

  if sip.item.noPanes then
    sip.showSpecifications({})
  end

  if sip.item.noBlueprint then
    widget.setButtonEnabled(sip.widgets.blueprint, false)
  end

  sip.setItemSlotItem(sip.widgets.itemSlot, sip.item)
end