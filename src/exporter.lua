local exporter = {}

-- The symbols to represent walls and floor in the
-- output
exporter.wall   = "2"
exporter.floor  = "1"

-- Write to stdout
function exporter:stdout(grid)
  local printIndexLine = true
  for y = 1, grid.height do
    for z = 0, 3 do
      for x = 1, grid.width do
        local cell = grid.cells[x][y]
        if z == 0 then
          if printIndexLine then io.write(" " .. x % 10 .. " ") end
        elseif z == 1 then
          if(cell.n+cell.w == 0 and cell.ln == 0) then
            io.write(self.floor)
          else
            io.write(self.wall) 
          end
          if cell.n == 1 then io.write(self.wall) else io.write(self.floor) end 
          if(cell.n+cell.e == 0 and cell.ln == 0) then
            io.write(self.floor)
          else
            io.write(self.wall) 
          end
        elseif z == 2 then
          if cell.w == 1 then io.write(self.wall) else io.write(self.floor) end 
          if cell.n + cell.s + cell.w + cell.e == 4 then
            io.write(self.wall)
          else
            io.write(self.floor) 
          end
          if cell.e == 1 then io.write(self.wall) else io.write(self.floor) end
        elseif z == 3 then
          if(cell.s+cell.w == 0 and cell.ls == 0) then
            io.write(self.floor)
          else
            io.write(self.wall) 
          end
          if cell.s == 1 then io.write(self.wall) else io.write(self.floor) end 
          if(cell.s+cell.e == 0 and cell.ls == 0) then
            io.write(self.floor)
          else
            io.write(self.wall) 
          end
        end
      end
      if z == 2 then io.write(" " .. y) end
      if z > 0 then io.write("\n") end
      if printIndexLine then io.write("\n") end
      printIndexLine = false
    end
  end
end

return exporter