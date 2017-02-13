-- this file holds all condition class definitions used for the gw2 condition builder in the skills

-- Empty Condition template class
local sm_condition = class('sm_condition')
sm_condition.type = 0		-- unique type to identify the "kind" of condition
-- Initialize new class, - gets called when :new(..) is called
function sm_condition:initialize(...)	
	
end
-- Evaluates the condition, returns "true" / "false". The first arg passed is always the Player table, 2nd the Target (can be nil, so check for it!)
function sm_condition:Evaluate(...)	

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
function sm_condition_hp:initialize(...)
	if ( table.valid(arg) and table.size(arg) >= 4 and type(arg[1]) == "number" and type(arg[2]) == "number" and type(arg[3]) == "number" and type(arg[4]) == "number") then
		self.target = arg[1]
		self.operator = arg[2]
		self.healthtype = arg[3]
		self.value = arg[4]

	else
		self.target = 1
		self.operator = 1
		self.healthtype = 3
		self.value = 100
		d("[SkillManager] - New Health Condition created")
	end	
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_hp:Evaluate(...)	-- Player, Target, ... others	
	if ( arg[1] ~= nil) then
		-- This Health Check is set to check HP on a Target, check if we have one, else return false
		if ( self.target == 2 and arg[1] == nil ) then return false end
				
		local hp
		if ( self.target == 1 ) then 
			hp = arg[1].health
		elseif ( self.target == 2 ) then
			hp = arg[2].health
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
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
end
SkillManager:AddCondition(sm_condition_hp)