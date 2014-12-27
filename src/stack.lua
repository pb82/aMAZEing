-- ------------------------------------
-- A primitive stack implementation
-- ------------------------------------
local stack = {}
stack.__index = stack

function stack:push(value)
  table.insert(self,1,value)
  return self
end

function stack:pop()  
  -- Will return nil if the stack is empty
  return table.remove(self,1)
end

function stack.new()
  local instance = {}
  setmetatable(instance, stack)
  return instance
end

return stack