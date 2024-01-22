require "/scripts/sb_assetmissing.lua"

function swapModes2()
	for i = 1, #modeWidgets[1] do widget.setVisible(modeWidgets[1][i], reading) end
	for i = 1, #modeWidgets[2] do widget.setVisible(modeWidgets[2][i], not reading) end
	widget.setVisible("renameBox",false)
	widget.setVisible("longPageText",long) if long then long = false
	  widget.setVisible("prevButton",false)
	  widget.setVisible("nextButton",false)
	end
end

function prepareBook()
	long = false
	local data = widget.getData(string.format("%s.%s", bookList, widget.getListSelected(bookList)))
	if #data[2] > 18 and data[2]:sub(0,5) == "shpd_" and sb_itemExists("shpd_page_alchemy_1") then
		local configData = root.assetJson("/interface/scripted/shpd_page/pagegui.config")
		if data[2]:sub(6,16) ~= "alchemybook" then configData.page = data[2]:sub(19,19) end
		player.interact("ScriptPane",configData) return
	end
	if type(data[1]) == "table" then
			pageContents = data[1] custom = true
		else
			custom = false
			local valid = pcall(function() root.assetJson(data[1]..".codex") end)
			if valid then
				pageContents = root.assetJson(data[1]..".codex")
				if pageContents.longContentPages then long = true pageContents = pageContents.longContentPages else pageContents = pageContents.contentPages end
			else
				pageContents = {data[1]}
		end
		end
	if data[4] and data[5] then
		player.interact(data[4],data[5]) return
	elseif long or #pageContents > 0 then readPage() else end
	swapModes()
end

function init()
	assetmissing = "/interface/sb_tooltips/assetmissing.png"
	entityId = pane.containerEntityId()
	i1 = nil
	reading, renaming, custom, long, warned = false
	promise = {nil,nil,nil,nil}
	widget.registerMemberCallback("modeStack.bookList", "prepareBook", prepareBook)
	selectedBook, pageContents = {}
	currentPage = 1
	modeWidgets = config.getParameter("modeWidgets")
	bookList = "modeStack.bookList"
	populateList()
end

function eraseEntry()
	local preparedBook = widget.getListSelected(bookList) or nil
	local books = world.getObjectParameter(entityId,"sb_codex") or {}
	if preparedBook then
	if selectedBook == {} then populateList() return end
	local data = widget.getData(string.format("%s.%s", bookList, widget.getListSelected(bookList)))
	preparedBook = data[2]
	if preparedBook == "sb_customcodex" then data[4] = preparedBook preparedBook = preparedBook.."-"..#data[1]..data[3] end
	if not books[preparedBook] then populateList() return end
	selectedBook = {books[preparedBook][1],books[preparedBook][2]}
	if data[4] == "sb_customcodex" then world.spawnItem({name=data[4],count=selectedBook[2],parameters=books[preparedBook][3]},world.entityPosition(entityId)) selectedBook[1] = preparedBook elseif
	#data == 3 or #data == 5 then world.spawnItem({name=selectedBook[1],count=selectedBook[2],parameters=books[preparedBook][3]},world.entityPosition(entityId)) else
	world.spawnItem({name=selectedBook[1],count=selectedBook[2],parameters=selectedBook[3]},world.entityPosition(entityId)) end
	promise[4] = world.sendEntityMessage(entityId,"sb_codex_remove",preparedBook)
	populateList()
	end
end
--[[
function eraseEntry()
	local preparedBook = widget.getListSelected(bookList) or nil
	local books = world.getObjectParameter(entityId,"sb_codex") or {}
	if preparedBook then
	if selectedBook == {} then populateList() return end
	local data = widget.getData(string.format("%s.%s", bookList, widget.getListSelected(bookList)))
	preparedBook = data[2]
	if preparedBook == "sb_customcodex" then data[4] = preparedBook preparedBook = preparedBook.."-"..#data[1]..data[3] end
	if not books[preparedBook] then populateList() return end
	selectedBook = {books[preparedBook][1],books[preparedBook][2]}
	if data[4] == "sb_customcodex" then world.containerAddItems(entityId,{name=data[4],count=selectedBook[2],parameters=books[preparedBook][3]}) selectedBook[1] = preparedBook elseif
	#data == 3 or #data == 5 then world.containerAddItems(entityId,{name=selectedBook[1],count=selectedBook[2],parameters=books[preparedBook][3]}) else
	world.containerAddItems(entityId,{name=selectedBook[1],count=selectedBook[2],parameters=selectedBook[3]}) end
	promise[4] = world.sendEntityMessage(entityId, "sb_codex_remove",preparedBook)
	populateList()
	end
end
]]

function warning(s,d) if not warned then d=d or "" sb.logError(s..d) warned=true end end
function resetParameter(a,b,c) if a.b == root.itemConfig(c).config.b then a.b = nil end end

function populateList()
	widget.clearListItems(bookList)
	local books = world.getObjectParameter(entityId,"sb_codex") or {}
	local newBooks = {}
	for i, v in pairs(books) do
		if sb_itemExists(i) then if books[i][2] > 0 and root.itemType(i) == "codex" then
			local ni = root.itemConfig({name=i})
			newBooks[#newBooks+1] = {
				name = ni.config.shortdescription or "Unnamed Item",
				data = {ni.directory..i:sub(1,string.len(i)-6),i},
				icon =  sb_assetmissing(ni.config.codexIcon,assetmissing)
			}
		else warning("Invalid Codex: ",i) end else
		if isCodex2(i) then if books[i][2] > 0 then
			local ni = books[i][3]
			newBooks[#newBooks+1] = {
				name = ni.shortdescription or "Unnamed Item",
				data = {ni.contentPages or {{}},"sb_customcodex",ni.shortdescription or ""},
				icon = sb_assetmissing(sb_pathToImage(ni.inventoryIcon or root.itemConfig(books[i][3]).config.inventoryIcon,"/items/active/starbound/codex/"),assetmissing)
			}
		else warning("Custom Codex error.") end else
			if not sb_itemExists(books[i][1]) then warning("No such item: ",books[i][1]) else
			local ni = books[i][3]
			newBooks[#newBooks+1] = {
				name = ni.shortdescription or root.itemConfig(books[i][1]).config.shortdescription or "Unnamed Item",
				data = {(ni.noteText or ni.description or root.itemConfig(books[i][1]).config.description),i,(ni.shortdescription or root.itemConfig(books[i][1]).config.shortdescription),ni.interactAction,ni.interactData},
				icon = sb_assetmissing(sb_pathToImage(ni.inventoryIcon or root.itemConfig(books[i][1]).config.inventoryIcon, root.itemConfig(books[i][1]).directory),assetmissing)
			}
		end end
		end
	end
	table.sort(newBooks, function(a,b) return a.name < b.name end)
	for i = 1, #newBooks do
		local listItem = widget.addListItem(bookList)
		local listedItem = bookList.."."..listItem
		widget.setText(listedItem..".bookName",newBooks[i].name)
		widget.setData(listedItem,newBooks[i].data)
		widget.setImage(listedItem..".newIcon",newBooks[i].icon)
	end
end


function prepareBooking(i)
	if isCodex(i) and registerNewCodex(i) then return elseif
	isCustomCodex(i) and registerNewCustomCodex(i) then return elseif
	(root.itemHasTag(i.name, "sb_copybook") or root.itemHasTag(i.name, "sb_lectern") or root.itemConfig(i).config.category == "codex" or (i.parameters.interactData and i.parameters.interactAction)) and not isCodex(i) and i.name ~= "sb_customcodex" and registerNewPage(i) then end
end


function registerNewCodex(i)
	local l=i.count
	i=i.name
	if sb_itemExists(i) then
			local books = world.getObjectParameter(entityId,"sb_codex") or {}
			local ni = root.itemConfig({name=i})
			if books[ni.name] then
			local listItem = widget.addListItem(bookList)
			widget.setText(bookList.."."..listItem..".bookName",ni.config.shortdescription)
			widget.setData(bookList.."."..listItem,{ni.directory..i:sub(1,string.len(i)-6),i}) end
			promise[1] = world.sendEntityMessage(entityId, "sb_codex_add",i,l)
			world.containerTakeAt(entityId, 0)
		else sb.logError("Invalid Codex: "..i) end
			populateList()
end

function registerNewCustomCodex(p)
	i = p.parameters
	local books = world.getObjectParameter(entityId,"sb_codex") or {}
		if not books["sb_customcodex-"..#i.contentPages..i.shortdescription..i.description] then
			local listItem = widget.addListItem(bookList)
			widget.setText(bookList.."."..listItem..".bookName",i.shortdescription)
			widget.setData(bookList.."."..listItem,{i.contentPages,"sb_customcodex"})
			promise[2] = world.sendEntityMessage(entityId, "sb_codex_add2",i,p.count)
			world.containerTakeAt(entityId, 0) end
			populateList()
end

function registerNewPage(p)
	i = p.parameters
	local books = world.getObjectParameter(entityId,"sb_codex") or {}
		if not books[(p.name..(i.sb_recipe and i.sb_recipe["name"] or ""))..#(i.description or root.itemConfig(p.name).config.description)..(i.shortdescription or root.itemConfig(p.name).config.shortdescription)] then
			local listItem = widget.addListItem(bookList)
			widget.setText(bookList.."."..listItem..".bookName",(i.shortdescription or root.itemConfig(p.name).config.shortdescription))
			widget.setData(bookList.."."..listItem,{(i.description or root.itemConfig(p.name).config.description),p.name})
			promise[3] = world.sendEntityMessage(entityId, "sb_codex_add3",i,p.count,p.name)
			world.containerTakeAt(entityId, 0) end
			populateList()
end

function update(dt)
	for i = 1, 4 do if promise[i] and promise[i]:finished() then promise[i]=nil populateList() end end
	addToLibrary()
	widget.setButtonEnabled("takeButton",widget.getListSelected(bookList)~=nil)
--	widget.setButtonEnabled("addtoButton",#widget.itemGridItems("itemGrid")>0)
	--upd=upd+1
	--if upd>=60 then populateList() upd=0 end
end

function readPage()
	widget.setText("pageText","")
	if not long then
	widget.setText("pageNum",string.format(config.getParameter("pageText","%s/%s"),currentPage,#pageContents)) widget.setButtonEnabled("nextButton",currentPage<#pageContents) widget.setButtonEnabled("prevButton",currentPage>1)
	if not custom then widget.setText("pageText",pageContents[currentPage]) else
	local newContents = ""
	for foo = 1, #pageContents[currentPage] do
	newContents = newContents..pageContents[currentPage][foo].."\n"
	end
	widget.setText("pageText",newContents)
	end
	else
	widget.setText("longPageText.pageText",pageContents[1])
	widget.setText("pageNum","")
	end
end

function toggleRename() renaming = not renaming widget.setVisible("renameBox",renaming) end
function renameBox() world.sendEntityMessage(entityId, "sb_codex_rename",string.gsub(widget.getText("renameBox"), "(%^.-%;)", "")) end
function prevP() if currentPage > 1 then currentPage = currentPage - 1 readPage() end end
function nextP() if currentPage < #pageContents then currentPage = currentPage + 1 readPage() end end
function swapModes() reading = not reading swapModes2() currentPage = 1 end
function takeFromLibrary() eraseEntry() end
function isCodex(i) return (string.len(i.name) > 6 and i.name:sub(-6) == "-codex") end
function isCodex2(i) return i:sub(1,14) == "sb_customcodex" end
function isCustomCodex(i) return (i.name == "sb_customcodex" and i.parameters.rarity == "uncommon") end
--function isABC(i) return (i.style or i.category=="Book" or i.createdby=="Kate, Loki, and Degrannon" or i.alignment or i.bookDirectives) end
function addToLibrary() i1 = widget.itemGridItems("itemGrid")[1] if i1 ~= nil then prepareBooking(i1) end end