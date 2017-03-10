-- this file holds all condition class definitions used for the gw2 condition builder in the skills

-- Empty Example Condition template class:
local sm_condition = class('sm_condition')
sm_condition.type = 0		-- unique type to identify the "kind" of condition
-- Initialize new class, - gets called when :new(..) is called
function sm_condition:initialize()	
	
end
-- Save  the condition data into a table and returns that
function sm_condition:Save()
	local data = {}
	data.class = 'Health'	-- required, saves the own "class Name"
	return data
end
-- Loads the condition data into this instance
function sm_condition:Load(data)
end
-- Evaluates the condition, returns "true" / "false".
function sm_condition:Evaluate(player,target)
end
-- Renders the condition UI
function sm_condition:Render()
end


-- HP check condition
local sm_condition_hp = class('Health', sm_condition)
sm_condition_hp.targets = { [1] = GetString("Player"), [2] = GetString("Target"),  }
sm_condition_hp.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
sm_condition_hp.healthtypes = { [1] = GetString("Current Health"), [2] = GetString("Max Health"), [3] = GetString("Health Percent"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_hp:initialize()
	self.target = 1
	self.operator = 1
	self.healthtype = 3
	self.value = 100
end
-- Save  the condition data into a table and returns that
function sm_condition_hp:Save()
	local data = {}
	data.class = 'Health'	-- required, saves the own "class Name"
	data.target = self.target
	data.operator = self.operator
	data.healthtype = self.healthtype
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_hp:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.healthtype = data.healthtype or 3
	self.value = data.value or 100
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_hp:Evaluate(player,target)
	if ( player ~= nil) then
		-- This Health Check is set to check HP on a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local hp
		if ( self.target == 1 ) then 
			hp = player.health
		elseif ( self.target == 2 ) then
			hp = target.health
		end
		
		if ( table.valid(hp) ) then
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
		else
			ml_error("[SkillManager] - sm_condition_hp:Evaluate: Invalid HP table")
		end
	else
		ml_error("[SkillManager] - sm_condition_hp:Evaluate: Invalid arguments received")
	end
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
SkillManager:AddCondition(sm_condition_hp) -- register this condition in the SM





-- Power check condition
local sm_condition_power = class('Power', sm_condition)
sm_condition_power.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_power:initialize()
	self.operator = 1
	self.value = 100	
end
-- Save  the condition data into a table and returns that
function sm_condition_power:Save()
	local data = {}
	data.class = 'Power'	-- required, saves the own "class Name"
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_power:Load(data)
	self.operator = data.operator or 1
	self.value = data.value or 100
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_power:Evaluate(player,target)
	if ( player ~= nil) then		
		local mp = player.power
		
		if ( type(mp) == "number" ) then						
			if ( self.operator == 1 ) then return mp < self.value 
			elseif ( self.operator == 2 ) then return mp <= self.value 
			elseif ( self.operator == 3 ) then return mp == self.value 
			elseif ( self.operator == 4 ) then return mp >= self.value
			elseif ( self.operator == 5 ) then return mp > self.value
			end
		else
			ml_error("[SkillManager] - sm_condition_power:Evaluate: Invalid Power Value")
		end
	else
		ml_error("[SkillManager] - sm_condition_power:Evaluate: Invalid arguments received")
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_power:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(200)
	GUI:InputText("##sm_condition_power2"..tostring(id), GetString("Player Power Percent"),GUI.InputTextFlags_ReadOnly)
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_power2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_power3"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 100 ) then self.value = 100 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_power) -- register this condition in the SM




-- Endurance check condition
local sm_condition_endurance = class('Endurance', sm_condition)
sm_condition_endurance.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_endurance:initialize()
	self.operator = 1
	self.value = 100	
end
-- Save  the condition data into a table and returns that
function sm_condition_endurance:Save()
	local data = {}
	data.class = 'Endurance'
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_endurance:Load(data)
	self.operator = data.operator or 1
	self.value = data.value or 100
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_endurance:Evaluate(player,target)
	if ( player ~= nil) then		
		local mp = player.endurance
		
		if ( type(mp) == "number" ) then						
			if ( self.operator == 1 ) then return mp < self.value 
			elseif ( self.operator == 2 ) then return mp <= self.value 
			elseif ( self.operator == 3 ) then return mp == self.value 
			elseif ( self.operator == 4 ) then return mp >= self.value
			elseif ( self.operator == 5 ) then return mp > self.value
			end
		else
			ml_error("[SkillManager] - sm_condition_endurance:Evaluate: Invalid Endurance Value")
		end
	else
		ml_error("[SkillManager] - sm_condition_endurance:Evaluate: Invalid arguments received")
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_endurance:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(200)
	GUI:InputText("##sm_condition_endurance2"..tostring(id), GetString("Player Endurance Percent"),GUI.InputTextFlags_ReadOnly)
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_endurance2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_endurance3"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 100 ) then self.value = 100 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_endurance) -- register this condition in the SM




-- CombatState check condition
local sm_condition_combatstate = class('CombatState', sm_condition)
sm_condition_combatstate.targets = { [1] = GetString("Player is"), [2] = GetString("Target is"),  }
sm_condition_combatstate.operators = { [1] = GetString("In Combat"), [2] = GetString("Not In Combat"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_combatstate:initialize()
	self.target = 1
	self.operator = 1
end
-- Save  the condition data into a table and returns that
function sm_condition_combatstate:Save()
	local data = {}
	data.class = 'CombatState'	-- required, saves the own "class Name"
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Loads the condition data into this instance
function sm_condition_combatstate:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_combatstate:Evaluate(player,target)
	if ( player ~= nil) then
		-- This CombatState Check is set to check on a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local state
		if ( self.target == 1 ) then 
			state = ml_global_information.Player_InCombat
		elseif ( self.target == 2 ) then
			state = target.incombat and target.isaggro
		end
		
					
		if ( self.operator == 1 ) then return state == true
		elseif ( self.operator == 2 ) then return state == false
		end
		
	else
		ml_error("[SkillManager] - sm_condition_combatstate:Evaluate: Invalid arguments received")
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_combatstate:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_combatstate"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_combatstate2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	return modified
end
SkillManager:AddCondition(sm_condition_combatstate) -- register this condition in the SM



-- Movement check condition
local sm_condition_movement = class('Movement', sm_condition)
sm_condition_movement.targets = { [1] = GetString("Player"), [2] = GetString("Target"),  }
sm_condition_movement.operators = { [1] = GetString("Is Moving"), [2] = GetString("Is Not Moving"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_movement:initialize()
	self.target = 1
	self.operator = 1
end
-- Save  the condition data into a table and returns that
function sm_condition_movement:Save()
	local data = {}
	data.class = 'Movement'	-- required, saves the own "class Name"
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Loads the condition data into this instance
function sm_condition_movement:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_movement:Evaluate(player,target)
	if ( player ~= nil) then
		-- This CombatState Check is set to check on a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local state
		if ( self.target == 1 ) then 
			state = ml_global_information.Player_IsMoving
		elseif ( self.target == 2 ) then
			state = target.movementstate == GW2.MOVEMENTSTATE.GroundMoving
		end
		
					
		if ( self.operator == 1 ) then return state == true
		elseif ( self.operator == 2 ) then return state == false
		end
		
	else
		ml_error("[SkillManager] - sm_condition_movement:Evaluate: Invalid arguments received")
	end
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
SkillManager:AddCondition(sm_condition_movement) -- register this condition in the SM





-- Buff Count check condition
local sm_condition_buffs = class('Buffs', sm_condition)
sm_condition_buffs.targets = { [1] = GetString("Player has"), [2] = GetString("Target has"),  }
sm_condition_buffs.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
sm_condition_buffs.bufftypes = { [1] = GetString("Boons"), [2] = GetString("Conditions"), [3] = GetString("SpeedBoons"), [4] = GetString("SlowConditions"), [5] = GetString("ImmobilizeConditions"),  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_buffs:initialize()
	self.target = 1
	self.operator = 1
	self.bufftype = 1
	self.value = 1
end
-- Save  the condition data into a table and returns that
function sm_condition_buffs:Save()
	local data = {}
	data.class = 'Buffs'
	data.target = self.target
	data.operator = self.operator
	data.bufftype = self.bufftype
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_buffs:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.bufftype = data.bufftype or 1
	self.value = data.value or 1
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buffs:Evaluate(player,target)
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = player.buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
		
		if ( table.valid(buffs) ) then
			local count = 0
			if (self.bufftypes == 1) then count = self:CountBuffsInList(ml_global_information.BoonsEnum, buffs)
			elseif (self.bufftypes == 2) then count = self:CountBuffsInList(ml_global_information.ConditionsEnum, buffs)
			elseif (self.bufftypes == 3) then count = self:CountBuffsInList(ml_global_information.SpeedBoons, buffs)
			elseif (self.bufftypes == 4) then count = self:CountBuffsInList(ml_global_information.SlowConditions, buffs)
			elseif (self.bufftypes == 5) then count = self:CountBuffsInList(ml_global_information.ImmobilizeConditions, buffs)
			end
			
			if ( self.operator == 1 ) then return count < self.value 
			elseif ( self.operator == 2 ) then return count <= self.value 
			elseif ( self.operator == 3 ) then return count == self.value 
			elseif ( self.operator == 4 ) then return count >= self.value
			elseif ( self.operator == 5 ) then return count > self.value
			end
		else
			ml_error("[SkillManager] - sm_condition_buffs:Evaluate: Invalid Buff table")
		end
	else
		ml_error("[SkillManager] - sm_condition_buffs:Evaluate: Invalid arguments received")
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
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_buffs2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_buffs3"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.bufftype, changed = GUI:Combo("##sm_condition_buffs4"..tostring(id),self.bufftype, self.bufftypes)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_buffs) -- register this condition in the SM




-- Single Buff check condition
local sm_condition_buff = class('Buff', sm_condition)
sm_condition_buff.targets = { [1] = GetString("Player"), [2] = GetString("Target"),  }
sm_condition_buff.operators = { [1] = GetString("has"), [2] = GetString("has not"), }
sm_condition_buff.buffs = {
	[736]		= GetString("Bleeding"),
	[720]		= GetString("Blind"),
	[737]		= GetString("Burning"),
	[722]		= GetString("Chilled"),
	[861]		= GetString("Confusion"),
	[721]		= GetString("Crippled"),
	[791]		= GetString("Fear"),
	[727]		= GetString("Immobilized"),
	[738]		= GetString("Vulnerability"),
	[742]		= GetString("Weakness"),
	[723]		= GetString("Poison"),
	[27705]		= GetString("Taunt"),
	[26766]		= GetString("Slow"),
	[19426]		= GetString("Torment"),
	
	[743]		= GetString("Aegis"),
	[17675]		= GetString("Aegis"),
	[725]		= GetString("Fury"),
	[740]		= GetString("Might"),
	[717]		= GetString("Protection"),
	[1187]		= GetString("Quickness"),
	[718]		= GetString("Regeneration"),
	[17674]		= GetString("Regeneration"),
	[26980]		= GetString("Resistance"),
	[873]		= GetString("Retaliation"),
	[1122]		= GetString("Stability"),
	[719]		= GetString("Swiftness"),
	[726]		= GetString("Vigor"),
	[762]		= GetString("Determined"),
	
	[5974]		= GetString("Super Speed"),
	[5543]		= GetString("Mist form"),
	[12542]		= GetString("Signet of the Hunt"),
	[13060]		= GetString("Signet of Shadows"),
	[5572]		= GetString("Signet of Air"),
	[10612]		= GetString("Signet of the Locust"),
	[33843]		= GetString("Leader of the Pact I"),
	[32675]		= GetString("Leader of the Pact II"),
	[33611]		= GetString("Leader of the Pact III"),
	
	[18621]		= GetString("Ichor"),
	
	[872]		= GetString("Stun"),
	[833]		= GetString("Daze"),
	[15090]		= GetString("Petrified 1"),
	[16963]		= GetString("Petrified 2"),
	[25181]		= GetString("Trapped"),
	[37211]		= GetString("Frostbite"
	
	[895]		= GetString("Determined (no icon)"),
	[11641]		= GetString("Determined (no icon)"),
	[757]		= GetString("Invulnerable"),
	[903]		= GetString("Righteous Indignation"),
	[36143]		= GetString("Destruction Immunity"),
	[29065]		= GetString("Tough Hide"),
}

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_buff:initialize()
	self.target = 1
	self.operator = 1
	self.buff = 743
end
-- Save  the condition data into a table and returns that
function sm_condition_buff:Save()
	local data = {}
	data.class = 'Buff'
	data.target = self.target
	data.operator = self.operator
	data.buff = self.buff
	return data
end
-- Loads the condition data into this instance
function sm_condition_buff:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.buff = data.buff or 743
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buff:Evaluate(player,target)
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = player.buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
		
		if ( table.valid(buffs) ) then			
			if ( self.operator == 1 ) then return buffs[self.buff] ~= nil
			elseif ( self.operator == 2 ) then return buffs[self.buff] == nil
			end
		else
			ml_error("[SkillManager] - sm_condition_buff:Evaluate: Invalid Buff table")
		end
	else
		ml_error("[SkillManager] - sm_condition_buff:Evaluate: Invalid arguments received")
	end	
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_buff:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_buff"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_buff2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(200)
	GUI:SameLine()
	self.buff, changed = GUI:Combo("##sm_condition_buff3"..tostring(id),self.buff, self.buffs)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_buff) -- register this condition in the SM



-- Single Custom Buff ID check condition
local sm_condition_buffid = class('Buff (ID)', sm_condition)
sm_condition_buffid.targets = { [1] = GetString("Player"), [2] = GetString("Target"),  }
sm_condition_buffid.operators = { [1] = GetString("has Buff ID"), [2] = GetString("has not Buff ID"), }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_buffid:initialize()
	self.target = 1
	self.operator = 1
	self.buffid = 743
end
-- Save  the condition data into a table and returns that
function sm_condition_buffid:Save()
	local data = {}
	data.class = 'Buff (ID)'
	data.target = self.target
	data.operator = self.operator
	data.buffid = self.buffid
	return data
end
-- Loads the condition data into this instance
function sm_condition_buffid:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.buffid = data.buffid or 743
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buffid:Evaluate(player,target)
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = player.buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
		
		if ( table.valid(buffs) ) then			
			if ( self.operator == 1 ) then return buffs[self.buffid] ~= nil
			elseif ( self.operator == 2 ) then return buffs[self.buffid] == nil
			end
		else
			ml_error("[SkillManager] - sm_condition_buffid:Evaluate: Invalid Buff table")
		end
	else
		ml_error("[SkillManager] - sm_condition_buffid:Evaluate: Invalid arguments received")
	end	
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_buffid:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_buffid"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_buffid2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(200)
	GUI:SameLine()	
	self.buffid, changed = GUI:InputInt("##sm_condition_buffid3"..tostring(id),self.buffid, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_buffid) -- register this condition in the SM
