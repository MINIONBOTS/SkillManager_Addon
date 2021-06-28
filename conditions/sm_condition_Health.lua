-- HP check condition
local sm_condition_hp = class('Health', sm_condition)
sm_condition_hp.uid = "Health"
sm_condition_hp.targets = { [1] = GetString("Target"), [2] = GetString("Player"), [3] = GetString("Friend"), }
sm_condition_hp.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
sm_condition_hp.healthtypes = { [1] = GetString("Current Health"), [2] = GetString("Max Health"), [3] = GetString("Health Percent"),  }
function sm_condition_hp:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.healthtype = data.healthtype or 3
	self.value = data.value or 100
end
function sm_condition_hp:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	data.healthtype = self.healthtype
	data.value = self.value
	return data
end
function sm_condition_hp:Evaluate(skill,context)
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

	if ( t ~= nil) then
		local hp = t.health
		if ( hp ) then
			if (self.healthtype == 1) then hp = hp.current
			elseif (self.healthtype == 2) then hp = hp.max
			elseif (self.healthtype == 3) then hp = hp.percent
			end

			if ( self.operator == 1 ) then return hp < self.value
			elseif ( self.operator == 2 ) then return hp <= self.value
			elseif ( self.operator == 3 ) then return hp == self.value
			elseif ( self.operator == 4 ) then return hp >= self.value
			elseif ( self.operator == 5 ) then return hp > self.value
			end
		end
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_hp:Render(id) -- need to pass an index value here, for the unique IDs used by imgui
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_hp"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()

	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.healthtype, changed = GUI:Combo("##sm_condition_hp2"..tostring(id),self.healthtype, self.healthtypes)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()

	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_hp3"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()

	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_hp4"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.healthtype == 3 ) then
		if ( self.value < 0 ) then self.value = 0 end
		if ( self.value > 100 ) then self.value = 100 end
	end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_hp)
