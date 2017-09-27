-- Movement check condition
local sm_condition_movement = class('Movement', sm_condition)
sm_condition_movement.uid = "Movement"
sm_condition_movement.targets = { [1] = GetString("Target"), [2] = GetString("Player"), [3] = GetString("Friend"), }
sm_condition_movement.operators = { [1] = GetString("Is Moving"), [2] = GetString("Is Not Moving"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_movement:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_movement:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_movement:Evaluate(context)
	-- Use:
	-- context.player
	-- context.attack_target	(== "Enemy")
	-- context.heal_target	(== "Friend")
	local t
	if ( self.target == 1 ) then 
		t = context.attack_target
	elseif ( self.target == 2 ) then
		t = context.player
	elseif ( self.target == 3 ) then
		t = context.heal_target
	end
	
	if (t) then
		local state = t.movementstate
		if ( self.operator == 1 ) then return state > 1
		elseif ( self.operator == 2 ) then return state <= 1
		end		
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_movement:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_movement"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_movement2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	return modified
end
SkillManager:AddCondition(sm_condition_movement)