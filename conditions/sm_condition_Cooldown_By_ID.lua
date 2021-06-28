-- Cooldown condition
local sm_condition_cooldown = class('Cooldown - by Skill ID', sm_condition)
sm_condition_cooldown.uid = "Cooldown  - by Skill ID"
sm_condition_cooldown.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_cooldown:initialize(data)
	self.skillid = data.skillid or 1175
	self.operator = data.operator or 1
	self.value = data.value or 50
end
-- Save  the condition data into a table and returns that
function sm_condition_cooldown:Save()
	local data = {}
	data.skillid = self.skillid
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_cooldown:Evaluate(skill,context)	
	if ( self.skillid > 1000 and self.skillid < 99999 ) then
		local skillinfo = Player:GetSpellInfoByID(self.skillid)
		if(skillinfo) then
			local val = skillinfo.cooldown
			if ( val ) then
				if ( self.operator == 1 ) then return val < self.value 
				elseif ( self.operator == 2 ) then return val <= self.value 
				elseif ( self.operator == 3 ) then return val == self.value 
				elseif ( self.operator == 4 ) then return val >= self.value
				elseif ( self.operator == 5 ) then return val > self.value		
				end
			end
		end
	end
	return false
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_cooldown:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Cooldown of Skill ID"))
	GUI:SameLine()
	
	GUI:PushItemWidth(100)
	self.skillid, changed = GUI:InputInt("##sm_condition_cooldown1"..tostring(id),self.skillid, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( self.skillid <= 1000 or self.skillid > 99999 ) then self.skillid = 10560 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_cooldown2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_cooldown3"..tostring(id),self.value, 1,50,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text(GetString("ms."))
	
	
	return modified
end
SkillManager:AddCondition(sm_condition_cooldown) 