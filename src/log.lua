-- ------------------------------------
-- Simple log output 
-- ------------------------------------
local log = {}

local function iterateTable(item)
    local first = true
    io.write(" {")
    for key, value in pairs(item) do
      if not first then io.write(", ") end
      if first then first = false end      
      io.write(key .. ": ");
      if (type(value) == "table") then
        iterateTable(value)
      else
        io.write(value)
      end
    end
    io.write(" }")
end

local function write(scope, text, item)
  if type(item) == "string" or type(item) == "number" then
    print(scope .. ": " .. text .. " " .. item)
  elseif type(item) == "table" then
    io.write(scope .. ": " .. text)
    iterateTable(item)
    io.write("\n")
  end
end

function log.info(text, item)
  write("INFO", text, item)
end

return log