-- Positioning condition
local sm_condition_breakbar = class('Positioning', sm_condition)
sm_condition_breakbar.uid = "Positioning"
sm_condition_breakbar.operators = { [1] = GetString("In Front of"), [2] = GetString("Flanking"), [3] = GetString("Behind"), [4] = GetString("Not Facing"), }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_breakbar:initialize(data)
	self.operator = data.operator or 1	
end
-- Save  the condition data into a table and returns that
function sm_condition_breakbar:Save()
	local data = {}
	data.operator = self.operator
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_breakbar:Evaluate(skill,context)
	if ( context.attack_target ) then
		local facedir = Player:IsFacingTarget(context.attack_target.id)			
		if ( (self.operator == facedir)  or (self.operator == 0 and facedir == false)) then 
			return true 
		end
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_breakbar:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Player is "))
	GUI:SameLine()
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_positioning1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
			
	GUI:SameLine()
	GUI:Text(GetString(" Target"))	
	
	return modified
end
SkillManager:AddCondition(sm_condition_breakbar) 