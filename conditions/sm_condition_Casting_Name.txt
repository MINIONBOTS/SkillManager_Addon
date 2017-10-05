-- Entities_In_Range check condition
local sm_condition_entitycount = class('Casting (Name)', sm_condition)
sm_condition_entitycount.uid = "Casting (Name)"
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
	self.target, changed = GUI:Combo("##sm_condition_iscasting1"..tostring(id),self.target, self.targets)
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	
	GUI:SameLine()
	GUI:Text("is casting ")
		
	GUI:PushItemWidth(250)
	GUI:SameLine()
	local slist = {}
	local idlist = {}		-- HOLY FUCK !? IS THERE NO FUCKING WAY TO SORT THIS CRAP BY NAME WITHOUT LOOSING THE ID !? JESUS CHRIST LUA 
	local idx = 1	
	for i,k in table.pairsByValueAttribute(SkillManager.skilllist, "name") do
		slist[i] = k.name
		idlist[i] = k.id
		if(k.id == self.skillid) then
			idx = i
		end
	end	
	idx, changed = GUI:Combo("##sm_condition_iscasting2"..tostring(id),idx, slist)
	if ( changed ) then modified = true end	
	self.skillid = idlist[idx]
	GUI:PopItemWidth()

	return modified
end
SkillManager:AddCondition(sm_condition_entitycount)
