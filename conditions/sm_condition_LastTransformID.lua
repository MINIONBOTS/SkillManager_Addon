-- Endurance check condition
local sm_condition_transformid = class('Last Transform ID', sm_condition)
sm_condition_transformid.uid = "Last Transform ID"
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_transformid:initialize(data)
	self.value = data.value or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_transformid:Save()
	local data = {}
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_transformid:Evaluate(skill,context)
	return context.player and context.player.transformid == self.value
end
-- Renders the condition data into UI, for "presentation" in the SkillManager's Condition Builder. Returns "true" when stuff changed, for saving
function sm_condition_transformid:Render(id) -- need to pass an index value here, for the unique IDs used by imgui	
	local modified
	local changed
	GUI:Text(GetString("Last Transform ID is "))
	
	GUI:PushItemWidth(100)
	GUI:SameLine()
	self.value, changed = GUI:InputInt("##sm_condition_wpid"..tostring(id),self.value, 1,10,GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)
	if ( self.value < 0 ) then self.value = 0 end
	if ( changed ) then modified = true end
	GUI:PopItemWidth()
	return modified
end
SkillManager:AddCondition(sm_condition_transformid) 