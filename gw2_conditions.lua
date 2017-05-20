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
function sm_condition:Evaluate(context)
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
function sm_condition_hp:Evaluate(context)
	local player = context.player
	local target = context.target
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
function sm_condition_power:Evaluate(context)
	local player = context.player
	local target = context.target
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
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_power:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(200)
	GUI:InputText("##sm_condition_power1"..tostring(id), GetString("Player Power Percent"),GUI.InputTextFlags_ReadOnly)
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
function sm_condition_endurance:Evaluate(context)
	local player = context.player
	local target = context.target
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
	end
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_endurance:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(200)
	GUI:InputText("##sm_condition_endurance1"..tostring(id), GetString("Player Endurance Percent"),GUI.InputTextFlags_ReadOnly)
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
function sm_condition_combatstate:Evaluate(context)
	local player = context.player
	local target = context.target
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
function sm_condition_movement:Evaluate(context)
	local player = context.player
	local target = context.target
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
local sm_condition_buffs = class('Buffs (Count)', sm_condition)
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
	data.class = 'Buffs (Count)'
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
function sm_condition_buffs:Evaluate(context)
	local player = context.player
	local target = context.target
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = ml_global_information.Player_Buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
		
		if ( table.valid(buffs) ) then
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
SkillManager:AddCondition(sm_condition_buffs) -- register this condition in the SM




-- Single Buff check condition
local sm_condition_buff = class('Buff (Name)', sm_condition)
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
	[37211]		= GetString("Frostbite"),
	[13017]		= GetString("Stealth"),
	[26142]		= GetString("Stealth2"),
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
	data.class = 'Buff (Name)'
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
function sm_condition_buff:Evaluate(context)
	local player = context.player
	local target = context.target
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = ml_global_information.Player_Buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
				
		if ( self.operator == 1 and table.valid(buffs) ) then return buffs[self.buff] ~= nil
		elseif ( self.operator == 2 and table.valid(buffs) ) then return buffs[self.buff] == nil
		end
		return false
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
function sm_condition_buffid:Evaluate(context)
	local player = context.player
	local target = context.target
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local buffs
		if ( self.target == 1 ) then 
			buffs = ml_global_information.Player_Buffs
		elseif ( self.target == 2 ) then
			buffs = target.buffs
		end
		
		if ( table.valid(buffs) ) then			
			if ( self.operator == 1 ) then return buffs[self.buffid] ~= nil
			elseif ( self.operator == 2 ) then return buffs[self.buffid] == nil
			end
		else
			return false
		end
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
SkillManager:AddCondition(sm_condition_buffid) -- register this condition in the SM



-- Cooldown condition
local sm_condition_cooldown = class('Cooldown', sm_condition)
sm_condition_cooldown.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }

-- Initialize new class, - gets called when :new(..) is called
function sm_condition_cooldown:initialize()
	self.skillid = 1
	self.operator = 1
	self.value = 50
end
-- Save  the condition data into a table and returns that
function sm_condition_cooldown:Save()
	local data = {}
	data.class = 'Cooldown'
	data.skillid = self.skillid
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_cooldown:Load(data)
	self.skillid = data.skillid or 1
	self.operator = data.operator or 1
	self.value = data.value or 50
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_cooldown:Evaluate(context)
	local cooldownlist = context.cooldownlist
	if ( cooldownlist == nil) then return true end
	if ( self.skillid == nil or type(self.skillid) ~= "number" ) then ml_error("[SkillManager] - sm_condition_cooldown:Evaluate: skill ID is invalid") return true end
	if ( self.value == nil or type(self.value) ~= "number" ) then ml_error("[SkillManager] - sm_condition_cooldown:Evaluate: cooldown value is invalid") return true end
	
	local cd = 0
	if ( cooldownlist[self.skillid] ) then
		cd = cooldownlist[self.skillid].cd
	end
					
	if ( self.operator == 1 ) then return cd < self.value 
	elseif ( self.operator == 2 ) then return cd <= self.value 
	elseif ( self.operator == 3 ) then return cd == self.value 
	elseif ( self.operator == 4 ) then return cd >= self.value
	elseif ( self.operator == 5 ) then return cd > self.value		
	end	
end

-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_cooldown:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Cooldown of Skill ID"))
	GUI:SameLine()
	
	GUI:PushItemWidth(100)
	self.skillid, changed = GUI:InputInt("##sm_condition_cooldown1"..tostring(id),self.skillid, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	GUI:PopItemWidth()	
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_cooldown2"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_cooldown3"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text(GetString("milliseconds."))
	
	
	return modified
end
SkillManager:AddCondition(sm_condition_cooldown) -- register this condition in the SM



-- Breakbar condition
local sm_condition_breakbar = class('Breakbar', sm_condition)
sm_condition_breakbar.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_breakbar:initialize()
	self.operator = 1
	self.value = 50
end
-- Save  the condition data into a table and returns that
function sm_condition_breakbar:Save()
	local data = {}
	data.class = 'Breakbar'
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_breakbar:Load(data)
	self.operator = data.operator or 1
	self.value = data.value or 50
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_breakbar:Evaluate(context)
	local cooldownlist = context.cooldownlist
	if ( cooldownlist == nil) then return true end
	if ( self.value == nil or type(self.value) ~= "number" ) then ml_error("[SkillManager] - sm_condition_breakbar:Evaluate: breakbar value is invalid") return true end
	
	local target = context.target
	if ( target ) then
		local bb = target.breakbarpercent*100  -- is originally a value between 0 and 1
		if ( self.operator == 1 ) then return bb < self.value 
		elseif ( self.operator == 2 ) then return bb <= self.value 
		elseif ( self.operator == 3 ) then return bb == self.value 
		elseif ( self.operator == 4 ) then return bb >= self.value
		elseif ( self.operator == 5 ) then return bb > self.value		
		end	
	end
	return false
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_breakbar:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Target's Breakbar is"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_breakbar1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_breakbar2"..tostring(id),self.value, 1,2,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 100 ) then self.value = 100 end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text(GetString("Percent."))	
	
	return modified
end
SkillManager:AddCondition(sm_condition_breakbar) -- register this condition in the SM




-- Distance condition
local sm_condition_distance = class('Distance', sm_condition)
sm_condition_distance.operators = { [1] = "<", [2] = "<=", [3] = "==", [4] = ">=", [5] = ">",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_distance:initialize()
	self.operator = 1
	self.value = 500
end
-- Save  the condition data into a table and returns that
function sm_condition_distance:Save()
	local data = {}
	data.class = 'Distance'
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_distance:Load(data)
	self.operator = data.operator or 1
	self.value = data.value or 500
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_distance:Evaluate(context)
	local cooldownlist = context.cooldownlist
	if ( cooldownlist == nil) then return true end
	if ( self.value == nil or type(self.value) ~= "number" ) then ml_error("[SkillManager] - sm_condition_distance:Evaluate: breakbar value is invalid") return true end
	
	local target = context.target
	if ( target ) then
		local bb = target.distance
		if ( self.operator == 1 ) then return bb < self.value 
		elseif ( self.operator == 2 ) then return bb <= self.value 
		elseif ( self.operator == 3 ) then return bb == self.value 
		elseif ( self.operator == 4 ) then return bb >= self.value
		elseif ( self.operator == 5 ) then return bb > self.value		
		end	
	end
	return false
end
function sm_condition_distance:Render(id)
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Target Distance is"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_distance1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_distance2"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	if ( self.value < 0 ) then self.value = 0 end
	if ( self.value > 10000 ) then self.value = 10000 end
	GUI:PopItemWidth()
		
	return modified
end
SkillManager:AddCondition(sm_condition_distance) -- register this condition in the SM



-- ContentID condition
local sm_condition_contentid = class('ContentID', sm_condition)
sm_condition_contentid.operators = { [1] = "==", [2] = "~=",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_contentid:initialize()
	self.operator = 1
	self.value = 1
end
-- Save  the condition data into a table and returns that
function sm_condition_contentid:Save()
	local data = {}
	data.class = 'Distance'
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Loads the condition data into this instance
function sm_condition_contentid:Load(data)
	self.operator = data.operator or 1
	self.value = data.value or 1
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_contentid:Evaluate(context)
	local cooldownlist = context.cooldownlist
	if ( cooldownlist == nil) then return true end
	if ( self.value == nil or type(self.value) ~= "number" ) then ml_error("[SkillManager] - sm_condition_contentid:Evaluate: breakbar value is invalid") return true end
	
	local target = context.target
	if ( target ) then
		local bb = target.distance
		if ( self.operator == 1 ) then return bb == self.value 
		elseif ( self.operator == 2 ) then return bb ~= self.value 	
		end	
	end
	return false
end
function sm_condition_contentid:Render(id)
	local modified
	local changed
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Target's Content ID is"))
	GUI:SameLine()
	
	GUI:PushItemWidth(50)
	GUI:SameLine()
	self.operator, changed = GUI:Combo("##sm_condition_contentid1"..tostring(id),self.operator, self.operators)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
		
	GUI:PushItemWidth(120)
	GUI:SameLine()	
	self.value, changed = GUI:InputInt("##sm_condition_contentid2"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
	if ( changed ) then modified = true end
	if ( self.value < 0 ) then self.value = 0 end
	GUI:PopItemWidth()
		
	return modified
end
SkillManager:AddCondition(sm_condition_contentid) -- register this condition in the SM



-- Aggro Condition
local sm_condition_aggro = class('Aggro', sm_condition)
sm_condition_aggro.targets = { [1] = GetString("Player"), [2] = GetString("Target"),  }
sm_condition_aggro.operators = { [1] = GetString("has Aggro"), [2] = GetString("has not Aggro"), }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_aggro:initialize()
	self.target = 1
	self.operator = 1
end
-- Save  the condition data into a table and returns that
function sm_condition_aggro:Save()
	local data = {}
	data.class = 'Aggro'
	data.target = self.target
	data.operator = self.operator
	return data
end
-- Loads the condition data into this instance
function sm_condition_aggro:Load(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_aggro:Evaluate(context)
	local player = context.player
	local target = context.target
	if ( player ~= nil) then
		-- This Check is set to a Target, check if we have one, else return false
		if ( self.target == 2 and target == nil ) then return false end
				
		local value
		if ( self.target == 1 ) then 
			value = player.isaggro
		elseif ( self.target == 2 ) then
			value = target.isaggro
		end
				
		if ( self.operator == 1 and table.valid(buffs) ) then return value == true
		elseif ( self.operator == 2 and table.valid(buffs) ) then return value == false
		end
		return false
	end	
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
SkillManager:AddCondition(sm_condition_aggro) -- register this condition in the SM