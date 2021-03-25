require("luatest.oop")
require("luatest.tableExtension")

local TrackedFunction = {}
TrackedFunction = class("TrackedFunction")

TrackedFunction._instances = {}

TrackedFunction.FORMAT_STRING_KEY = "%s: %d <= %d <= %s"


--- TrackedFunction constructor.
--
-- Creates and returns a TrackedFunction-instance that can be used inside UnitTests to
-- determine how often a specific function has been called inside a complex procedure.
--
-- @tparam table self Implicit parameter TrackedFunction-class-table
-- @tparam function func Function that shall be tracked
-- @tparam table container Table that contains the function that shall be tracked
-- @treturn TrackedFunction TrackedFunction-instance of the function that shall be tracked
function TrackedFunction.__call(self, func, container)
  local instance = setmetatable({}, self.__type)
  
  -- Check whether container actually contains the function that shall be tracked
  local key = table.key(container, func)
  if key then instance._key = key else error("Table does not contain function") end
  
  -- Replace the function that shall be tracked with a TrackedFunction-instance
  container[key] = instance
  
  --- Remember the function that shall be tracked.
  instance._func = func
  --- Remember the container that contains the tracked function.
  instance._container = container
  --- Remember the key that points at the tracked function inside container.
  instance._key = key
  --- The expected minimum number of calls of the tracked function.
  instance._minCalls = 1
  --- The expected maximum number of calls of the tracked function.
  instance._maxCalls = math.huge
  --- The number of actual calls of the tracked function.
  instance._calls = 0
  
  -- Keep track of all TrackedFunction-instances
  TrackedFunction._instances[func] = instance
  
  return instance
end

function TrackedFunction.nextTrackedFunction()
  local trackedFunctionKeys = table.keys(TrackedFunction._instances)
  local i = 0
  return function()
    i = i + 1
    return TrackedFunction._instances[trackedFunctionKeys[i]]
  end
end

function TrackedFunction.count()
  local trackedFunctionKeys = table.keys(TrackedFunction._instances)
  return #trackedFunctionKeys
end

function TrackedFunction.verifyAll()
  local result = true
  local badTrackedFunctions = {}
  for trackedFunction in TrackedFunction.nextTrackedFunction() do
    if not trackedFunction:verify() then
      result = false
      table.insert(badTrackedFunctions, trackedFunction)
    end
  end
  return result, badTrackedFunctions
end

function TrackedFunction.untrack(func)
  local trackedFunction = TrackedFunction._instances[func]
  trackedFunction:_restore()
  TrackedFunction._instances[func] = nil
end

function TrackedFunction.untrack_all()
  for _, trackedFunction in pairs(TrackedFunction._instances) do
    trackedFunction:_restore()
  end
  TrackedFunction._instances = {}
end

function TrackedFunction:_restore()
  self._container[self._key] = self._func
end

--- Sets the minimum allowed number of calls to the tracked function.
-- 
-- @tparam number n Minimum number of calls
function TrackedFunction:setMinCalls(n)
  -- TODO: check min kleiner max
  self._minCalls = n
end

--- Sets the maximum allowed number of calls to the tracked function.
-- 
-- @tparam number n Maximum number of calls
function TrackedFunction:setMaxCalls(n)
  self._maxCalls = n
end

--- Sets a fixed allowed number of calls to the tracked function.
-- 
-- @tparam number n Fixed number of calls
function TrackedFunction:setFixedCalls(n)
  self._minCalls = n
  self._maxCalls = n
end

--- Resets the call counter for the tracked function.
-- 
function TrackedFunction:resetCallCount()
  self._calls = 0
end

---
function TrackedFunction:isOver()
  return self._calls > self._maxCalls
end

function TrackedFunction:isUnder()
  return self._calls < self._minCalls
end

function TrackedFunction:verify()
  return (not self:isOver()) and (not self:isUnder())
end

--- Call to the tracked function.
--
function TrackedFunction.__type.__call(self, ...)
  self._calls = self._calls + 1
  return self._func(...)
end

function TrackedFunction.__type.__tostring(self)
  local formatString = TrackedFunction.FORMAT_STRING_KEY
  local msg = formatString:format(
    tostring(self._key), 
    self._minCalls, 
    self._calls, 
    tostring(self._maxCalls)
  )
  
  return msg
end

return TrackedFunction
