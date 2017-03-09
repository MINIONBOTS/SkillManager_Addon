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
	self.value, changed = GUI:InputInt("##sm_condition_hp4"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal)
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
	self.value, changed = GUI:InputInt("##sm_condition_power3"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal)
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
	self.value, changed = GUI:InputInt("##sm_condition_endurance3"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal)
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