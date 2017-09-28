-- This template holds the renderfuncs etc. for the skillpelettes

sm_skillpalette = class('sm_skillpalette')
sm_skillpalette.table = _G["table"]

-- this function is automatically called when a new "instance" of the class('..') is created with sm_skill:new(...)
function sm_skillpalette:initialize(data)
	if ( data ~= nil ) then
		for i,k in pairs(data) do
			self[i] = k
		end
	end
end

-- To Draw the Icon of this palette in the skill palette selector. Returns the selected palette UID
function sm_skillpalette:RenderIcon(currentselectedsetuid)
	local result
	local highlighted
	if ( currentselectedsetuid and self.uid == currentselectedsetuid ) then
		GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
		highlighted = true
	end
	if (self.icon and FileExists(sm_mgr.iconpath.."\\"..self.icon..".png") ) then
		result = GUI:ImageButton("##"..self.uid, sm_mgr.iconpath.."\\"..self.icon..".png",40,40)
	else
		sm_webapi.getimage( self.id, sm_mgr.iconpath.."\\"..self.icon..".png" )
		result = GUI:ImageButton("##"..self.uid, sm_mgr.iconpath.."\\default.png",40,40)
	end
	if ( highlighted ) then GUI:PopStyleColor(3) end
	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString(self.uid)) end
	return result
end

-- To Draw the Skills in the Skill Palette Editor Window. Returns the selected skill ID
function sm_skillpalette:RenderSkills(currentselectedid)	
	if ( self.skills_luacode ) then
		local skilldata
		if ( type(self.skills_luacode) == "table" ) then
			skilldata = self.skills_luacode			
		else
			ml_error("TODO: ADD STRING LOAD HANDLER FOR PUBLIC SKILL SETS  IN sm_skillpalette:RenderSkills")
			
		end
		if ( skilldata ) then
			-- copy / save the key in the table value
			for i,s in pairs(skilldata) do
				s.id = i
			end
			for i,s in sm_skillpalette.table.pairsByValueAttribute(skilldata, "icon") do
				local highlighted
				if ( currentselectedid and i == currentselectedid ) then
					GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
					GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
					GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
					GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
					highlighted = true
				end
				local selected
				if (s.icon and FileExists(sm_mgr.iconpath.."\\"..s.icon..".png") ) then
					selected = GUI:ImageButton("##"..tostring(i), sm_mgr.iconpath.."\\"..s.icon..".png",30,30)
				
				else					
					sm_webapi.getimage( s.id, sm_mgr.iconpath.."\\"..s.icon..".png" )
					selected = GUI:ImageButton("##"..tostring(i), sm_mgr.iconpath.."\\default.png",30,30)
				end
				if ( selected ) then currentselectedid = i end
				if ( highlighted ) then GUI:PopStyleColor(4) end
				if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString(s.icon)) end
				GUI:SameLine()
				local x,y = GUI:GetCursorPos()
				GUI:SetCursorPos(x,y+10)
				GUI:Text(GetString(s.icon))
				x,y = GUI:GetCursorPos()
				GUI:SetCursorPos(x,y-10)
			end
		end
	end
	return currentselectedid
end

-- Returns a new instance of sm_skill with the data from this palette
function sm_skillpalette:GetSkillData( id ) 
	if ( self.skills_luacode ) then
		local skilldata
		if ( type(self.skills_luacode) == "table" ) then
			skilldata = self.skills_luacode			
		else
			ml_error("TODO: ADD STRING LOAD HANDLER FOR PUBLIC SKILL SETS  IN sm_skillpalette:GetSkill")
			
		end
		if ( skilldata ) then
			local data = {}
			for i,k in pairs (skilldata[id]) do
				data[i] = k
			end
			data.id = id
			data.skillpalette = self
			data.skillpaletteuid = self.uid
			return data
		end
	end
end

function sm_skillpalette:IsActive()
	ml_error("Implement a 'function sm_skillpalette:IsActive()' in your SkillPalette : "..tostring(self.uid))
	return false
end
function sm_skillpalette:CanActivate()
	ml_error("Implement a 'function sm_skillpalette:CanActivate()' in your SkillPalette : "..tostring(self.uid))
	return false
end
function sm_skillpalette:Activate()
	ml_error("Implement a 'function sm_skillpalette:Activate()' in your SkillPalette : "..tostring(self.uid))
end
function sm_skillpalette:Deactivate()
end