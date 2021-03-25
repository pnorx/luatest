local UnitTest = require("luatest.UnitTest")
local asserty = UnitTest.TestAssertion

local Example_02 = UnitTest("Example_02")

--function Example_02.testcase_is_true()
--  asserty.is_true(true)  
--end
--
--function Example_02.testcase_is_false()
--  asserty.is_false(false)
--end

function Example_02.testcase_check_function_calls()
  local tableContainingFunctionToTrack = {}
  tableContainingFunctionToTrack.functionToTrack = function() end

  local functionCallingFunctionToTrack = function() tableContainingFunctionToTrack.functionToTrack() end

  asserty.track_function(tableContainingFunctionToTrack.functionToTrack, tableContainingFunctionToTrack)

  local functionToTrackWasCalled_1 = pcall(asserty.check_tracked_functions)  
  asserty.is_false(functionToTrackWasCalled_1)
  
  tableContainingFunctionToTrack.functionToTrack:setMinCalls(2)
  tableContainingFunctionToTrack.functionToTrack:setMaxCalls(5)
  
  functionCallingFunctionToTrack()
  functionCallingFunctionToTrack()
  functionCallingFunctionToTrack()
  functionCallingFunctionToTrack()
  
  asserty.check_tracked_functions()
  
--  local functionToTrackWasCalled_2 = pcall(asserty.check_tracked_functions)  
--  asserty.is_true(functionToTrackWasCalled_2)
  
--  asserty.untrack_function(tableContainingFunctionToTrack.functionToTrack)
  
end

if UnitTest.is_main(Example_02) then UnitTest.main() end