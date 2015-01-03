-- ------------------------------------
-- The grid in which to render the 
-- dungeon
-- ------------------------------------
local log = require("log")

local grid = {}
grid.__index = grid

-- Grid constructor
function grid.new(width, height)
  local instance = {}
  instance.width = width
  instance.height = height
  instance.cells = {}
  
  -- The instance is a grid
  setmetatable(instance, grid)
  
  -- Iterate over all cells in the grid...
  for x = 1, width do
    instance.cells[x] = {}
    for y = 1, height do
      -- ...and set up the walls. Initially all walls
      -- are up
      instance.cells[x][y] = {n = 1, s = 1, e = 1, w = 1,ln=0,ls=0}
    end
  end
  
  return instance
end

--[[
  Find dead ends and (cells with three walls surrounding them)
  and remove them 
  
  TODO: At the moment this function is very inefficient. For
  every iteration a new list of dead ends is computed. This
  is not necesarry since the close function could just return
  the new dead end it's left.
--]]
function grid:reduceDeadEnds(maxIterations)
  -- Returns a list of all coordinates of dead ends
  local function findDeadEnds()
    local result = {}
    for y = 1, self.height do
      for x = 1, self.width do
        local cell = self.cells[x][y]
        if self:isDeadEnd({x = x, y = y}) then
          table.insert(result,1,{x = x, y = y})
        end
      end
    end
    return result
  end
  
  local iterations = 0
  
  while iterations < maxIterations do
    local deadEnds = findDeadEnds()

    if (#deadEnds == 0) then
      iterations = maxIterations
    else
      -- Pick a random dead end
      local deadEndIndex = math.random(1,#deadEnds)
      local deadEnd = deadEnds[deadEndIndex]
            
      self:closeCell(deadEnd)
      
      iterations = iterations + 1
    end
  end
end

--[[
  Breaks down the wall between the two cells
  For example if cell a lies left of cell b then
  the western wall of cell a and the eastern wall of
  cell b have to be opened
--]]
function grid:openPath(a, b)
  local xDiff = a.x - b.x
  local yDiff = a.y - b.y
  
  if      xDiff < 0 then self:getCell(a).e = 0; self:getCell(b).w = 0
  elseif  xDiff > 0 then self:getCell(a).w = 0; self:getCell(b).e = 0
  elseif  yDiff < 0 then self:getCell(a).s = 0; self:getCell(b).n = 0
  elseif  yDiff > 0 then self:getCell(a).n = 0; self:getCell(b).s = 0
  end    
end

--[[
  Restores all four walls of a cell. Used for
  dead end reduction. When a dead end is closed
  another dead end is potentially created.
  Return the affected cell
--]]
function grid:closeCell(cell)
  -- We call the cell to close 'deadEnd' because we usually
  -- only close such cells
  local deadEnd = self:getCell(cell) 
  
  -- Manually propagate the erection of the new wall to the
  -- affected neighbour cell
  if deadEnd.n == 0 then self:getCell({x=cell.x, y=cell.y - 1}).s = 1 end
  if deadEnd.s == 0 then self:getCell({x=cell.x, y=cell.y + 1}).n = 1 end
  if deadEnd.e == 0 then self:getCell({x=cell.x + 1, y=cell.y}).w = 1 end
  if deadEnd.w == 0 then self:getCell({x=cell.x - 1, y=cell.y}).e = 1 end
    
  -- Close the cell
  deadEnd.n = 1
  deadEnd.s = 1
  deadEnd.w = 1
  deadEnd.e = 1
end

--[[
  Returns all the neighbours of a cell which are
  1)  Bounded: Their position must be within the grid
  2)  Intact: Only neighbours with all four walls intact
      are considered
--]]
function grid:getNeighbours(x, y)
  local result = {}

  -- Check if a cell lies within the grid
  local function bounded(x, y)
    return self.cells[x] ~= nil and self.cells[x][y] ~= nil
  end
  
  -- Check wether all four walls of a cell are intact
  local function intact(x, y)
    local cell = self.cells[x][y]
    return cell.n == 1 and cell.s == 1 and cell.e == 1 and cell.w == 1
  end
  
  if bounded(x+1,y) and intact(x+1,y) then table.insert(result,1,{x=x+1,y=y}) end
  if bounded(x-1,y) and intact(x-1,y) then table.insert(result,1,{x=x-1,y=y}) end
  if bounded(x,y+1) and intact(x,y+1) then table.insert(result,1,{x=x,y=y+1}) end
  if bounded(x,y-1) and intact(x,y-1) then table.insert(result,1,{x=x,y=y-1}) end
  
  return result
end

-- Returns the total number of cells in the grid
function grid:getTotalCells()
  return self.width * self.height
end

-- Return the cell at the given index
function grid:getCell(coord)
  return self.cells[coord.x][coord.y]
end

-- A cell is a dead end if it is surrounded by walls on
-- three sides
function grid:isDeadEnd(coord)
  local cell = self:getCell(coord)
  return (cell.n + cell.s + cell.e + cell.w) == 3
end

-- A locked cell is surrounded by walls on all four sides
function grid:isLocked(coord)
  local cell = self:getCell(coord)
  return (cell.n + cell.s + cell.e + cell.w) == 4
end

function grid:exists(coord)
  return self.cells[coord.x] ~= nil and self.cells[coord.x][coord.y] ~= nil
end

return grid