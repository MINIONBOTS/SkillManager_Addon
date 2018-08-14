-- Single Buff check condition
local sm_condition_buff = class('Buff (Name)', sm_condition)
sm_condition_buff.uid = "Buff (Name)"
sm_condition_buff.targets = { [1] = GetString("Target"), [2] = GetString("Player"), [3] = GetString("Friend"), }
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
function sm_condition_buff:initialize(data)
	self.target = data.target or 1
	self.operator = data.operator or 1
	self.buff= data.buff or 743
end
-- Save  the condition data into a table and returns that
function sm_condition_buff:Save()
	local data = {}
	data.target = self.target
	data.operator = self.operator
	data.buff = self.buff
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_buff:Evaluate(skill,context)
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
SkillManager:AddCondition(sm_condition_buff) 