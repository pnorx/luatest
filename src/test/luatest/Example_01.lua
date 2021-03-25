local UnitTest = require("luatest.UnitTest")
local asserty = UnitTest.TestAssertion

local Example_01 = UnitTest("Example_01")

function Example_01.testcase_empty()
  
end

function Example_01.testcase_pending()
  asserty.set_pending()
end

function Example_01.testcase_success()
  asserty.is_true(true)
end

function Example_01.testcase_failure()
  asserty.is_true(false)
end

function Example_01.testcase_runtime_error_in_testcase()
  callOnNilValue()
end

function Example_01.testcase_runtime_error_in_assertion()
  asserty.runtime_error = asserty(function() callOnNilValue() end)
  asserty.runtime_error()
end

function Example_01.testcase_bad_assertion_1()
  asserty.bad_assertion_1 = asserty(function() return end)
  asserty.bad_assertion_1()
end

function Example_01.testcase_bad_assertion_2()
  asserty.bad_assertion_2 = asserty(function() return false end)
  asserty.bad_assertion_2()
end

function Example_01.testcase_bad_assertion_3()
  asserty.bad_assertion_3 = asserty(function() return false, "" end)
  asserty.bad_assertion_3()
end

if UnitTest.is_main(Example_01) then UnitTest.main() end