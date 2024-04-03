local swin = swing or function() end

function swing(moves)
  moves.up = true
  moves.down = false
  swin(moves)
end