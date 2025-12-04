require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/activeitem/sb_swing.lua"
require "/scripts/player/sb_hasTech.lua"
require "/scripts/sb_uimessage.lua"
require "/scripts/sb_assetmissing.lua"

function init(); swingInit(); sb_cursor("power"); sb_techType()
  tech = config.getParameter("techModule", "")
  suit = root.techType(tech) == "Suit"
end

function swingAction()
  if root.hasTech(tech) then
    if not sb_isTechEnabled(tech) then --Allow using unlock items to bypass paying tech cards (TODO: oops, tech card inflation!)
      if suit then
        world.sendEntityMessage(entity.id(), "sb_suitTech:enable", tech)
      else
        player.makeTechAvailable(tech)
        player.enableTech(tech)
      end

      sb_uiMessage("newTech")
      item.consume(1)
    else
      sb_uiMessage("techKnown")
    end
  else
    sb_uiMessage("invalidModSetup")
  end
end