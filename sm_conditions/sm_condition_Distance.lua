-- Distance condition
local sm_condition_distance = class('Distance', sm_condition)
sm_condition_distance.uid = "Distance"
sm_condition_distance.targets = { [1] = GetString("Enemy"), [2] = GetString("Friend"), }
sm_condition_distance.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_distance:initialize(data)
	self.operator = data.operator or 1
	self.value = data.value or 500
	self.target = data.target or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_distance:Save()
	local data = {}
	data.operator = self.operator
	data.value = self.value
	data.target = self.target
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_distance:Evaluate(context)
	-- Use:
	-- context.player
	-- context.attack_target	(== "Enemy")
	-- context.heal_target	(== "Friend")
	local t
	if ( self.target == 1 ) then 
		t = context.attack_target
	elseif ( self.target == 2 ) then
		t = context.heal_target
	end
	if ( t ) then
		local bb = t.distance
		if ( self.operator == 1 ) then return bb < self.value 
		elseif ( self.operator == 2 ) then return bb <= self.value 
		elseif ( self.operator == 3 ) then return bb == self.value 
		elseif ( self.operator == 4 ) then return bb >= self.value
		elseif ( self.operator == 5 ) then return bb > self.value		
		end	
	end
	return false
end
function sm_condition_distance:Render(id)
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_movement"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	GUI:SameLine()
	
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString(" Distance is"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_distance1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_distance2"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 10000 ) then self.value = 10000 end
	GUI:PopItemWidth()
		
	return modified
end
SkillManager:AddCondition(sm_condition_distance) 