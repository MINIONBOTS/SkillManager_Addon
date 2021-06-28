-- Cooldown condition
local sm_condition_cooldown = class('Ammo', sm_condition)
sm_condition_cooldown.uid = "Ammo"
sm_condition_cooldown.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_cooldown:initialize(data)	
	self.operator = data.operator or 1
	self.value = data.value or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_cooldown:Save()
	local data = {}
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_cooldown:Evaluate(skill,context)	
	local val = skill.ammo
	if ( val ) then
		if ( self.operator == 1 ) then return val < self.value 
		elseif ( self.operator == 2 ) then return val <= self.value 
		elseif ( self.operator == 3 ) then return val == self.value 
		elseif ( self.operator == 4 ) then return val >= self.value
		elseif ( self.operator == 5 ) then return val > self.value		
		end
	end
	return false
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_cooldown:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Ammo"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_ammo2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_ammo3"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( self.value < 0) then self.value = 0 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	return modified
end
SkillManager:AddCondition(sm_condition_cooldown) 