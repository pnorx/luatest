local UnitTest = require("UnitTest")
local asserty = UnitTest.TestAssertion

local Template = UnitTest("Template")

function Template.testcase_01()



  status, response = sendRequest(canId, request)
  

--  asserty.is_true(true)
end

function Template.testcase_02()
--  asserty.is_true(false)  
end

function Template.testcase_03()
--  asserty.set_pending()  
end

function Template.setup()
  -- will be executed before each TestCase
end

function Template.teardown()
  -- will be executed after each TestCase  
end

function Template.init()
  -- will be executed before any TestCase
end

function Template.finit()
  -- will be executed after all TestCases
end

if UnitTest.is_main(Template) then UnitTest.main() end -- TODO: Test Runner Integration in Eclipse