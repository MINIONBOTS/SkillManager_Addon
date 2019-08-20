-- Condition template:
local sm_condition = class('sm_condition')
-- Initialize new class, - gets called when :new(..) is called
function sm_condition:initialize()
	ml_error("Implement a 'function sm_condition:initialize()' in your sm_condition: "..tostring(self.uid))
end
-- Save  the condition data into a table and returns that
function sm_condition:Save()
	ml_error("Implement a 'function sm_condition:Save()' in your sm_condition: "..tostring(self.uid))
end
-- Evaluates the condition, returns "true" / "false".
function sm_condition:Evaluate(skill,context)
	ml_error("Implement a 'function sm_condition:Evaluate()' in your sm_condition: "..tostring(self.uid))
end
-- Renders the condition UI
function sm_condition:Render()
	ml_error("Implement a 'function sm_condition:Render()' in your sm_condition: "..tostring(self.uid))
end
_G['sm_condition'] = sm_condition	-- so others can init their condition