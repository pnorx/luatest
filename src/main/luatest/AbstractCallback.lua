require("luatest.oop")

if unpack then table.unpack = unpack end

if not table.contains then 
  table.contains = function(tab, element)
    local doesContain = false
    if type(tab) == "table" then
      for _, content in pairs(tab) do
        if content == element then
          doesContain = true
          break
        end 
      end
    end
    return doesContain
  end
end

local AbstractCallback = {}
AbstractCallback = class("AbstractCallback")

function AbstractCallback.__call(self)
  return setmetatable({_callbacks = {}}, self.__type)
end

function AbstractCallback:subscribe(position, callback)
  assert(type(callback) == "function")
  assert(type(self.CALL_AT) == "table")
  assert(table.contains(self.CALL_AT, position))
  if not self._callbacks[position] then self._callbacks[position] = {} end
  table.insert(self._callbacks[position], callback)
end

function AbstractCallback:_push(position, ...)
  if self._callbacks[position] then 
    for i, callback in ipairs(self._callbacks[position]) do
      callback(...)
    end
  end
end

return AbstractCallback