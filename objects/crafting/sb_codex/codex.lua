--does it need to be storage?? cant it be a variable?
function containerCallback() setCodex() end
function init()
	script.setUpdateDelta(1)
	restoreData()
		message.setHandler("sb_codex_rename",function(_,_,a) a = string.gsub(a,"(%^.-%;)","") if string.gsub(a,"(% )","") == "" then a = root.itemConfig(object.name()).config.shortdescription or "Lectern" end object.setConfigParameter("shortdescription","^orange;"..a.."^reset;") end)
		message.setHandler("sb_codex_restore",function() restoreData() end)

		message.setHandler("sb_codex_add", function(_,_,book,quantity)
			storage.codice = storage.codice or {}
				if not storage.codice[book] then
					storage.codice[book] = {book,quantity}
				else
					storage.codice[book][2] = storage.codice[book][2]+quantity
				end
			setCodex()
		end)
		
		message.setHandler("sb_codex_add2", function(_,_,i,quantity)
			storage.codice = storage.codice or {}
			local codex = "sb_customcodex-"..#i.contentPages..i.shortdescription
				if not storage.codice[codex] then
					storage.codice[codex] = {"sb_customcodex-"..#i.contentPages,quantity,i}
				else
				storage.codice[codex][2] = storage.codice[codex][2]+quantity
				end
			setCodex()
		end)
		
		message.setHandler("sb_codex_add3", function(_,_,i,quantity,name)
			storage.codice = storage.codice or {}
			local codex = name.."-"..(i.sb_recipe and i.sb_recipe["name"] or "")..(i.noteText or #(i.description or root.itemConfig(name).config.description))..(i.shortdescription or root.itemConfig(name).config.shortdescription)
				if not storage.codice[codex] then
					storage.codice[codex] = {name,quantity,i}
				else
				storage.codice[codex][2] = storage.codice[codex][2]+quantity
				end
			setCodex()
		end)
		
--[[		message.setHandler("sb_codex_info", function()
			return {object.name(),entity.position(),entity.uniqueId(),config.getParameter("shortdescription","")}
		end)]]--


		message.setHandler("sb_codex_remove", function(_,_,id)
		storage.codice = storage.codice or {}
		if storage.codice[id] then storage.codice[id] = nil end
		setCodex()
	end)
end

function restoreData()
	local a = config.getParameter("sb_codex")
	if a then storage.codice = a end
end
function setCodex() object.setConfigParameter("sb_codex",storage.codice or {}) end function uninit() setCodex() end function update() setCodex() end