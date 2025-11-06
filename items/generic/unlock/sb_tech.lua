require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"
require "/scripts/sb_assetmissing.lua"

function init() swingInit() sb_cursor("power") sb_techType()
  tech = config.getParameter("techModule","")
  suit = root.techType(tech) == "Suit"
end

function swingAction()
  if root.hasTech(tech) then
    if suit and not ownsSuit() then
      unlockSuit()
    elseif not suit and not ownsTech() then
      unlockTech()
    else
      sb_uiMessage("techKnown")
    end
  else
    sb_uiMessage("invalidModSetup")
  end
end

function unlockTech()
  player.makeTechAvailable(tech)
  player.enableTech(tech)
  sb_uiMessage("newTech")
  item.consume(1)
end

function unlockSuit()
  if not conditions(root.techConfig(tech).sb_conditions) then
    sb_uiMessage("invalidModSetup")
    sb.logWarn("[Betabound] Player attempted to learn a tech but its mod conditions have not been met: "..tech)
    return
  end
  if #player.getProperty("sb_bioimplants") == 0 then
    player.setProperty("sb_bioimplants",{tech})
  else
    local suits = player.getProperty("sb_bioimplants")
    suits[#suits+1] = tech
    player.setProperty("sb_bioimplants",suits)
  end
  sb_uiMessage("newTech")
  item.consume(1)
end

function ownsTech() return contains(player.enabledTechs(),tech) end
function ownsSuit() return contains(player.getProperty("sb_bioimplants"),tech) end
function conditions(c) if not c then return true end return sb_itemExists(c) end