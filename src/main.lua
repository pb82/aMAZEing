-- ------------------------------------
-- aMAZEing
-- A maze and dungeon generator
-- ------------------------------------
local exporter  = require("exporter")
local config    = require("config")
local rooms     = require("rooms")
local stack     = require("stack")
local grid      = require("grid")
local log       = require("log")

-- Seed the random number generator
local function randomize()
  local seed = os.time() * os.clock()
  math.randomseed(seed)
  math.random()
end

local function run(grid, currentCell)
  local totalCells = grid:getTotalCells()
  local cellStack = stack.new()
  local visitedCells = 1
  
  log.info("Starting at", currentCell)  
  
  while visitedCells < totalCells do
    local neighbours = grid:getNeighbours(currentCell.x, currentCell.y)
    if #neighbours > 0 then
      -- Pick a random neighbour
      local nextCell = neighbours[math.random(1, #neighbours)]
      
      -- Open up the wall between the current cell and the
      -- selected neighbour
      grid:openPath(currentCell, nextCell)
      
      -- Store the current cell for later backtracking and
      -- proceed with the selected neighbour
      cellStack:push(currentCell)
      currentCell = nextCell
      
      -- We have visited one more cell
      visitedCells = visitedCells + 1
    else
      -- There are no viable neighbours in the current path:
      -- Backtrack
      currentCell = cellStack:pop()
      -- Terminate the loop when the bottom of the
      -- stack is reached (no more backtracking possible)
      if (currentCell == nil) then
        visitedCells = totalCells
      end
    end
  end
end

-- Entry point
local function main()
  randomize()
  local g = grid.new(config.width, config.height)
  local r = rooms.placeRooms(g,config.rooms.number,config.rooms.size)
    
  -- Iterate over all cells in the grid
  for x = 1, g.width do
    for y = 1, g.height do
      local coord = {x=x, y=y}
      -- If a cell is surrounded only by walls
      if g:isLocked(coord) then
        -- run the maze generator 
        run(g, coord)
      end
    end
  end  
  
  rooms.connectRooms(g, r)
  
  g:reduceDeadEnds(config.deadEndReduction)
  
  -- Write to stdout
  exporter.floor = " "
  exporter.wall = "█"
  exporter:stdout(g)
end

main()
