-- CombatState check condition
local sm_condition_swimstate = class('SwimState', sm_condition)
sm_condition_swimstate.uid = "SwimState"
sm_condition_swimstate.targets = { [1] = GetString("Player is"), [2] = GetString("Target is"),  }
sm_condition_swimstate.operators = { [1] = GetString("Not in Water"), [2] = GetString("Diving"), [3] = GetString("Swimming"), }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_swimstate:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_swimstate:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_swimstate:Evaluate(skill,context)
	local state 
	if ( self.target == 1 and context.player ) then
		state = context.player.swimming
	elseif ( self.target == 2 and context.attack_target ) then
		state = context.attack_target.swimming 
	elseif ( self.target == 3 and context.heal_target ) then
		state = context.heal_target.swimming
	end
	if (state~=nil) then
		if ( self.operator == 1 ) then return state == 0
		elseif ( self.operator == 2 ) then return state == 1
		elseif ( self.operator == 3 ) then return state == 2
		end		
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_swimstate:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_swimstate"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_swimstate2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	return modified
end
SkillManager:AddCondition(sm_condition_swimstate)