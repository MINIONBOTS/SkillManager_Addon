-- Single Custom Buff ID check condition
local sm_condition_buffid = class('Buff (ID)', sm_condition)
sm_condition_buffid.uid = "Buff (ID)"
sm_condition_buffid.targets = { [1] = GetString("Target"), [2] = GetString("Player"), [3] = GetString("Friend"),  }
sm_condition_buffid.operators = { [1] = GetString("has Buff ID"), [2] = GetString("has not Buff ID"), }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_buffid:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.buffid = data.buffid or 743
end
-- Save  the condition data into a table and returns that
function sm_condition_buffid:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	data.buffid = self.buffid
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buffid:Evaluate(skill,context)
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

	local hasbuff = false

	if ( t ) then
		local buffs = t.buffs
		if ( buffs ) then
			hasbuff = buffs[self.buffid] ~= nil
		end
	end

	return self.operator == 1 and hasbuff or self.operator == 2 and not hasbuff
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_buffid:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_buffid"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(175)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_buffid2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(100)
	GUI:SameLine()	
	self.buffid, changed = GUI:InputInt("##sm_condition_buffid3"..tostring(id),self.buffid, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_buffid) 