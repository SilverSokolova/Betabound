require "/scripts/sb_uimessage.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/sb_cursors.lua"
require "/scripts/sb_assetmissing.lua"

function init() sb_techType()
  if not config.getParameter("version") and not player.getProperty("betabound",{}).gotUMR then
    player.giveItem(root.assetJson("/scripts/sb_versioning/upgrademoduleremover.json"))
    player.setProperty("betabound",sb.jsonMerge(player.getProperty("betabound",{}),{gotUMR=true}))
  end
  script.setUpdateDelta(20)
  activeItem.setHoldingItem(false)
  sb_cursor("power")
  tech = config.getParameter("techModules")
  durability = config.getParameter("durability",5)
end

function activate() if player.isAdmin() or config.getParameter("durabilityHit",5) >= durability then lockinTech() end end

function update(dt)
  local d = config.getParameter("durabilityHit",5)
  if d < durability then activeItem.setInstanceValue("durabilityHit",d+1) end
end

function lockinTech()
  if root.hasTech(tech[1]) and root.hasTech(tech[2]) then
    local tec = root.techType(tech[1]) ~= "Suit" and player.equippedTech(root.techConfig(tech[1]).type) or player.getProperty("sb_bioimplant")
    if tec ~= nil then
      if ownsTech() then
        suit = root.techType(tec) == "Suit" and true
        if (tech[1] == tec) or (tech[2] == tec) then
          activeItem.setInstanceValue("durabilityHit",0)
          local e = {tech[2],tech[1]}
          activeItem.setInstanceValue("techModules",e)
          local f = config.getParameter("tooltipFields",nil)
          if f then
            e = {objectBImage = f.objectCImage, objectCImage = f.objectBImage,objectImage=""} 
            activeItem.setInstanceValue("tooltipFields",e)
          end
          if not suit then
            player.equipTech(tech[2])
          else
            world.sendEntityMessage(player.id(),"sb_implant",tech[2]) end
            animator.playSound("success")
          else
            sb_uiMessage("techNotBinded")
          end
        else
          sb_uiMessage("techNotKnown")
        end
      else
        sb_uiMessage("techNotBinded")
      end
    else
      sb_uiMessage("techFail")
    end
  tech = config.getParameter("techModules")
end

function ownsTech() return contains(player.enabledTechs(), tech[2]) or contains(player.getProperty("sb_bioimplants",{}), tech[2]) end