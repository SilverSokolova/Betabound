require "/scripts/sb_assetmissing.lua"

function selectDestination() widget.setButtonEnabled("btnTeleport",true) end

function init()
	if not config.getParameter("modded") then
		local mod = root.assetJson("/interface/windowconfig/teleportdialog.config:paneLayout.background")

		if mod.fileBody == "/interface/v6warping/warpbody.png" then
			local interactData = config.getParameter("")
			interactData.gui.background.fileBody = mod.fileBody
			interactData.gui.close.position[2] = interactData.gui.close.position[2]+98
			interactData.gui.bookmarkList.rect[2] = interactData.gui.bookmarkList.rect[2]+22
			interactData.gui.bookmarkList.rect[4] = interactData.gui.bookmarkList.rect[4]+93
			interactData.gui.btnTeleport.position[2] = interactData.gui.btnTeleport.position[2]+13
			interactData.gui.btnBookmark.position[2] = interactData.gui.btnBookmark.position[2]+13
			interactData.modded = true
			player.interact("ScriptPane",interactData,player.id())
			pane.dismiss()
		end

		if mod.fileBody == "/interface/warping/pat/warpbody.png" then
			local interactData = config.getParameter("")
			interactData.gui.background = mod
			mod = root.assetJson("/interface/windowconfig/teleportdialog.config:paneLayout")
			interactData.gui.close.position = mod.close.position
			interactData.gui.bookmarkList.rect[2] = interactData.gui.bookmarkList.rect[2] + 23
			interactData.gui.bookmarkList.rect[3] = mod.bookmarkList.rect[3]
			interactData.gui.bookmarkList.rect[4] = mod.bookmarkList.rect[4] + 0
			interactData.gui.btnTeleport.position[1] = interactData.gui.btnTeleport.position[1]+87
			interactData.gui.btnBookmark.position[1] = interactData.gui.btnBookmark.position[1]+87
		--	interactData.gui.btnTeleport.position[2] = interactData.gui.btnTeleport.position[2]+13
		--	interactData.gui.btnBookmark.position[2] = interactData.gui.btnBookmark.position[2]+13
			interactData.gui.bookmarkList.children.bookmarkItemList.columns = 2
			interactData.gui.bookmarkList.children.bookmarkItemList.schema.spacing[1] = 2
			interactData.btnTeleportAltPos = interactData.gui.btnTeleport.position[1] - 34.5
			interactData.modded = true
			player.interact("ScriptPane",interactData,player.id())
			pane.dismiss()
		end
	end

	local worldId = player.worldId()
	iconImagePath = config.getParameter("iconImagePath")
	coordinates = worldId:sub(string.find(worldId,":"),string.len(worldId))
	uniqueId = config.getParameter("uniqueId")
	canBookmark = config.getParameter("canBookmark")
	canReturn = config.getParameter("canReturn")
	list = "bookmarkList.bookmarkItemList"

	if canReturn then
		widget.setButtonEnabled("btnBookmark",true)
		widget.setVisible("btnBookmark",true)
		widget.setPosition("btnTeleport",{config.getParameter("btnTeleportAltPos",34.5),widget.getPosition("btnTeleport")[2]})
	end

	if canBookmark or canReturn then
	--	if world.terrestrial() then sb.logInfo(sb.printJson(celestial.visitableParameters(coordinates),1)) end
		icon = world.terrestrial() and celestial.visitableParameters(coordinates).primaryBiome or nonTerrestrialType(worldId) or "teleporter"
		if world.type() == "asteroids" then icon = celestial.visitableParameters(coordinates).asteroidBiome end
		icon = getIcon(icon) and icon or "default"
		name = (world.terrestrial() or world.type() == "asteroids") and celestial.planetName(coordinates) or name or ""
	end

	if canBookmark and uniqueId then
		local bookmarked = false
		local bookmarks = player.teleportBookmarks() --Documentation lied or is outdated

		for _, bookmark in pairs(bookmarks) do if bookmark.target[2] == uniqueId then bookmarked = true break end end

		if not bookmarked then --player.addTeleportBookmark{target={player.worldId(),uniqueId},bookmarkName="",targetName="",icon="default"} then
		--	player.removeTeleportBookmark{target={player.worldId(),uniqueId},bookmarkName="",targetName="",icon="default"}
			local interactData = root.assetJson("/interface/windowconfig/sb_editbookmark.config")
			interactData.icon = icon
			interactData.planetName = name
			interactData.target = {player.worldId(),uniqueId}
			player.interact("ScriptPane",interactData,player.id())
			pane.dismiss()
		end
	end

	widget.registerMemberCallback("bookmarkList.bookmarkItemList","editBookmark",editBookmark)
	populateBookmarkItemList()
end

function populateBookmarkItemList()
	widget.clearListItems(list)
	local destinations = config.getParameter("destinations")
	if destinations then
		local j = #destinations
		for i = 1, j do
			if not destinations[i].conditions or config.getParameter(destinations[i].conditions) then
				local listItem = widget.addListItem(list)
				widget.setText(string.format("%s.%s.name", list, listItem), destinations[i].name)
				widget.setText(string.format("%s.%s.planetName", list, listItem), destinations[i].planetName)
				widget.setData(string.format("%s.%s", list, listItem), {destinations[i].warpAction,false})
				widget.setImage(string.format("%s.%s.icon", list, listItem), sb_assetmissing("/interface/bookmarks/icons/"..destinations[i].icon..".png","/interface/bookmarks/icons/default.png"))
				widget.setButtonEnabled(string.format("%s.%s.editButton", list, listItem), false)
				widget.setVisible(string.format("%s.%s.editButton", list, listItem), false)
			end
		end
	end

	local bookmarks = player.teleportBookmarks()
	table.sort(bookmarks,function(a,b) return a.bookmarkName < b.bookmarkName end)
	
	for _, bookmark in pairs(bookmarks) do
		local listItem = widget.addListItem(list)
		widget.setText(string.format("%s.%s.name", list, listItem), bookmark.bookmarkName)
		widget.setText(string.format("%s.%s.planetName", list, listItem), bookmark.targetName)
		widget.setData(string.format("%s.%s", list, listItem), {bookmark.target[1],bookmark.target[2],bookmark.icon,bookmark.bookmarkName,bookmark.targetName})
		widget.setImage(string.format("%s.%s.icon", list, listItem), sb_assetmissing("/interface/bookmarks/icons/"..bookmark.icon..".png","/interface/bookmarks/icons/default.png"))
	end
end


function teleport()
	local destination = widget.getListSelected(list)
	if destination then
		local data = widget.getData(string.format("%s.%s",list,destination))
		if data[2] then
			player.warp(data[1].."="..(type(data[2])=="string" and data[2] or parseDecimalCoordinate(data[2])),"beam")
		elseif data[1]=="sb_party" then party()
		else player.warp(data[1],"beam")
		end
		pane.dismiss()
	end
end

function editBookmark()
	local destination = widget.getListSelected(list)
	if destination then
		local data = widget.getData(string.format("%s.%s",list,destination))
		local interactData = root.assetJson("/interface/windowconfig/sb_editbookmark.config")
		interactData.icon = data[3]
		--interactData.name = widget.getText(string.format("%s.%s.planetName",list,destination))
		interactData.name = data[4]
		interactData.planetName = data[5]
		interactData.target = {data[1],data[2]}
		interactData.editing = true
		player.interact("ScriptPane",interactData,player.id())
		pane.dismiss()
	end
end

function party()
	player.interact("openTeleportDialog",{canBookmark=false,includePlayerBookmarks=false,includePartyMembers=true},player.id())
	pane.dismiss()
end

function bookmark()
	if string.find(icon,"//") or string.sub(icon,1,1) == "/" then icon = "default" end
	player.addTeleportBookmark{target={player.worldId(),uniqueId or world.entityPosition(player.id())},bookmarkName=name,targetName=name,icon=icon}
end

function getIcon(a)
	return sb_assetmissing(string.format(iconImagePath,a),false) and a or false
end

function nonTerrestrialType(a)
	if string.find(a,"ClientShipWorld:") then name = "Player Ship" return "ship" end
	local _, n = string.gsub(a,":","")
	local object = false
	if n > 1 then
		local b = string.find(a,":")+1
		object = string.sub(a,b,string.find(a,":",b)-1)
	elseif n > 0 then
		object = string.sub(a,string.find(a,":")+1)
	end
	if object then
		local systemObjects = root.assetJson("/system_objects.config")
		if systemObjects[object] then if systemObjects[object].parameters then
			name = systemObjects[object].parameters.displayName or "?"			
		end end
	end
	return object
end

function parseDecimalCoordinate(pos)
	return string.format("%s.%s",math.floor(pos[1],1),math.floor(pos[2]-2,1))
end