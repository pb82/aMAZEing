local log = require("log")

local rooms = {}

--[[
  Rooms must not overlap and must also keep at least
  one tile between them
--]]
local function overlaps(grid, dimensions)
  local w = dimensions.width
  local h = dimensions.height
  local rX = dimensions.x
  local rY = dimensions.y
  
  for y = 0, h + 1 do
    for x = 0, w + 1 do
      if grid:exists({x=x+rX-1,y=y+rY-1}) then
        local cell = grid:getCell({x=x+rX-1,y=y+rY-1})
        if (cell.n+cell.s+cell.w+cell.e < 4) then
          return true
        end
      end
    end
  end
  
  return false
end 

-- Place a single room in the dungeon given it's
-- dimensions 
local function placeRoom(grid, dimensions)
  local w = dimensions.width
  local h = dimensions.height
  local rX = dimensions.x
  local rY = dimensions.y
  
  for y = 1, h do
    for x = 1, w do
      local cell = grid:getCell({x=x+rX-1,y=y+rY-1})
      if (cell.n+cell.s+cell.w+cell.e < 4) then
        log.info("already filled",cell)
      -- Upper left corner
      elseif x == 1 and y == 1 then
        cell.n = 1
        cell.s = 0
        cell.e = 0
        cell.w = 1
      -- Upper right corner
      elseif x == w and y == 1 then
        cell.n = 1
        cell.s = 0
        cell.e = 1
        cell.w = 0
      -- Lower left corner
      elseif x == 1 and y == h then
        cell.n = 0
        cell.s = 1
        cell.e = 0
        cell.w = 1
      -- Lower right corner
      elseif x == w and y == h then
        cell.n = 0
        cell.s = 1
        cell.e = 1
        cell.w = 0
      -- Upper wall
      elseif y == 1 then
        cell.n = 1
        cell.s = 0
        cell.w = 0
        cell.e = 0
      -- Lower wall
      elseif y == h then
        cell.n = 0
        cell.s = 1
        cell.w = 0
        cell.e = 0
      -- Left wall
      elseif x == 1 then
        cell.n = 0
        cell.s = 0
        cell.w = 1
        cell.e = 0
      -- Right wall
      elseif x == w then
        cell.n = 0
        cell.s = 0
        cell.w = 0
        cell.e = 1
      else
        cell.n = 0
        cell.s = 0
        cell.w = 0
        cell.e = 0
      end      
    end
  end  
end

-- Connect a list of rooms to the maze system
function rooms.connectRooms(grid, rooms)
  for _, room in pairs(rooms) do
    local x = room.x
    local y = room.y
    local w = room.width
    local h = room.height
    
    -- Vertical connections
    local vCons = {}
    
    -- Try northern wall
    for i = x, x + w - 1 do
      if y > 1 then
        local cellA = grid:getCell({x=i,y=y-1})
        local cellB = grid:getCell({x=i,y=y})
        
        if cellA.n+cellA.w+cellA.e+cellA.s < 4 then
          table.insert(vCons,1,{cellA=cellA, cellB=cellB})
        end
      end
    end
    
    -- Try southern wall
    for i = x, x + w - 1 do
      if y < grid.height then
        local cellA = grid:getCell({x=i,y=y+h-1})
        local cellB = grid:getCell({x=i,y=y+h})
        
        if cellA.n+cellA.w+cellA.e+cellA.s < 4 then
          table.insert(vCons,1,{cellA=cellA, cellB=cellB,x=i,y=y+h})
        end
      end
    end
        
    if #vCons > 0 then
      local pair = vCons[math.random(1,#vCons)]
      pair.cellB.n=0
      pair.cellB.ln=1
      pair.cellA.s=0
      pair.cellA.ls=1
    end    
  end
end

-- Place rooms in the dungeon, depending on the
-- settings
function rooms.placeRooms(grid, number, size)
  local tries = 0
  local roomsPlaced = 0
  local rooms = {}
  
  -- Try to place a room until the desired number
  -- of rooms is reached
  while roomsPlaced < number do
    -- Get some random dimensions for a room
    local x = math.random(1, grid.width)
    local y = math.random(1, grid.height)
    local width = math.random(2, size)
    local height = math.random(2, size)
    
    -- Test if the dimensions are actually within the grid
    if x + width > grid.width or y + height > grid.height then
        -- If no, discard them
    else
        -- If yes, place a room at that position with the
        -- given dimensions
        local dimensions = {x=x, y=y, height=height, width=width}
        if (not overlaps(grid, dimensions)) then
          placeRoom(grid, dimensions)
          table.insert(rooms,1,dimensions)
          roomsPlaced = roomsPlaced + 1
        end
    end    
    
    tries = tries + 1
    if tries > (100 * number) then
      roomsPlaced = number
    end
  end
  
  return rooms
end

return rooms