-- ------------------------------------
-- aMAZEing
-- A maze and dungeon generator
-- ------------------------------------
local config  = require("config")
local stack   = require("stack")
local grid    = require("grid")
local log     = require("log")

-- Seed the random number generator
local function randomize()
  local seed = os.time() * os.clock()
  math.randomseed(seed)
  math.random()
end

-- Returns a random starting point
local function getStartingPoint(grid)
  return {
    x = math.random(1, grid.width),
    y = math.random(1, grid.height)
  }
end

local function run(grid)
  local currentCell = getStartingPoint(grid)
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
  run(g)
  g:reduceDeadEnds(config.deadEndReduction)
  g:printToStdout()
end

main()
