require("luatest.oop")

local TestAssertion = require("luatest.TestAssertion")

local TestCase = {}
TestCase = class("TestCase")

TestCase.MESSAGE = {
  RUNTIME_ERROR_SHORT = "unhandled exception in testcase"
}

function TestCase.__call(self, name, func)
  local instance = setmetatable({}, self.__type)
  instance.name = name
  instance.func = func
  instance.status = TestAssertion.STATUS.PENDING
  return instance
end

function TestCase:execute()
  local testCaseDidExecute, failedAssertionOrError = xpcall(self.func, debug.traceback)

  if testCaseDidExecute then
    self.status = TestAssertion.STATUS.SUCCESS
  else
    if isinstance(failedAssertionOrError, TestAssertion) then
      self.status = failedAssertionOrError.status
      self.errorMsgShort = failedAssertionOrError.errorMsgShort
      self.errorMsgLong = failedAssertionOrError.errorMsgLong
      self.stackTrace = failedAssertionOrError.stackTrace
    else
      self.status = TestAssertion.STATUS.RUNTIME_ERROR
      self.errorMsgShort = TestCase.MESSAGE.RUNTIME_ERROR_SHORT
      self.errorMsgLong = tostring(failedAssertionOrError)
    end
  end  
end

function TestCase.__type.__tostring(self)
  return self.name
end

return TestCase
