-- Breakbar condition
local sm_condition_breakbar = class('Breakbar', sm_condition)
sm_condition_breakbar.uid = "Breakbar"
sm_condition_breakbar.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_breakbar:initialize(data)
	self.operator = data.operator or 1
	self.value = data.value or 50
end
-- Save  the condition data into a table and returns that
function sm_condition_breakbar:Save()
	local data = {}
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_breakbar:Evaluate(context)
	if ( context.attack_target ) then
		local bb = context.attack_target.breakbarpercent*100  -- is originally a value between 0 and 1
		if ( self.operator == 1 ) then return bb < self.value 
		elseif ( self.operator == 2 ) then return bb <= self.value 
		elseif ( self.operator == 3 ) then return bb == self.value 
		elseif ( self.operator == 4 ) then return bb >= self.value
		elseif ( self.operator == 5 ) then return bb > self.value		
		end	
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_breakbar:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Target's Breakbar is"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_breakbar1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_breakbar2"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 100 ) then self.value = 100 end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text(GetString("Percent."))	
	
	return modified
end
SkillManager:AddCondition(sm_condition_breakbar) 