-- ContentID condition
local sm_condition_contentid = class('ContentID', sm_condition)
sm_condition_contentid.uid = "ContentID"
sm_condition_contentid.operators = { [1] = "==", [2] = "~=",  }
-- Initialize new class, - gets called when :new(..) is called
function sm_condition_contentid:initialize(data)
	self.operator = data.operator or 1
	self.value = data.value or 1
end
-- Save  the condition data into a table and returns that
function sm_condition_contentid:Save()
	local data = {}
	data.operator = self.operator
	data.value = self.value
	return data
end
-- Evaluates the condition, returns "true" / "false"
function sm_condition_contentid:Evaluate(skill,context)
	if ( context.attack_target ) then
		local bb = context.attack_target.contentid
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
SkillManager:AddCondition(sm_condition_contentid)