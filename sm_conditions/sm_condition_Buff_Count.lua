
-- Buff Count check condition
local sm_condition_buffs = class('Buffs (Count)', sm_condition)
sm_condition_buffs.uid = "Buffs (Count)"
sm_condition_buffs.targets = { [1] = GetString("Target has"), [2] = GetString("Player has"), [3] = GetString("Friend has")  }
sm_condition_buffs.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
sm_condition_buffs.bufftypes = { [1] = GetString("Boons"), [2] = GetString("Conditions"), [3] = GetString("SpeedBoons"), [4] = GetString("SlowConditions"), [5] = GetString("ImmobilizeConditions"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_buffs:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.bufftype = data.bufftype or 1
	self.value = data.value or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_buffs:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	data.bufftype = self.bufftype
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buffs:Evaluate(context)
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
		
	if ( t ) then	
		local buffs = t.buffs		
		if ( buffs ) then	
			local count = 0
			if (self.bufftype == 1) then count = self:CountBuffsInList(ml_global_information.BoonsEnum, buffs)
			elseif (self.bufftype == 2) then count = self:CountBuffsInList(ml_global_information.ConditionsEnum, buffs)
			elseif (self.bufftype == 3) then count = self:CountBuffsInList(ml_global_information.SpeedBoons, buffs)
			elseif (self.bufftype == 4) then count = self:CountBuffsInList(ml_global_information.SlowConditions, buffs)
			elseif (self.bufftype == 5) then count = self:CountBuffsInList(ml_global_information.ImmobilizeConditions, buffs)
			end
			
			if ( self.operator == 1 ) then return count < self.value 
			elseif ( self.operator == 2 ) then return count <= self.value 
			elseif ( self.operator == 3 ) then return count == self.value 
			elseif ( self.operator == 4 ) then return count >= self.value
			elseif ( self.operator == 5 ) then return count > self.value
			end
		else
			return false
		end
	end	
end
--Helper func
function sm_condition_buffs:CountBuffsInList(listtocheckagainst,buffs)
	local count = 0
	if ( table.size(buffs) > 0 ) then
		for id,v in pairs (buffs) do
			if ( listtocheckagainst[id] ) then
				count = count + 1
			end
		end
	end
	return count
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_buffs:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_buffs"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_buffs2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_buffs3"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(175)
	GUI:SameLine()
	self.bufftype, changed = GUI:Combo("##sm_condition_buffs4"..tostring(id),self.bufftype, self.bufftypes)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_buffs)