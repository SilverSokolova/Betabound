local originalSwing = swing or function() end

function swing(moves)
  moves.up = true
  moves.down = false
  originalSwing(moves)
end