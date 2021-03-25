local TestAssertion = require("luatest.TestAssertion")

local StandardOutputHandler = {} -- umbenennen zu SimpleOutputHandler

StandardOutputHandler.unittests_executed = 0
StandardOutputHandler.unittests_successfull = 0
StandardOutputHandler.unittests_with_problem = {}
StandardOutputHandler._unittestIsClean = true
StandardOutputHandler._current_unit = nil

StandardOutputHandler.testcases_executed = 0
StandardOutputHandler.testcases_successfull = 0
StandardOutputHandler.testcases_faulty = 0
StandardOutputHandler.testcases_pending = 0
StandardOutputHandler.testcases_broken = 0
StandardOutputHandler.testcase_messages = {}

local lineDouble = "=================================================="
local lineSingle = "--------------------------------------------------"

local function generateTestCaseResultMessage(testcase)
  local statusStr = TestAssertion.MESSAGE[testcase.status]
  local shortMsgStr = (testcase.errorMsgShort ~= nil) and  testcase.errorMsgShort or "" 
  local longMsgStr = (testcase.errorMsgLong ~= nil) and  testcase.errorMsgLong or ""
  local unitStr = tostring(StandardOutputHandler._current_unit)
  local message = ("%s: %s [%s]\n%s\n%s\n\n%s"):format(statusStr, testcase.name, unitStr, lineSingle, shortMsgStr,longMsgStr)
  if testcase.stackTrace then message = message .. "\n" .. testcase.stackTrace end
  return message
end

function StandardOutputHandler.on_before_testing()
--  print("CALLBACK:BEFORE_TESTING")
end

function StandardOutputHandler.on_before_unit(unittest)
--  print("CALLBACK:BEFORE_UNIT")
--  print("next UnitTest: " .. tostring(unittest))
  StandardOutputHandler.unittests_executed = StandardOutputHandler.unittests_executed + 1
  StandardOutputHandler._unittestIsClean = true
  StandardOutputHandler._current_unit = unittest
end

function StandardOutputHandler.on_before_case(testcase)
--  print("CALLBACK:BEFORE_CASE")
--  print("next TestCase: " .. tostring(testcase))
end

function StandardOutputHandler.on_test_case(testcase)
--  print("CALLBACK:TEST_CASE")
  StandardOutputHandler.testcases_executed = StandardOutputHandler.testcases_executed + 1
end

function StandardOutputHandler.on_result_case(testcase)
--  print("CALLBACK:RESULT_CASE")
  if testcase.status == TestAssertion.STATUS.SUCCESS then
    io.stdout:write(".")
    StandardOutputHandler.testcases_successfull = StandardOutputHandler.testcases_successfull + 1
  else
    if testcase.status == TestAssertion.STATUS.FAILURE then
      io.stdout:write("F")
      StandardOutputHandler.testcases_faulty = StandardOutputHandler.testcases_faulty + 1
      StandardOutputHandler._unittestIsClean = false
    elseif testcase.status == TestAssertion.STATUS.PENDING then
      io.stdout:write("-")  
      StandardOutputHandler.testcases_pending = StandardOutputHandler.testcases_pending + 1
      StandardOutputHandler._unittestIsClean = false
    else
      io.stdout:write("E")  
      StandardOutputHandler.testcases_broken = StandardOutputHandler.testcases_broken + 1
      StandardOutputHandler._unittestIsClean = false
    end
    table.insert(StandardOutputHandler.testcase_messages, generateTestCaseResultMessage(testcase))
  end
end

function StandardOutputHandler.on_after_case(testcase)
--  print("CALLBACK:AFTER_CASE")
end

function StandardOutputHandler.on_result_unit(unittest)
--  print("CALLBACK:RESULT_UNIT")
--  print("\n")
  if StandardOutputHandler._unittestIsClean then
    StandardOutputHandler.unittests_successfull = StandardOutputHandler.unittests_successfull + 1
  else
    table.insert(StandardOutputHandler.unittests_with_problem, tostring(unittest))
  end
end

function StandardOutputHandler.on_after_testing()
--  print("CALLBACK:AFTER_TESTING")
  print("\n")
  for i, testcaseMessage in ipairs(StandardOutputHandler.testcase_messages) do
    print(lineDouble)
    print(testcaseMessage)
  end
  print(lineDouble)
  print("")
  print("TestCases executed:", StandardOutputHandler.testcases_executed)
  print("TestCases successfull:", StandardOutputHandler.testcases_successfull)
  print("TestCases faulty:", StandardOutputHandler.testcases_faulty)
  print("TestCases pending:", StandardOutputHandler.testcases_pending)
  print("TestCases broken:", StandardOutputHandler.testcases_broken)
  print("")
  print("UnitTests executed:", StandardOutputHandler.unittests_executed)
  print("UnitTests successfull:", StandardOutputHandler.unittests_successfull)
  if #StandardOutputHandler.unittests_with_problem == 0 then
    print("All UnitTests were successfull!")
  else
    print("UnitTests with problems:")
    for i, unittest in ipairs(StandardOutputHandler.unittests_with_problem) do print("- " .. unittest) end
  end
end

return StandardOutputHandler