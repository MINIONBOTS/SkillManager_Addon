-- Skill class for the Skill Manager Profile, holding info for a single skill. Responsible for rendering the initial selection of a skill ID and the condition editor.
local table = _G["table"]
local string = _G["string"]
sm_skill = class('sm_skill')

-- this function is automatically called when a new "instance" of the class('..') is created with sm_skill:new(...)
function sm_skill:initialize(data)
	self.conditions = {}
	self.condition_luacode = "return true"
	if ( data ~= nil ) then
		for i,k in pairs(data) do
			if ( i ~= "conditions" and i~= "skill_next") then
				self[i] = k
			end
		end
		-- Get the most recent data from the skillIDs from skillpalette and c++
		if ( sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][data.skillpaletteuid] ) then
			local freshdata = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][data.skillpaletteuid]:GetSkillData(data.id)
			if(table.valid(freshdata)) then
				for i,k in pairs(freshdata) do
					if(i == "activationtime" or i == "instantcast" or i == "stopsmovement") then
						if(self[i] == nil) then self[i] = k end
					else
						self[i] = k
					end
				end
			else
				ml_error("[SkillManager] - Could not find Skill ID "..tostring(data.id).." in SkillPalette: "..tostring(data.skillpaletteuid)..". Skill IDs Changed !?.")
			end			
		else
			ml_error("[SkillManager] - Could not load SkillPalette: "..tostring(data.skillpaletteuid)..". You are probably missing an addon or some files.")
		end
		
		-- Load Conditions
		if(data.conditions) then
			for i,grp in pairs(data.conditions) do
				self.conditions[i] = {}
				for j,k in pairs (grp) do
					if (j ~= "casttarget" ) then
						if ( sm_mgr.conditions[k.uid] ) then
							self.conditions[i][k] = sm_mgr.conditions[k.uid]:new(k)
						else
							ml_error("[SkillManager] - Could not load Condition: "..tostring(k.uid)..". You are probably missing an addon or some files.")
						end
					end
				end
				self.conditions[i].casttarget = grp.casttarget
			end
		end
		-- Load combo skills
		if (data.skill_next) then
			self.skill_next = sm_skill:new(data.skill_next)
			self.skill_next.skill_prev = self
		end
	end
	self.temp = {}
end
-- erases all data but the actual class
function sm_skill:Clear()
	for i,k in pairs(self) do
		if ( i ~= "class" ) then
			self[i] = nil
		end
	end
	self.conditions = {}
	self.temp = {}
end

-- Flies to the fucking moon
function sm_skill:Save()
	local copy = {}
	copy.id = self.id
	copy.skillpaletteuid = self.skillpaletteuid
	copy.setsattackrange = self.setsattackrange
	copy.requireslos = self.requireslos -- or true
	copy.activationtime = self.activationtime
	copy.instantcast = self.instantcast
	copy.stopsmovement = self.stopsmovement
	copy.condition_luacode = self.condition_luacode
	copy.conditions = {}
	local gidx = 0
	for i,grp in pairs(self.conditions) do
		gidx = gidx + 1
		copy.conditions[gidx] = {}
		local cidx = 0
		for j,k in pairs(grp) do
			if ( j ~= "casttarget" ) then
				cidx = cidx + 1
				copy.conditions[gidx][cidx] = k:Save()
				copy.conditions[gidx][cidx].uid = k.uid
			end
		end
		copy.conditions[gidx].casttarget = grp.casttarget
	end
	if ( self.skill_next ) then
		copy.skill_next = self.skill_next:Save()
	end
	-- recompile condition code
	 self.temp.condition_luacode_compiled = nil
	 self.temp.condition_luacode_bugged = nil
	return copy
end

-- Renders the Skill Editor Window
function sm_skill:Render()	
	local skill = self
	while ( skill ) do
		if ( skill.id == nil ) then
			skill:RenderSkillPaletteEditor()
			return
		else
			skill = skill.skill_next
		end
	end
	self:RenderSkillEditor()
end

-- Renders all SkillPalettes / skill sets, to pick a skill from
function sm_skill:RenderSkillPaletteEditor()	
	GUI:SetNextWindowSize(500,600,GUI.SetCond_Always)
	--GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
	self.temp.editorvisible, self.temp.editoropen = GUI:Begin(GetString("Skill Set Editor").."##smpeditor", self.temp.editoropen or true,GUI.WindowFlags_NoResize)
	if (self.temp.editoropen) then
		if (self.temp.editorvisible) then -- unfolded
			GUI:PushStyleVar(GUI.StyleVar_FramePadding, 2, 2)
			-- Left sided Skill Set group
			local c = 0
			GUI:BeginChild("##spe_group",120,0, true)											
				if ( sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()] ~= nil ) then
					for i,p in sm_skillpalette.table.pairsByValueAttribute(sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()], "uid") do
						if ( c == 1 ) then 
							GUI:SameLine() 
							c = 0 
						else
							c = c + 1
						end
						if ( p:RenderIcon(self.temp.currentskillset) ) then -- icon was clicked
							-- get the real "key" and not the one from the "sorted list" above...silly cpu usage but who cares							
							for i,w in pairs(sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()]) do
								if ( i == p.uid ) then
									self.temp.currentskillset = i
									self.temp.currentskillid = nil
								end
							end							
						end
					end
				end
			GUI:EndChild()			
			
			-- Right upper sided Skill Set- Skills
			if ( self.temp.currentskillset ) then
				GUI:SameLine()
				local _,y = GUI:GetContentRegionAvail()
				GUI:BeginChild("##spe_setskills",0,y - 25, true)
					local title = string.gsub(self.temp.currentskillset, "_", " ")
					GUI:Text(title)
					self.temp.currentskillid = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][self.temp.currentskillset]:RenderSkills(self.temp.currentskillid)
				GUI:EndChild()
			else
				GUI:SameLine()
				local _,y = GUI:GetContentRegionAvail()
				GUI:Dummy(0, y - 25)
			end
			
			local x,y = GUI:GetWindowSize()
			GUI:SetCursorPos(self.temp.currentskillid and x - 250 or x - 200, y-27)
			-- Render Skill Details
			if( self.temp.currentskillid ) then

				if ( GUI:Button(GetString("Select Skill"), 100, 0) ) then
					-- copy the skillset data of the skill we picked into the action of ours					
					local data = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][self.temp.currentskillset]:GetSkillData(self.temp.currentskillid)
					local tmpnext = self.skill_next
					local tmpprev = self.skill_prev
					self:Clear()
					self.condition_luacode = "return true"
					if ( data ~= nil ) then
						for i,k in pairs(data) do
							self[i] = k
						end
					end
					self.skill_next = tmpnext
					self.skill_prev = tmpprev
					if ( self.slot >= GW2.SKILLBARSLOT.Slot_1 and self.slot <= GW2.SKILLBARSLOT.Slot_5 ) then
						self.setsattackrange = true
					end
					if ( not sm_mgr.profile.temp.activeskillpalettes ) then sm_mgr.profile.temp.activeskillpalettes = {} end
					if ( not sm_mgr.profile.temp.activeskillpalettes[self.skillpaletteuid] ) then
						sm_mgr.profile.temp.activeskillpalettes[self.skillpaletteuid] = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][self.skillpaletteuid]
					end
					sm_mgr.profile.temp.modified = true
				end
				GUI:SameLine()
			end

			if(GUI:Button(GetString("Cancel"), 100, 0)) then
				if(not self.temp.oldid) then
					sm_mgr.profile.actionlist[sm_mgr.profile.temp.selectedactionidx] = nil
				else
					self:CloseSkillPaletteEditor()
				end
				sm_mgr.profile.temp.selectedactionidx = nil
				sm_mgr.profile.temp.selectedaction = nil
			end
			GUI:PopStyleVar()
		end
	else
		-- someone pressed the X to close"
		self:CloseSkillPaletteEditor()
	end	
	GUI:End()
end

function sm_skill:CloseSkillPaletteEditor()	
	if ( not self.id and self.temp.oldid ) then self.id = self.temp.oldid end
	self.temp.oldid = nil
	self.temp.deleteaction = nil	
end

-- Renders skill information and condition editor
function sm_skill:RenderSkillEditor()
	GUI:SetNextWindowSize(600,600,GUI.SetCond_Always)
	--GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
	self.temp.editorvisible, self.temp.editoropen = GUI:Begin(GetString("Skill Editor").."##smpeditor", self.temp.editoropen or true,GUI.WindowFlags_NoResize)
	if (self.temp.editoropen) then
		if (self.temp.editorvisible) then -- unfolded
			
			-- Top Bar showing Skill Icon(s) / Combo List
			GUI:BeginChild("##spe_skillgroup",585,85,false,GUI.WindowFlags_ForceHorizontalScrollbar)
			if ( not self.temp.currentskill ) then self.temp.currentskill = self end
			local skill = self
			local counter = 0
			while ( skill and skill.id ) do
				counter = counter + 1
				GUI:BeginGroup()
					if ( skill:RenderIcon(self.temp.currentskill == skill, counter) ) then
						self.temp.currentskill.temp.deleteaction = nil
						self.temp.currentskill = skill
					end
					GUI:SameLine()
					if(skill.skill_next) then
						-- We are not at the last skill combo yet
						GUI:ImageButton("##"..skill.id, sm_mgr.texturepath.."\\next.png",8,40)
					else
						-- Draw an empty Placeholder to allow adding a combo/flip skill						
						if ( GUI:ImageButton("##skillnewcombo",sm_mgr.texturepath.."\\addon.png",40,40) ) then
							skill.skill_next = sm_skill:new()
							skill.skill_next.skill_prev = skill
						end
						if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add another Combo-Skill.")) end
					end
					if ( GUI:Button(GetString("Change##"..tostring(counter)))) then
						skill.temp.oldid = skill.id
						skill.id = nil
						sm_mgr.profile.temp.modified = true
					end
				GUI:EndGroup()
				if(skill.skill_next and skill.skill_next.id) then
					GUI:SameLine()
				end
				skill = skill.skill_next
			end	
			GUI:EndChild()
			
			
			-- Middle Part, showing hardcoded Skill Details
			if(self.temp.context) then
				self.temp.currentskill:RenderHardcodedSkillDetails()
			end
			-- Delete Button
			GUI:SameLine(GUI:GetContentRegionAvailWidth()-15)
			local highlighted
			if ( self.temp.currentskill.temp.deleteaction ) then 	GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7) GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8) GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9) highlighted = true 	end					
			if ( GUI:ImageButton("##delaction",sm_mgr.texturepath.."\\w_delete.png",13,13)) then
				if ( not self.temp.currentskill.temp.deleteaction ) then self.temp.currentskill.temp.deleteaction = 1 else self.temp.currentskill.temp.deleteaction = 2	end
			end
			if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Delete this Skill.")) end
			if ( highlighted ) then GUI:PopStyleColor(3) end
			
			-- Lower Part, Condition Editor
			self.temp.currentskill:RenderConditionEditor()
			
			-- Bottom, Condition Code Editor
			self.temp.currentskill:RenderCustomConditionEditor()
			
			-- Finally remove the skill if irequested
			if(self.temp.currentskill.temp.deleteaction and self.temp.currentskill.temp.deleteaction == 2) then
				
				if ( not self.temp.currentskill.skill_prev ) then
					if ( self.temp.currentskill.skill_next ) then
						self.temp.currentskill.skill_next.skill_prev = nil
						sm_mgr.profile.actionlist[sm_mgr.profile.temp.selectedactionidx] = self.temp.currentskill.skill_next
						sm_mgr.profile.temp.selectedaction = self.temp.currentskill.skill_next
					else
						sm_mgr.profile.actionlist[sm_mgr.profile.temp.selectedactionidx] = nil
						sm_mgr.profile.temp.selectedactionidx = nil
						sm_mgr.profile.temp.selectedaction = nil
					end
					
				else
					if ( self.temp.currentskill.skill_next ) then
						self.temp.currentskill.skill_prev.skill_next = self.temp.currentskill.skill_next
						self.temp.currentskill.skill_next.skill_prev = self.temp.currentskill.skill_prev						
					else
						self.temp.currentskill.skill_prev.skill_next = nil
					end					
				end	
				self.temp.currentskill = nil
				sm_mgr.profile.temp.modified = true
			end
		end
	else
		-- someone pressed the X to close 
		self.temp.currentskill.temp.deleteaction = nil
		sm_mgr.profile.temp.selectedactionidx = nil
		sm_mgr.profile.temp.selectedaction = nil
	end	
	GUI:End()
end

-- To Draw the Icon of this Skill
function sm_skill:RenderIcon(currentselected, counter)
	-- Render the skill line
	local clicked
	local highlighted
	if ( currentselected ) then
		GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
		highlighted = true
	end
	if (self.icon and FileExists(sm_mgr.iconpath.."\\"..self.icon..".png") ) then
		clicked = GUI:ImageButton("##"..tostring(counter), sm_mgr.iconpath.."\\"..self.icon..".png",40,40)
	else
		sm_webapi.getimage( self)
		clicked = GUI:ImageButton("##"..tostring(counter), sm_mgr.iconpath.."\\default.png",40,40)
	end
	if ( highlighted ) then GUI:PopStyleColor(3) end
	if (GUI:IsItemHovered()) then GUI:SetTooltip( self.name or self.icon) end
	return clicked	
end

-- Render a Table/List with the hardcoded skill info
function sm_skill:RenderHardcodedSkillDetails()
	GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 8, 1)
	GUI:PushStyleVar(GUI.StyleVar_FramePadding, 4, 0)
	GUI:Text(GetString("Name:")) GUI:SameLine(125) GUI:Text(tostring(self.name))
	GUI:SameLine(300)
	GUI:Text(GetString("ID:")) GUI:SameLine(425) GUI:Text(tostring(self.id))
	
	GUI:Text(GetString("Set:")) GUI:SameLine(125) GUI:Text(tostring(self.skillpaletteuid))
	GUI:SameLine(300)
	GUI:Text(GetString("IsActiveSet:")) GUI:SameLine(425) GUI:Text(tostring(self.skillpalette:IsActive(self.temp.context)))
	
	GUI:Text(GetString("CanCast:")) GUI:SameLine(125) GUI:Text(tostring(self.temp.cancast))
	GUI:SameLine(300)
	GUI:Text(GetString("CanActivateSet:")) GUI:SameLine(425) GUI:Text(tostring(self.skillpalette:CanActivate(self.temp.context)))
	
	GUI:Text(GetString("MinRange:")) GUI:SameLine(125) GUI:Text(tostring(self.minrange))
	GUI:SameLine(300)
	GUI:Text(GetString("MaxRange:")) GUI:SameLine(425) GUI:Text(tostring(self.maxrange))
	
	GUI:Text(GetString("Radius:")) GUI:SameLine(125) GUI:Text(tostring(self.radius))
	GUI:SameLine(300)	
	GUI:Text(GetString("Req.Power:")) GUI:SameLine(425) GUI:Text(tostring(self.power))
	
	GUI:Text(GetString("Cooldown:")) GUI:SameLine(125) GUI:Text(tostring(self.cooldown or 0).."/"..tostring(self.cooldownmax))
	GUI:SameLine(300)
	GUI:Text(GetString("AmmoCooldown:")) GUI:SameLine(425) GUI:Text(tostring(self.ammocooldown or 0).."/"..tostring(self.ammocooldownmax))
	
	GUI:Text(GetString("GroundTargeted:")) GUI:SameLine(125) GUI:Text(tostring(self.isgroundtargeted))
	GUI:SameLine(300)
	GUI:Text(GetString("Ammo:")) GUI:SameLine(425) GUI:Text(tostring(self.ammo or 0).."/"..tostring(self.ammomax or 0))
	
	local changed
	GUI:Text(GetString("Set AttackRange:")) GUI:SameLine(125) self.setsattackrange, changed = GUI:Checkbox("##setsattack" , self.setsattackrange or false) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, this Skill is included in defining the maximum Attackrange of the bot." )) end			
	if ( changed ) then sm_mgr.profile.temp.modified = true end
	
	GUI:SameLine(300)
	if ( self.requireslos == nil ) then self.requireslos = true end
	GUI:Text(GetString("Requires LoS:")) GUI:SameLine(425) self.requireslos, changed = GUI:Checkbox("##requireslos" , self.requireslos) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, this Skill will only be cast at the target if it is in Line of Sight." )) end			
	if ( changed ) then sm_mgr.profile.temp.modified = true end
	
	GUI:PushItemWidth(150)
	local changed
	GUI:Text(GetString("Cast Time:")) GUI:SameLine(125) self.activationtime, changed = GUI:InputFloat("##casttime" , tonumber(self.activationtime), 0.1, 0.5, 2, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("The Duration this Skill is cast. Setting this too low, can result in the Bot interrupting other Skills." )) end			
	if ( changed ) then sm_mgr.profile.temp.modified = true end
	GUI:PopItemWidth()
	
	GUI:SameLine(300)
	local changed
	if ( self.instantcast == nil ) then self.instantcast = false end
	GUI:Text(GetString("Instant Cast:")) GUI:SameLine(425) self.instantcast, changed = GUI:Checkbox("##instantcast", self.instantcast)
	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If this is Enabled, the Skill can be cast instantly 'without interrupting' the currently cast Skill." )) end			
	if ( changed ) then sm_mgr.profile.temp.modified = true end
	
	GUI:PushItemWidth(150)
	if ( self.stopsmovement == nil ) then self.stopsmovement = false end
	GUI:Text(GetString("Stops movement:")) GUI:SameLine(125) self.stopsmovement, changed = GUI:Checkbox("##stopsmovement" , self.stopsmovement or false)
	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, the bot will try not to move while casting the skill." ).."\n"..GetString("Needs to be enabled for skills that root the player in place. Like meteor shower or flurry")) end			
	if ( changed ) then sm_mgr.profile.temp.modified = true end
	
	GUI:PopItemWidth()
	
	GUI:PopStyleVar(2)
end

-- Get data from c++ and update this skill's data
function sm_skill:UpdateData(context, iscombo)
	if ( context ) then
		self.temp.context = context
		self.temp.iscombo = iscombo
		if (context.skillbar and self.id and self.slot ) then
			local skilldata
			-- Elite + Weapons 1 - 5
			if ( self.slot > 3 and self.slot < 10 ) then
				if (context.skillbar[self.slot] and context.skillbar[self.slot].id == ( self.id or self.oldid )) then
					skilldata = context.skillbar[self.slot]
				end
			-- Check for slot 555, the fictional non skill slot and set hardcoded data. TODO: make this easyer for global changes.
			elseif (self.slot == 555) then
				skilldata = {
					cooldown = 0,
					ammo = 0,
					ammomax = 0,
					ammocooldown = 0,
					cancast = true,
					
					name = (self.id == 10 and GetString("Dodge") or self.id == 20 and GetString("Swap Weaponset")),
					cooldownmax = 0,
					ammocooldownmax = 0,
					minrange = 0,
					maxrange = 0,
					radius = 0,
					power = 0,
					isgroundtargeted = false,
				}
			else
				-- Heal & Utility Slot, check all 3 slots for the skill id
				if ( self.slot <= 3 ) then
					for i=0,3 do
						if (context.skillbar[i] and context.skillbar[i].id == ( self.id or self.oldid )) then
							skilldata = context.skillbar[i]
							self.slot = i
							break
						end
					end
				
				elseif ( self.slot>=10 ) then
					for i=12,18 do
						if (context.skillbar[i] and context.skillbar[i].id == ( self.id or self.oldid )) then
							skilldata = context.skillbar[i]
							self.slot = i
							break
						end
					end			
				end
			end
			if( not skilldata) then
				skilldata = Player:GetSpellInfoByID(self.id or self.oldid)			
			end
			
			if ( skilldata ) then				
				-- This skill is equipped, update all info
				self.cooldown = skilldata.cooldown
				self.ammo = skilldata.ammo
				self.ammomax = skilldata.ammomax
				self.ammocooldown = skilldata.ammocooldown
				self.cancast = skilldata.cancast
				
				local playerLvl = Player.level
				if (playerLvl < 2 and self.slot == GW2.SKILLBARSLOT.Slot_2 and not table.valid(context.skillbar[self.slot])) or
					(playerLvl < 4 and self.slot == GW2.SKILLBARSLOT.Slot_3 and not table.valid(context.skillbar[self.slot])) or
					(playerLvl < 6 and self.slot == GW2.SKILLBARSLOT.Slot_4 and not table.valid(context.skillbar[self.slot])) or
					(playerLvl < 8 and self.slot == GW2.SKILLBARSLOT.Slot_5 and not table.valid(context.skillbar[self.slot])) or 
					(playerLvl < 11 and self.slot == GW2.SKILLBARSLOT.Slot_7 and not table.valid(context.skillbar[self.slot])) or 
					(playerLvl < 15 and self.slot == GW2.SKILLBARSLOT.Slot_8 and not table.valid(context.skillbar[self.slot])) or 
					(playerLvl < 19 and self.slot == GW2.SKILLBARSLOT.Slot_9 and not table.valid(context.skillbar[self.slot])) or 
					(playerLvl < 31 and self.slot == GW2.SKILLBARSLOT.Slot_10 and not table.valid(context.skillbar[self.slot])) then
					self.cancast = false
				end

				-- static ones, would only have to get updated once...how ?
				-- this string valid check should make it only set this static data once. ^^
				if (not string.valid(self.name)) then
					self.name = skilldata.name
					self.cooldownmax = skilldata.cooldownmax
					self.ammocooldownmax = skilldata.ammocooldownmax
					self.minrange = skilldata.minrange
					self.maxrange = skilldata.maxrange
					self.radius = skilldata.radius
					self.power = skilldata.power
					self.isgroundtargeted = skilldata.isgroundtargeted
				end
				
			else
				local id = self.id or self.oldid
				ml_warning("[SkillManager] - No Skill Data found for Skill ID "..tostring(id))
			end
		end
		
		if ( self.skill_next ) then		
			self.temp.cancast = self.skill_next:UpdateData(context,true)
		end
				
		-- Check if we can cast this spell
		self.temp.cancastflipcombo = nil
		local canCastResult = self:CanCast()
		if ( self.temp.cancast or not self.skill_next) then
			-- local cc = self:CanCast()
			self.temp.cancastflipcombo = iscombo and canCastResult and self.parent
			self.temp.cancast = canCastResult and self:IsEquipped()		
		end
		
		-- Update AttackRange	
		if ( self.setsattackrange and self.maxrange and self.maxrange > 0 and self.skillpalette:IsActive(self.temp.context)) then
			-- Set a maxattackrange and an actual activemaxattackrange
			if ( not sm_mgr.profile.temp.maxattackrange or sm_mgr.profile.temp.maxattackrange < self.maxrange ) then sm_mgr.profile.temp.maxattackrange = self.maxrange end
			if ( self.temp.cancast or (self.slot == GW2.SKILLBARSLOT.Slot_1 and canCastResult)) then
				if ( not sm_mgr.profile.temp.activemaxattackrange or sm_mgr.profile.temp.activemaxattackrange < self.maxrange ) then
					sm_mgr.profile.temp.activemaxattackrange = self.maxrange
				end
			end
		end
	end
	return self.temp.cancast or ( self.temp.cancastflipcombo ~= nil and self.temp.cancastflipcombo or false)
end

-- Take a fucking wild guess, returns true for modified conditions
function sm_skill:RenderConditionEditor()
	local _,y = GUI:GetContentRegionAvail()
	GUI:BeginChild("##sm_skillcondi",0, self.temp.customcodeeditoropen and y - 330 or y-30, true)		
	GUI:PushStyleVar(GUI.StyleVar_FramePadding, 3,0)
	GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 4, 3)
	GUI:Text(GetString("Conditions:"))	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("This Skill can be cast, when all conditions of at least one 'Group' are 'true'." )) end
	local changed
	if ( self.conditions ~= nil ) then
		for gid,grp in pairs(self.conditions) do
			GUI:SetNextTreeNodeOpened(true,GUI.SetCond_Once)
			if ( GUI:TreeNode(GetString("Group ")..tostring(gid)) ) then
				-- Cast target definer				
				GUI:PushItemWidth(100)
				GUI:Text(GetString("Cast Spell At:"))
				if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If this Condition group evaluates to 'true', the spell will be cast at the selected target. \n (Enemy == context.attack_target, Player == context.player, Friend == context.heal_target)")) end
				GUI:SameLine()
				grp.casttarget, changed = GUI:Combo("##casttarget"..tostring(gid)..""..tostring(i),grp.casttarget or 1, { [1] = GetString("Enemy"), [2] = GetString("Player"), [3] = GetString("Friend"), })
				if ( changed ) then sm_mgr.profile.temp.modified = true end
				GUI:PopItemWidth()
				for i,k in pairs(grp) do
					if ( i ~= "casttarget" ) then
						if ( k:Render(tostring(gid).."-"..tostring(i)) ) then sm_mgr.profile.temp.modified = true end
						-- Delete Button
						GUI:SameLine(GUI:GetContentRegionAvailWidth())
						local highlighted
						if ( self.temp.deletecondi and self.temp.deletecondi.grid == gid and self.temp.deletecondi.cid == i) then
							GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
							GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
							GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
							highlighted = true
						end					
						if ( GUI:ImageButton("##delcondi"..tostring(gid)..""..tostring(i),sm_mgr.texturepath.."\\w_delete.png",13,13)) then
							if ( not self.temp.deletecondi or self.temp.deletecondi.grid ~= gid or self.temp.deletecondi.cid ~= i) then 
								 self.temp.deletecondi = { grid = gid, cid = i }
							else
								grp[i] = nil
								local empty = true
								for n,m in pairs(grp) do
									if (n and m and n~= "casttarget") then
										empty = false
									end
								end
								if ( empty ) then
									self.conditions[gid] = nil
								end
								self.temp.deletecondi = nil
								sm_mgr.profile.temp.modified = true
							end
						end
						if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Delete this Condition.")) end
						if ( highlighted ) then GUI:PopStyleColor(3) end
					end
				end
				-- Add new condition to this group
				if(not self.temp.newconditiongroup and GUI:ImageButton("##andcondinew",sm_mgr.texturepath.."\\addon.png",15,15)) then		
					self.temp.newconditiongroup = gid
				end
				if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add another Condition to this Group.")) end
				if ( self.temp.newconditiongroup ~= nil and self.temp.newconditiongroup == gid ) then
					self:RenderConditionComboBox(self.temp.newconditiongroup)	
				end
				GUI:TreePop()
			end			
		end
	end
	GUI:PopStyleVar(2)
	-- Add a new Group:
	GUI:Spacing()
	if(GUI:ImageButton("##condinew",sm_mgr.texturepath.."\\addon.png",25,25)) then		
		self.temp.newcondition = true
	end
	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add a new Condition.")) end
	if ( self.temp.newcondition ~= nil ) then
		self:RenderConditionComboBox(self.temp.newcondition)	
	end
	
	GUI:EndChild()
end
-- Little helper for the above
function sm_skill:RenderConditionComboBox(groupid)
	local combolist = {}
	local i = 1
	for k,v in spairs(sm_mgr.conditions) do
		combolist[i] = k
		i = i+1
	end
	self.temp.newconditionidx = GUI:Combo("##addcondinew"..tostring(groupid),self.temp.newconditionidx or 1, combolist)
	GUI:SameLine()
	if (GUI:Button(GetString("Add").."##addnewcond"..tostring(groupid), 50,20)) then
		local condi = sm_mgr.conditions[combolist[self.temp.newconditionidx]]:new({})
		if(condi)then
			if ( type(groupid) =="boolean" ) then 
				-- Add new Group
				table.insert(self.conditions, { [1] = condi, })
				self.temp.newcondition = nil
			else
				d("-- Add new entry in Group")
				table.insert(self.conditions[groupid], condi)	
				self.temp.newconditiongroup = nil				
			end
			self.temp.newconditionidx = nil
			sm_mgr.profile.temp.modified = true
			
		else
			ml_error("[SkillManager] - No Such Condition found: "..tostring(combolist[self.temp.newcondition]))
		end
	end
end



-- Custom Lua code editor for Condition building. MUST return true/false, always!
function sm_skill:RenderCustomConditionEditor()
	local _,maxy = GUI:GetContentRegionAvail()
	if( not self.temp.customcodeeditoropen ) then 
		GUI:SetNextTreeNodeOpened(false,GUI.SetCond_Once)
	end
	if ( GUI:TreeNode(GetString("CUSTOM CONDITION LUA CODE EDITOR").."##"..tostring(self.id) )) then
		self.temp.customcodeeditoropen = true

		local x,y = GUI:GetCursorPos()
		GUI:SetCursorPos(maxy-25,y-20)		

		if ( GUI:IsItemHovered() ) then 
			local tooltip = string.gsub([[
				Additional Lua Code, when to allow this spell to be cast. Must return 'true' or 'false'!
				Use the 'self' and 'context' table which are available here: 'self.cooldown' etc. for this skill's data.
				context.player.pos instead of Player.pos, to save performance.
				Also available:
				context.player.party
				context.player.squad
				context.player.specs
				context.player.buffs
				context.player.transformid
				context.player.lasttransformid
				context.player.weaponset
				context.player.canswapweaponset
				context.player.mainhand
				context.player.mainhand_alt
				context.player.offhand
				context.player.offhand_alt
				context.player.friends_nearby
				context.player.enemies_nearby
				context.player.pet
				context.skillbar
				context.actionlist
				context.casttarget (Result from the Condition Group above that evaluated to 'true'. Overwrite this if you need (1=Enemy, 2=Player, 3=Friend)
				context.attack_targetid (CAN BE NIL) 
				context.attack_target (CAN BE NIL)
				context.attack_targetid_alt (To override)
				context.heal_targetid (CAN BE NIL)
				context.heal_target (CAN BE NIL)
				context.heal_targetid_alt (To override )
			]], "\t", "")
				
			GUI:SetTooltip(GetString(tooltip)) 
		end
		GUI:SetCursorPos(x,y)
		local maxx,_ = GUI:GetContentRegionAvail()
		local changed = false
		self.condition_luacode, changed = GUI:InputTextEditor( "##smactioncodeeditor", self.condition_luacode or "return true", maxx, math.max(maxy/2,300) , GUI.InputTextFlags_AllowTabInput)
		if ( changed ) then sm_mgr.profile.temp.modified = true  end
		GUI:PushItemWidth(600)
		GUI:Dummy(600,1)
		GUI:PopItemWidth()
		GUI:TreePop()
	else
		self.temp.customcodeeditoropen = nil
	end
	if ( not self.temp.customcodeeditoropen and GUI:IsItemHovered() ) then
		GUI:SetTooltip(GetString("Additional Lua Code, when to allow this spell to be cast. Must return 'true' or 'false'!"))
	end
end

-- To Draw the ActionList Image/Button of this Skill. Returns: image clicked, image dragged
function sm_skill:RenderActionButton(currentselectedaction,draggedaction, id1,id2)
	if( not self.id ) then return end
	if( not id2 ) then id2 = 1 end
	local combo = self.skill_prev ~= nil
	local iconsize = combo and 25 or 35

	if(combo) then 
		GUI:PushStyleVar(GUI.StyleVar_FramePadding, 1, 1)
	end
	
	local clicked,dragged,released
	if ( currentselectedaction and self == currentselectedaction ) then
		GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.85)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.92)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,1)
	elseif ( self:IsCasting() ) then
		GUI:PushStyleColor(GUI.Col_Button,1,1,1,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1,1,1,0.9)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1,1,1,1)
	elseif ( self.temp.cancast or (self.temp.cancastflipcombo and combo)) then
		GUI:PushStyleColor(GUI.Col_Button,0,1,0.2,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,0,1,0.2,0.9)
		GUI:PushStyleColor(GUI.Col_ButtonActive,0,1,0.2,1)
	else
		GUI:PushStyleColor(GUI.Col_Button,1.0,0,0.2,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0,0.2,0.9)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0,0.0,1)
	end
	local x,y = GUI:GetCursorPos()	
	if (self.icon and FileExists(sm_mgr.iconpath.."\\"..self.icon..".png") ) then
		if ( draggedaction and draggedaction == self ) then
			clicked = GUI:ImageButton("##"..tostring(self.id)..tostring(id1)..tostring(id2), sm_mgr.iconpath.."\\blank.png",iconsize,iconsize)
		else
			clicked = GUI:ImageButton("##"..tostring(self.id)..tostring(id1)..tostring(id2), sm_mgr.iconpath.."\\"..self.icon..".png",iconsize,iconsize)	
		end
	else
		sm_webapi.getimage( self)
		clicked = GUI:ImageButton("##"..tostring(self.id)..tostring(id1)..tostring(id2), sm_mgr.iconpath.."\\default.png",iconsize,iconsize)
	end
	GUI:PopStyleColor(3)
	if (GUI:IsItemHovered()) then GUI:SetTooltip( self.name or self.icon) end
	
	-- Drag n Drop to switch places
	if ( not clicked ) then	
		if ( GUI:IsItemClicked() or GUI:IsItemActive() ) then dragged = true end
		if ( GUI:IsMouseReleased(0) and (GUI:IsItemHovered() or GUI:IsItemHovered(GUI.HoveredFlags_AllowWhenBlockedByActiveItem))) then released = true end
	end
	-- Cooldown Overlay
	if ( not combo and self.cooldown and self.cooldown > 0 ) then
		--local nx,ny = GUI:GetCursorPos()	
		GUI:SetCursorPos(x,y) -- THIS IS SHIT FIX IT !!!!!
		GUI:PushStyleColor(GUI.Col_Text,1,1,1,1)
		GUI:PushStyleColor(GUI.Col_FrameBg,0,0,0,0.5)
		GUI:PushStyleColor(GUI.Col_PlotHistogram,1,1,1,0.25)
		GUI:ProgressBar( self.cooldown/self.cooldownmax, iconsize+2, iconsize+4)
		GUI:PopStyleColor(3)
		--GUI:SetCursorPos(nx,ny)
	end
	
	if(combo) then
		GUI:PopStyleVar()
	end
	
	-- Nametag for non combos
	if ( not combo and not self.skill_next ) then
		GUI:SameLine()
		GUI:BeginGroup()		
		GUI:Dummy(20,10)
		GUI:Text(self.name)
		GUI:EndGroup()		
	end
	-- Render Skill Combo Icons
	if ( self.skill_next and self.skill_next.id) then
		GUI:SameLine()
		self.skill_next:RenderActionButton(currentselectedaction,draggedaction,id1,id2+1)
	end
	return clicked, dragged, released
end

-- If this spell is being cast right now.
function sm_skill:IsCasting()
	return self.temp.context and self.temp.context.player and self.temp.context.player.castinfo and self.temp.context.player.castinfo.skillid == self.id
end

-- Checks if the Target of the Condition group which evaluated to "true"  is actually valid right now
function sm_skill:IsCastTargetValid()
	if (self.temp.casttarget == 1) then
		return self.temp.context.attack_target ~= nil
	elseif (self.temp.casttarget == 2) then
		return self.temp.context.player ~= nil
	elseif (self.temp.casttarget == 3) then
		return self.temp.context.heal_target	~= nil
	end
end

function sm_skill:GetCastTarget()
	if (self.temp.casttarget == 1) then
		return self.temp.context.attack_target
	elseif (self.temp.casttarget == 2) then
		return self.temp.context.player
	elseif (self.temp.casttarget == 3) then
		return self.temp.context.heal_target
	end
end

-- For Heal, Utility and Elite Slots, which can have different Skills from the same Set
-- Shitty flip skills fuck up the logic big time here, so we go the easiest way of just allowing "cancast" to be true when we are having the set actíve for skills 6-10
function sm_skill:IsEquipped()
	if (self.temp.context.skillbar) then
		-- Check for slot 555, fictional non skill slot. Used for dodge and swap weapons.
		if (self.slot == 555) then
			return true
		elseif (  self.slot < GW2.SKILLBARSLOT.Slot_1 or self.slot > GW2.SKILLBARSLOT.Slot_5 ) then		
			if ( self.skillpalette:IsActive(self.temp.context) ) then
				if ( self.slot == GW2.SKILLBARSLOT.Slot_6 and self.temp.context.skillbar[self.slot] and self.temp.context.skillbar[self.slot].id == self.id ) then return true end	-- Heal
				if ( self.slot == GW2.SKILLBARSLOT.Slot_10 and self.temp.context.skillbar[self.slot]and self.temp.context.skillbar[self.slot].id == self.id ) then return true end  -- Elite
				-- Utility				
				if ( self.slot >= GW2.SKILLBARSLOT.Slot_7 and self.slot <= GW2.SKILLBARSLOT.Slot_9 ) then
					if ( (self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_7] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_7].id == self.id) or 
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_8] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_8].id == self.id )or 
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_9] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_9].id == self.id)) then
						return true
					end
				end
				-- Toolbelt aka F-shit
				if ( self.slot >= GW2.SKILLBARSLOT.Slot_12 and self.slot <= GW2.SKILLBARSLOT.Slot_18 ) then
					if ( (self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_12] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_12].id == self.id) or 
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_13] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == self.id ) or 
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_14] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_14].id == self.id) or
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_15] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_15].id == self.id) or
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_16] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_16].id == self.id) or 
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_17] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == self.id) or
						(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_18] and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_18].id == self.id)) then
						return true
					end
				end
			end		
		else
			-- Weapon skill 1-5 : only return true for NONE-Flip-skills if they are on our current bar
			if ( not self.parent or (self.skillpalette:IsActive(self.temp.context) and self.temp.context.skillbar[self.slot] and self.temp.context.skillbar[self.slot].id == self.id))then 			
				return true
			end
		end
	end
	return false
end

-- Checks if the skill can be cast -> skillpalette and Conditions and onslot check
function sm_skill:CanCast()
	if (self.id and self.skillpalette and self.cancast and (self.skillpalette:IsActive(self.temp.context) or self.skillpalette:CanActivate(self.temp.context))) then
				
		-- Internal CD when spam casting
		if ( self.temp.internalcd and (ml_global_information.Now - self.temp.internalcd <= 0) ) then
			return false
		end
		
		-- Skills which cannot be used underwater
		if (self.nounderwater and self.temp.context.player.swimming == GW2.SWIMSTATE.Diving) then
			return false
		end
		
		if(self.skillpalette.CanCast and not self.skillpalette:CanCast(self.temp.context,self.id)) then
			return false
		end
		
		-- At least ONE of the condition groups needs to be true for the skill to be castable
		self.temp.casttarget = 1
		for i,grp in pairs( self.conditions ) do
			self.temp.casttarget = 1
			for k,v in pairs(grp) do
				if ( k ~= "casttarget") then
					if ( not v:Evaluate(self,self.temp.context)) then
						self.temp.casttarget = 0
						break
					end
				end
			end
			if (self.temp.casttarget > 0) then -- this condition group evaluated to true
				self.temp.casttarget = grp.casttarget
				break
			end
		end
		
		-- Check custom code
		if ( self.temp.casttarget > 0 ) then
			if ( not self.temp.condition_luacode_compiled and not self.temp.condition_luacode_bugged ) then
				local execstring = 'return function(self,context) '..self.condition_luacode..' end'
				local func = loadstring(execstring)
				if ( func ) then
					func()(self, self.temp.context)
					self.temp.condition_luacode_compiled = func	
				else
					self.temp.condition_luacode_compiled = nil
					self.temp.condition_luacode_bugged = true
					ml_error("[SkillManager] - Custom Condition Code has a BUG in Skill ID ".. tostring(self.id))
					assert(loadstring(execstring)) -- print out the actual error
				end
			end
		
			if ( self.temp.condition_luacode_compiled and not self.temp.condition_luacode_compiled()(self,self.temp.context) ) then 
				self.temp.casttarget = 0
			end
		end
		
		-- LoS Check
		if ( self.requireslos and self.temp.casttarget > 0 ) then
			local target
			if (self.temp.casttarget == 1) then	-- Enemy
				target = self.temp.context.attack_target
			elseif (self.temp.casttarget == 3) then
				target = self.temp.context.heal_target	-- Friend						
			end
			if (target and not target.los) then
				self.temp.casttarget = 0
			end		
		end
		
		return self.temp.casttarget ~= 0
	end
	return false
end







