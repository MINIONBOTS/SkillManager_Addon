-- CombatState check condition
local sm_condition_combatstate = class('Alive', sm_condition)
sm_condition_combatstate.uid = "Alive"
sm_condition_combatstate.targets = { [1] = GetString("Player is"), [2] = GetString("Target is"), [3] = GetString("Friend is"),  }
sm_condition_combatstate.operators = { [1] = GetString("Alive"), [2] = GetString("Not Alive"),  }
function sm_condition_combatstate:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
function sm_condition_combatstate:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	return data
end
function sm_condition_combatstate:Evaluate(skill,context)
	local state 
	if ( self.target == 1 and context.player ) then
		state = context.player.alive
	elseif ( self.target == 2 and context.attack_target ) then
		state = context.attack_target.alive
	elseif ( self.target == 3 and context.heal_target ) then
		state = context.heal_target.alive
	end
	local isalive = state~=nil;
	return self.operator == 1 and isalive or self.operator == 2 and not isalive
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_combatstate:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_alive"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_alive2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	return modified
end
SkillManager:AddCondition(sm_condition_combatstate)