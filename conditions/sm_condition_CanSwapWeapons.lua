-- CombatState check condition
local sm_condition_combatstate = class('Can Swap Weapons', sm_condition)
sm_condition_combatstate.uid = "Can Swap Weapons"
sm_condition_combatstate.operators = { [1] = GetString("Player can swap Weapons"), [2] = GetString("Player cannot swap Weapons"),  }
function sm_condition_combatstate:initialize(data)	
	self.operator = data.operator or 1
end
function sm_condition_combatstate:Save()
	local data = {}
	data.operator = self.operator
	return data
end
function sm_condition_combatstate:Evaluate(skill,context)
	return context.player and ( (context.player.canswapweaponset and self.operator == 1 ) or (context.player.canswapweaponset == false and self.operator == 2 ))
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_combatstate:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(150)
	self.operator, changed = GUI:Combo("##sm_condition_canswap"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	return modified
end
SkillManager:AddCondition(sm_condition_combatstate)