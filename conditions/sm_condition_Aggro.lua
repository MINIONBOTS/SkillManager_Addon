-- Aggro Condition
local sm_condition_aggro = class('Aggro', sm_condition)
sm_condition_aggro.uid = "Aggro"
sm_condition_aggro.targets = { [1] = GetString("Target"), [2] = GetString("Player"), [3] = GetString("Friend"), }
sm_condition_aggro.operators = { [1] = GetString("has Aggro"), [2] = GetString("has no Aggro"), }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_aggro:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_aggro:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_aggro:Evaluate(skill,context)
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

	local hasaggro = t and t.isaggro
	return self.operator == 1 and hasaggro or self.operator == 2 and not hasaggro
end
function sm_condition_aggro:Render(id) -- need to pass an index value here, for the unique IDs used by imgui
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_aggro"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()

	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_aggro_2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_aggro)