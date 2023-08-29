function init()
	local iconImagePath = config.getParameter("iconImagePath")
	icon = config.getParameter("icon","/interface/bookmarks/icons/barren.png")
	planetName = config.getParameter("planetName","")
	target = config.getParameter("target")
	widget.setImage("imgIcon",string.format(iconImagePath,icon))
	widget.setText("lblPlanetName",planetName)
	widget.setText("name",config.getParameter("name",""))
	widget.setVisible("remove",config.getParameter("editing",false))
end

function ok()
	remove()
	player.removeTeleportBookmark{target={target[1],target[2]},bookmarkName=widget.getText("name"),targetName=planetName,icon=icon}
	player.addTeleportBookmark{target={target[1],target[2]},bookmarkName=widget.getText("name"),targetName=planetName,icon=icon}
	pane.dismiss()
end

function remove()
	player.removeTeleportBookmark{target={target[1],target[2]},bookmarkName=widget.getText("name"),targetName=planetName,icon=icon}
	pane.dismiss()
end

function name() end