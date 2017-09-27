-- Endurance check condition
local sm_condition_endurance = class('Endurance', sm_condition)
sm_condition_endurance.uid = "Endurance"
sm_condition_endurance.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_endurance:initialize(data)
	self.operator = data.operator or 1
	self.value = data.value or 100
end
-- Save  the condition data into a table and returns that
function sm_condition_endurance:Save()
	local data = {}
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_endurance:Evaluate(context)
	if ( context.player) then	
		local mp = context.player.endurance		
		if ( type(mp) == "number" ) then						
			if ( self.operator == 1 ) then return mp < self.value 
			elseif ( self.operator == 2 ) then return mp <= self.value 
			elseif ( self.operator == 3 ) then return mp == self.value 
			elseif ( self.operator == 4 ) then return mp >= self.value
			elseif ( self.operator == 5 ) then return mp > self.value
			end
		end
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_endurance:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(200)
	GUI:InputText("##sm_condition_endurance1"..tostring(id), GetString("Player Endurance Percent"),GUI.InputTextFlags_ReadOnly)
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_endurance2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_endurance3"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 100 ) then self.value = 100 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_endurance) 