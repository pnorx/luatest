require("luatest.oop")
local AbstractCallback = require("luatest.AbstractCallback")

local UnitTest = {}
UnitTest = class("UnitTest", AbstractCallback)

UnitTest.TestCase = require("luatest.TestCase")
UnitTest.TestAssertion = require("luatest.TestAssertion")

UnitTest._unitTestInstances = {}

UnitTest._callbacks = {}
UnitTest.CALL_AT = {
  BEFORE_TESTING = 1,
  BEFORE_UNIT    = 2,
  BEFORE_CASE    = 3,
  TEST_CASE      = 4,
  RESULT_CASE    = 7,
  AFTER_CASE     = 8,
  RESULT_UNIT    = 9,
  AFTER_TESTING  = 10
}

function UnitTest._registerOutputHandler(outputHandler)
  UnitTest:subscribe(UnitTest.CALL_AT.BEFORE_TESTING, outputHandler.on_before_testing)
  UnitTest:subscribe(UnitTest.CALL_AT.BEFORE_UNIT,    outputHandler.on_before_unit)
  UnitTest:subscribe(UnitTest.CALL_AT.BEFORE_CASE,    outputHandler.on_before_case)
  UnitTest:subscribe(UnitTest.CALL_AT.TEST_CASE,      outputHandler.on_test_case)
  UnitTest:subscribe(UnitTest.CALL_AT.RESULT_CASE,    outputHandler.on_result_case)  
  UnitTest:subscribe(UnitTest.CALL_AT.AFTER_CASE,     outputHandler.on_after_case)
  UnitTest:subscribe(UnitTest.CALL_AT.RESULT_UNIT,    outputHandler.on_result_unit)
  UnitTest:subscribe(UnitTest.CALL_AT.AFTER_TESTING,  outputHandler.on_after_testing)
end

function UnitTest.main(outputHandler)
  local outputHandler = outputHandler or require("luatest.StandardOutputHandler")
  UnitTest._registerOutputHandler(outputHandler)

  UnitTest:_push(UnitTest.CALL_AT.BEFORE_TESTING)
  
  for i, unitTest in ipairs(UnitTest._unitTestInstances) do
    UnitTest:_push(UnitTest.CALL_AT.BEFORE_UNIT, unitTest)
    if unitTest.init then unitTest:init() end
    
    for testCase in unitTest:nextTestCase() do
      UnitTest:_push(UnitTest.CALL_AT.BEFORE_CASE, testCase)
      if unitTest.setup then unitTest:setup() end
      
      UnitTest:_push(UnitTest.CALL_AT.TEST_CASE, testCase)
      testCase:execute()
      UnitTest:_push(UnitTest.CALL_AT.RESULT_CASE, testCase)
      
      if unitTest.teardown then unitTest:teardown() end
      UnitTest:_push(UnitTest.CALL_AT.AFTER_CASE, testCase)
    end
    
    if unitTest.finit then unitTest:finit() end
    UnitTest:_push(UnitTest.CALL_AT.RESULT_UNIT, unitTest)
  end
  
  UnitTest:_push(UnitTest.CALL_AT.AFTER_TESTING)
end

function UnitTest.__call(self, name)
  local instance = setmetatable({name=name}, self.__type)
  table.insert(UnitTest._unitTestInstances, instance)
  return instance
end

function UnitTest:nextTestCase()
  local testCases = {}
  
  for k, v in pairs(self) do
    if type(k) == "string" and type(v) == "function" then
      if k:find("test") == 1 then
        table.insert(testCases, UnitTest.TestCase(k, v))
      end
    end
  end

  local i = 0
  return function()
    i = i + 1
    return testCases[i]
  end
end

-- TODO: umbenennen und zusammenfassen zu :runStandalone
function UnitTest.is_main(name) -- TODO: ändern zu Objektfunktion und damit zu tostring(self)
  return arg[0]:match("([^\\/]*).lua$") == tostring(name)
end

function UnitTest.__type.__tostring(self)
  return self.name or "<no name available>"
end

return UnitTest