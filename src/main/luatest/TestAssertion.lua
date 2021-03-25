require("luatest.oop")

local TrackedFunction = require("luatest.TrackedFunction")

local TestAssertion = {}
TestAssertion = class("TestAssertion")

TestAssertion.STATUS = {
  PENDING = 1,
  SUCCESS = 2,
  FAILURE = 3,
  BAD_ASSERTION = 4,
  RUNTIME_ERROR = 5
}

TestAssertion.MESSAGE = {
  BAD_ASSERTION_SHORT = "bad test function return value %d: %s <%s>",
  BAD_ASSERTION_LONG = [[If this ERROR appears the following questions might help you:
- Does your custom TestFunction always return 3 values?
- Is the first value a boolean with the test result?
- Are the second and third value strings?]],
  RUNTIME_ERROR_SHORT = "unhandled exception in test function",
  RUNTIME_ERROR_LONG = [[If this ERROR appears the following questions might help you:
- Are you using the correct TestFunction?
- Do you supply the TestFunction with the correct input?
- Are there any unhandled exceptions in your custom TestFunction?]],
  TOO_FEW_CALLS_SHORT = "tracked function was not called often enough",
  TOO_MANY_CALLS_SHORT = "tracked function was called too many times",
  MULTIPLE_CALLING_ISSUES_SHORT = "multiple functions were called either too often or not often enough",
  [TestAssertion.STATUS.PENDING] = "PENDING",
  [TestAssertion.STATUS.SUCCESS] = "SUCCESS",
  [TestAssertion.STATUS.FAILURE] = "FAILURE",
  [TestAssertion.STATUS.BAD_ASSERTION] = "BAD ASSERTION",
  [TestAssertion.STATUS.RUNTIME_ERROR] = "RUNTIME ERROR"
}

function TestAssertion.__call(self, func, pending)
  local instance = setmetatable({}, self.__type)
  instance.status = TestAssertion.STATUS.PENDING
  instance._pending = pending
  instance._test = func
  return instance
end

function TestAssertion.__type.__call(self, ...)
  local assertionDidExecute, assertionResultOrError, assertionMsgShort, assertionMsgLong  = xpcall(self._test, debug.traceback, ...)
  if assertionDidExecute then
    if type(assertionResultOrError) == "boolean" then
      if assertionResultOrError == true then
        self.status = TestAssertion.STATUS.SUCCESS
      else -- assertion result is negative
        if assertionMsgShort and type(assertionMsgShort) == "string" then
          if assertionMsgLong and type(assertionMsgLong) == "string" then
            self.status = TestAssertion.STATUS.FAILURE
            self.errorMsgShort = assertionMsgShort
            self.errorMsgLong = assertionMsgLong
            self.stackTrace = debug.traceback(nil, 2)
          else -- third return value is not a string
            self.status = TestAssertion.STATUS.BAD_ASSERTION
            self.errorMsgShort = TestAssertion.MESSAGE.BAD_ASSERTION_SHORT:format(3, assertionMsgLong, type(assertionMsgLong))
            self.errorMsgLong = TestAssertion.MESSAGE.BAD_ASSERTION_LONG
            self.stackTrace = debug.traceback(nil, 2)
          end
        else -- second return value is not a string
          self.status = TestAssertion.STATUS.BAD_ASSERTION
          self.errorMsgShort = TestAssertion.MESSAGE.BAD_ASSERTION_SHORT:format(2, assertionMsgShort, type(assertionMsgShort))
          self.errorMsgLong = TestAssertion.MESSAGE.BAD_ASSERTION_LONG
          self.stackTrace = debug.traceback(nil, 2)
        end
      end
    else -- firste return value is not a boolean
      self.status = TestAssertion.STATUS.BAD_ASSERTION
      self.errorMsgShort = TestAssertion.MESSAGE.BAD_ASSERTION_SHORT:format(1, assertionResultOrError, type(assertionResultOrError))
      self.errorMsgLong = TestAssertion.MESSAGE.BAD_ASSERTION_LONG
      self.stackTrace = debug.traceback(nil, 2)
    end
  else -- assertion did not execute
    self.status = TestAssertion.STATUS.RUNTIME_ERROR
    self.errorMsgShort = TestAssertion.MESSAGE.RUNTIME_ERROR_SHORT
    self.errorMsgLong = TestAssertion.MESSAGE.RUNTIME_ERROR_LONG
    self.stackTrace = tostring(assertionResultOrError)
  end
  
  if self._pending then self.status = TestAssertion.STATUS.PENDING end
  if self.status ~= TestAssertion.STATUS.SUCCESS then error(self) end
end

function TestAssertion.__type.__tostring(self)
  local statusStr = TestAssertion.MESSAGE[self.status]
  local shortMsgStr = (self.errorMsgShort ~= nil) and  (", ".. self.errorMsgShort) or "" 
  local longMsgStr = (self.errorMsgLong ~= nil) and  ("\n" .. self.errorMsgLong) or ""
  local stackTraceStr = (self.stackTrace ~= nil) and  ("\n" .. self.stackTrace) or ""
  return statusStr .. shortMsgStr .. longMsgStr .. stackTraceStr
end

TestAssertion.track_function = TrackedFunction

TestAssertion.untrack_function = TrackedFunction.untrack

TestAssertion.untrack_all_functions = function()

end

TestAssertion.check_tracked_functions = TestAssertion(function()
  local result, badTrackedFunctions = TrackedFunction.verifyAll()
  
  local errorMessageShort = "<short>"
  local errorMessageLong = "<long>"
  
  if #badTrackedFunctions > 0 then
    if #badTrackedFunctions == 1 then
      local badTrackedFunction = badTrackedFunctions[1]
      if badTrackedFunction:isUnder() then errorMessageShort = TestAssertion.MESSAGE.TOO_FEW_CALLS_SHORT end    
      if badTrackedFunction:isOver() then errorMessageShort = TestAssertion.MESSAGE.TOO_MANY_CALLS_SHORT end
    elseif #badTrackedFunctions > 1 then
      errorMessageShort = TestAssertion.MESSAGE.MULTIPLE_CALLING_ISSUES_SHORT
    end
    
    errorMessageLong = "bad functions:"
    for i, badTrackedFunction in ipairs(badTrackedFunctions) do
      errorMessageLong = errorMessageLong .. "\n" .. tostring(badTrackedFunctions[1])    
    end
  end
  
  return result, errorMessageShort, errorMessageLong  
end)

TestAssertion.set_pending = TestAssertion(function(description) 
  local result = false
  local errorMessageShort = "deliberate pending"
  local errorMessageLong = description or "TestCase was manually flagged as pending"
  return result, errorMessageShort, errorMessageLong
end, true)

TestAssertion.is_true = TestAssertion(function(subject)
  local result = subject == true
  local errorMessageShort = "test subject is not true"
  local errorMessageLong = "tostring(subject) = " .. tostring(subject) .. "\ntype(subject) = " .. type(subject)
  return result, errorMessageShort, errorMessageLong
end)

TestAssertion.is_false = TestAssertion(function(subject)
  local result = subject == false
  local errorMessageShort = "test subject is not false"
  local errorMessageLong = "tostring(subject) = " .. tostring(subject) .. "\ntype(subject) = " .. type(subject)
  return result, errorMessageShort, errorMessageLong
end)

return TestAssertion