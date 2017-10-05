-- Entities_In_Range check condition
local sm_condition_entitycount = class('Casting (ID)', sm_condition)
sm_condition_entitycount.uid = "Casting (ID)"
sm_condition_entitycount.targets = { [1] = GetString("Target"), [2] = GetString("Player") , [3] = GetString("Friend") }
function sm_condition_entitycount:initialize(data)	
	self.target = data.target or 1
	self.skillid = data.skillid or 1
end
function sm_condition_entitycount:Save()
	local data = {}	
	data.target = self.target
	data.skillid = self.skillid
	return data
end
function sm_condition_entitycount:Evaluate(skill,context)	
	local castinfo
	if ( self.target == 1 and context.attack_target ) then
		castinfo = context.attack_target.castinfo
	elseif ( self.target == 2 and context.player ) then
		castinfo = context.player.castinfo
	elseif ( self.target == 3 and context.heal_target ) then
		castinfo = context.heal_target.castinfo
	end
	return castinfo and castinfo.skillid and castinfo.skillid == self.skillid	
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_entitycount:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:PushItemWidth(100)
	self.target, changed = GUI:Combo("##sm_condition_iscastingid1"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text("is casting Skill ID ")
		
	GUI:PushItemWidth(150)
	GUI:SameLine()
	self.skillid, changed = GUI:InputInt("##sm_condition_iscastingid2"..tostring(id),self.skillid, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if(self.skillid < 0 ) then self.skillid = 0 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()

	return modified
end
SkillManager:AddCondition(sm_condition_entitycount)
