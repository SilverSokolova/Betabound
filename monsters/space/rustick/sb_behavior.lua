local ini = init or function() end

function init()
  if world.type() == "cultistmission1" then
    local pos = entity.position()
    if pos[1] == 844 and pos[2] == 906 then
      mcontroller.setPosition({pos[1]-1,pos[2]-1})
    elseif pos[1] == 954 and pos[2] == 866 then
      mcontroller.setPosition({pos[1]-1,pos[2]-1})
    end
  end
  ini()
end