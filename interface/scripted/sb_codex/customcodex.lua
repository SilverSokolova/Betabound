function init()
  pageContents = config.getParameter("contentPages", {{""}})
  local customData = config.getParameter("customData")
  baseData = root.itemConfig("sb_customcodex").config
  signedData = {customData[1] ~= baseData.shortdescription and customData[1] or baseData.shortdescriptionBlank, customData[2] ~= baseData.description and customData[2] or baseData.descriptionBlank}
--  signedData = {"Untitled Book","An untitled book."}
--  if customData[1] ~= baseData.shortdescription then signedData[1] = customData[1] widget.setText("renameBox1",signedData[1]) end
--  if customData[2] ~= (baseData.description or "An untitled book.") then signedData[2] = customData[2] widget.setText("renameBox2",signedData[2]) widget.setText("renameBox2label",signedData[2]) end

  widget.setText("renameBox1",signedData[1])
  widget.setText("renameBox2",signedData[2])
  widget.setText("renameBox2label",signedData[2])

  currentPage = 1
  widget.setText("pageNum","P. "..currentPage.." of "..#pageContents)
  readPage()
  pane.setTitle("^orange;"..signedData[1],config.getParameter("reading"))
  renaming = false
  modeWidgets = {{"pageNum","nextButton","prevButton"},{"renameBox1","renameBox2","renameBox2label"}}
  captions = config.getParameter("captions")
  local path = "/interface/scripted/sb_codex/"
  buttonImages = {}
  buttonImages[true] = {base=path.."renameselected.png",hover=path.."renameselected-hover.png",pressed=path.."renameselected-hover.png?brightness=60",disabledImage=path.."renameselected.png?brightness=-30"}
  buttonImages[false] = {base=path.."backbutton2.png",hover=path.."backbutton2-hover.png",pressed=path.."backbutton2-hover.png?brightness=60",disabledImage=path.."backbutton2.png?brightness=-30"}
  changeIcon()
end

function uninit()
  signedData = {string.gsub(signedData[1],"(%^.-%;)",""),string.gsub(signedData[2], "(%^.-%;)", "")}
  if string.len(string.gsub(signedData[1],"(% )","")) == 0 then signedData[1] = baseData.shortdescriptionBlank end
  if string.len(string.gsub(signedData[2],"(% )","")) == 0 then signedData[2] = baseData.descriptionBlank end
  combinePageLines()
  miscData = miscData or config.getParameter("miscData")
--  if pageContents == root.itemConfig("sb_customcodex").pageContents then player.giveItem("sb_customcodex") else
player.giveItem({name="sb_customcodex",count=1,parameters={rarity="uncommon",inventoryIcon=miscData[2],tooltipFields=miscData[1],shortdescription=signedData[1],description=signedData[2],codexIcon=miscData[3],contentPages=pageContents}}) --end
end

function readPage()
widget.setButtonEnabled("prevButton",currentPage>1)
widget.setText("pageNum",string.format(config.getParameter("pageFormat","%s/%s"),currentPage,#pageContents))--"P. "..currentPage.." of "..#pageContents)
for i = 1, #pageContents[currentPage] do
widget.setText("PTB"..i, ""..pageContents[currentPage][i] or "")
end
for i = #pageContents[currentPage]+1, 18 do
widget.setText("PTB"..i,"")
end
end

function combinePageLines()
local a = widget.getText local b = "PTB" local c = {} local d = 0
for i = 1, 18 do c[i] = a(b..i)
d=d+string.len(c[i]) end
pageContents[currentPage] = c
if d > 0 then return c else return false end
end

function combineAllPageLines()
local a = 0 local b = pageContents
for i = 1, #b do
for bar = 1, #b[i] do
a=a+string.len(string.gsub(b[i][bar],"(% )",""))
if a > 0 then return true end
end end
return false
end

function linejump()
if widget.hasFocus("PTB18") then widget.focus("PTB1") return end
for i = 1, 17 do
if widget.hasFocus("PTB"..i) then widget.focus("PTB"..i+1) break end
end
end

function changeIcon(i)
  if i then
    local item = player.swapSlotItem() and root.itemConfig(player.swapSlotItem()).config
    if not item then return end
    if item.codexIcon then
      miscData = miscData or config.getParameter("miscData")
      miscData[2] = player.swapSlotItem().parameters.codexIcon or item.codexIcon
      miscData[3] = miscData[2]
      if item.itemName == "sb_customcodex" then
	widget.setItemSlotItem("iconSlot",{"sb_customcodex",1,sb.jsonMerge(config.getParameter("iconTooltip"),{inventoryIcon=miscData[3]})})
      else
	widget.setItemSlotItem("iconSlot",{item.itemName,1,config.getParameter("iconTooltip")})
      end
    end
  else
      miscData = miscData or config.getParameter("miscData")
      widget.setItemSlotItem("iconSlot",{"sb_customcodex",1,sb.jsonMerge(config.getParameter("iconTooltip"),{inventoryIcon=miscData[3]})})
  end
end

function prevP() if currentPage > 1 then combinePageLines() currentPage = currentPage - 1 readPage() end end
function nextP() if currentPage >= #pageContents then pageContents[#pageContents+1] = {"^;"} end combinePageLines() currentPage = currentPage + 1 readPage() end
function toggleRename()
for i = 1, 18 do widget.setVisible("PTB"..i, renaming) end
for i = 1, #modeWidgets[1] do widget.setVisible(modeWidgets[1][i], renaming) end
for i = 1, #modeWidgets[2] do widget.setVisible(modeWidgets[2][i], not renaming) end
widget.setButtonImages("renameButton", buttonImages[renaming])
widget.setText("renameButton",captions[renaming and 1 or 2])
renaming = not renaming
end
function renameBox1() signedData[1] = widget.getText("renameBox1") pane.setTitle("^orange;"..signedData[1],config.getParameter("reading")) end
function renameBox2() signedData[2] = widget.getText("renameBox2") widget.setText("renameBox2label",signedData[2]) end