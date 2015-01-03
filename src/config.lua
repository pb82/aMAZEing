-- ------------------------------------
-- Dungeon configuration. Edit the
-- values to produce different dungeons
-- ------------------------------------
local config = {
  -- Grid dimensions
  width = 10,
  height = 10,
    
  -- The rooms of the dungeon
  rooms = {
    number = 3,
    
    -- The maximum size in x and y direction
    size = 3
  },
  
  -- The number of iterations to spend on
  -- dead end reduction. The lower this 
  -- number, the less pathways between 
  -- rooms
  deadEndReduction = 50,
  verbose = true
}

return config