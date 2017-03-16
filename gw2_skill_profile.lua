-- Skill Profile class template for the Skill Manager

-- forward declaration 
local sm_action = class('sm_action')
local sm_skillset = class('sm_skillset')

local sm_skill_profile = class('sm_skill_profile')
sm_skill_profile.filepath = ""
sm_skill_profile.filename = ""
sm_skill_profile.modulefunctions = nil 	-- private store addon functions
sm_skill_profile.context = {}					-- private addons can use their own custom variables or functions
sm_skill_profile.name = ""						-- Custom profile name that is displayed in the dropdown menu
sm_skill_profile.mainmenucode = GetString("-- You can render Main Menu UI Elements here as well as access the shared 'context' table. \n \n-- You can use:'context', 'context.currentskills', 'context.casthistory'\nreturn true")		-- UI Code of the SM Profile that is rendered in the Main Menu
sm_skill_profile.smcode = ""					-- UI Code that is rendered in the SM window above the skills
sm_skill_profile.smskilllistcode = ""		-- UI Code to present, manage and edit the skills
sm_skill_profile.profession = 1				-- The Class or Profession the skillprofile is made for
sm_skill_profile.skillsets = {}					-- Holds all "sets" of skills  (- grouped together skills by weapontype or transformation or similiar)
sm_skill_profile.texturepath = GetStartupPath() .. "\\GUI\\UI_Textures"
sm_skill_profile.texturecache = GetLuaModsPath() .. "\\SkillManager\\Cache"
sm_skill_profile.actionlist = {}				-- The priority list used for casting, holding all skills / combos in order 1 - n
sm_skill_profile.currentskills = {}			-- Holds a copy of the "live data" of the player skills
sm_skill_profile.skilldata = {}				-- Additional Skill Data from the API
sm_skill_profile.combatmovement = {}

-- These 2 needs to be set before the profile can be loaded / saved. Pass the 3rd arg for private addon handling
function sm_skill_profile:initialize(filepath, filename, modulefunctions, customcontext, profession)
	self.filepath = filepath
	self.filename = filename
	self.modulefunctions = modulefunctions
	self.context = customcontext or {}	
	self.profession = profession or SkillManager:GetPlayerProfession()
end

-- Saving this Profile
function sm_skill_profile:Save()
	if ( self.filepath ~= "" and self.filename ~= "" ) then
		if ( FolderExists(self.filepath) ) then			
			self:PreSave()
			local copy = {}
			copy.name = self.name
			copy.mainmenucode = self.mainmenucode
			copy.smcode = self.smcode
			copy.smskilllistcode = self.smskilllistcode
			copy.profession = self.profession
			copy.fightrangetype = self.fightrangetype
			copy.fixedfightrange = self.fixedfightrange
			copy.castspeed = self.castspeed
			-- Saving the essential data for actionlist
			copy.actionlist = {}
			local idx = 1
			for orderid,v in pairs(self.actionlist) do 							
				copy.actionlist[idx] = v:Save()
				idx = idx + 1 
			end
			-- Saving the essential data for skillsets
			copy.skillsets = {}
			for i,v in pairs(self.skillsets) do 							
				copy.skillsets[i] = { id = v.id, weaponsetid = v.weaponsetid, transformid = v.transformid, weapontype = v.weapontype, name = v.name or "", activateskillid = v.activateskillid, deactivateskillid = v.deactivateskillid}
				copy.skillsets[i].skills = {}
				for id,s in pairs(v.skills) do
					copy.skillsets[i].skills[id] = { slot = s.slot , minrange = s.minrange or 0, maxrange = s.maxrange or 0, radius = s.radius or 0,  power = s.power or 0, flip_level = s.flip_level or 0}
				end				
			end	
			
			FileSave(self.filepath.."\\"..self.filename..".sm", copy)
			self:AfterSave()
			d("[SkillManager::SkillProfile] - Saved Profile : "..self.filename..".sm")
		else
			ml_error("[SkillManager::SkillProfile] - Could not save Profile, invalid Profile folder: "..self.filepath)
		end		
	else
		ml_error("[SkillManager::SkillProfile] - Could not save Profile, invalid name or folderpath!")
	end
end
-- Loading this Profile (Handles also private addon case)
function sm_skill_profile:Load()
	if ( self.filepath ~= "" and self.filename ~= "" and FolderExists(self.filepath)) then
		-- Handle private addon profile & normal public one
		local data
		if ( FileExists(self.filepath.."\\"..self.filename..".sm" )) then
			-- Developer case, he has the original profile
			 data = FileLoad(self.filepath.."\\"..self.filename..".sm")
		else
			-- User case, he has only the .paf file
			if ( self.modulefunctions ) then			
				local files = self.modulefunctions.GetModuleFiles("data")		
				if(table.size(files)>0) then
					for _,filedata in pairs(files) do
						if( self.filename..".sm" == filedata.f) then
							local fileString = spvp.modulefunctions.ReadModuleFile(filedata)
							if(fileString) then						
								local fileFunction, errorMessage = loadstring(fileString)
								if (fileFunction) then
									data = fileFunction()					
								end
							end
							break
						end
					end
				else
					ml_error("[SkillManager::SkillProfile] - Error, no 'data' subfolder or no SM Profiles in that folder found!")
				end
			else
				ml_error("[SkillManager::SkillProfile] - Error, no PrivateModuleFunctions found! ")
			end
		end
		
		-- Check if loaded profile is valid
		if ( table.valid(data)) then
			-- reset the lists, we are only working in the same "instance" , so "classes" would get loaded twice ;)
			self.actionlist = {} 
			self.skillsets = {}
			for k, v in pairs(data) do
				if ( k ~= "filepath" and k ~= "filename" ) then
					-- Fill ActionList
					if ( k == "actionlist" and table.size(v) > 0 ) then
						-- creating action instances 
						for orderid,actiondata in pairs(v) do							
							local action = sm_action:new(actiondata)
							--[[local extradata = self:GetSkillDataByID( id )
							if ( extradata ) then
								for l,d in pairs(extradata) do
									action[l] = d
								end							
							end]]
							self.actionlist[orderid] = action
						end
					
					-- Fill Skillsets
					elseif ( k == "skillsets" and table.size(v) > 0 ) then
						for id,setdata in pairs(v) do							
							if ( setdata.skills ) then
								for skillid, _ in pairs (setdata.skills) do
									local extradata = self:GetSkillDataByID( skillid )
									if ( extradata ) then
										for key,d in pairs(extradata) do
											setdata.skills[skillid][key] = d
										end
									end
								end
							end
							local skillset = sm_skillset:new(setdata)							
							self.skillsets[id] = skillset
						end
					
					else
						self[k] = v
					end
				end
			end
			local name = self.name or self.filename
			d("[SkillManager::SkillProfile] - Successfully Loaded Profile: "..name)
			return self
		else
			ml_error("[SkillManager::SkillProfile] - Error loading Profile: "..tostring(self.filepath).." // "..tostring(self.filename)..".sm")
		end
	else
		ml_error("[SkillManager::SkillProfile] - Could not load Profile, invalid filename or folderpath: "..tostring(self.filepath).." // "..tostring(self.filename)..".sm")
	end
end

-- Renders Custom Profile UI Elements into the Main Menu of the Bot
function sm_skill_profile:RenderCodeEditor()
	if ( self.mainmenucode ) then
		if ( self.menucodechanged or not self.menucodefunc ) then
			local execstring = 'return function(context) '..self.mainmenucode..' end'
			local func = loadstring(execstring)
			if ( func ) then
				func()(self.context)
				self.menucodechanged = nil
				self.menucodefunc = func	
			else				
				ml_error("SkillManagerProfile::RenderCodeEditor() compilation error in ".. tostring(self.name ~= "" and self.name or self.filename ))
				assert(loadstring(execstring)) -- print out the actual error
			end
		else
			--executing the already loaded function
			self.menucodefunc()(self.context)
		end
	end
end


-- TODO: MOVE ALL INTO SEPERATE ADDON!
-- GW2 Specific Code starts here:
sm_skill_profile.slotnames = { 
	[1] = GetString(" W1"),
	[2] = GetString(" W2"),
	[3] = GetString(" W3"),
	[4] = GetString(" W4"),
	[5] = GetString(" W5"),
	[6] = GetString("Heal"),
	[7] = GetString("Util1"),
	[8] = GetString("Util2"),
	[9] = GetString("Util3"),
	[10] = GetString("Elite"),
	[11] = GetString("??1"),
	[12] = GetString("??2"),
	[13] = GetString(" F1"),
	[14] = GetString(" F2"),
	[15] = GetString(" F3"),
	[16] = GetString(" F4"),
	[17] = GetString(" F5"),
	[18] = GetString("S1"),
}

sm_skill_profile.professions = { 
	[1] = GetString("Guardian"), 
	[2] = GetString("Warrior"), 
	[3] = GetString("Engineer"), 
	[4] = GetString("Ranger"), 
	[5] = GetString("Thief"), 
	[6] = GetString("Elementalist"), 
	[7] = GetString("Mesmer"), 
	[8] = GetString("Necromancer"), 
	[9] = GetString("Revenant"), 
	}
	
sm_skill_profile.hardcodedsets = {
	["2_30162"] = { name = "Med Kit", activateskillid = 5802 },	-- bundles use additionally currentskills[3].skillid to ident them 
	["2_5930"] = { name = "Flamethrower", activateskillid = 5927 },
	["2_5965"] = { name = "Elixier Gun", activateskillid = 5933 },
	["2_6169"] = { name = "Grenade-Aqua", activateskillid = 5805 },			
	["2_5808"] = { name = "Grenade Kit", activateskillid = 5805 },
	["2_5822"] = { name = "Bomb Kit", activateskillid = 5812 },
	["2_5905"] = { name = "Tool Kit", activateskillid = 5904 },
	["2_30307"] = { name = "Mortar Kit", activateskillid = 30800 },
	["3_6"] = { name = "Reaper", activateskillid = 30792, deactivateskillid = 30961},
	["3_10633"] = { name = "Lichform", activateskillid = 10550, deactivateskillid = 10700},
	["3_10663"] = { name = "Plaque", activateskillid = 10549, deactivateskillid = 10700},
	["6_0"] = { name = "Death Shroud", activateskillid = 10574, deactivateskillid = 10585},
	["6_1"] = { name = "Shroud-Aqua", activateskillid = 10574, deactivateskillid = 10585},
}

-- Resets all kinds of "modified" toggle vars, after saving. Enforces "reloading" of all codeeditor text.
function sm_skill_profile:PreSave()
	self.actioneditoropen = nil
	self.modified = nil
	self.menucodechanging = nil
	self.selectedskill = nil
	self.selectedskillset = nil
	self.lasttick = nil
	self.context = nil
	self.dragid = nil
	self.dropid = nil
	self.dropidhover = nil
	self.weaponsets = nil
	self.lastcastonplayer = nil
	self.combatmovement = {}
	self.targetlastupdated = nil
	self.targetid = nil
	self.sets = nil
end
function sm_skill_profile:AfterSave()
	self.menucodechanged = true
	self.actioneditoropen = true
	self.weaponsets = {}
	
	-- Reset potential bugged editorcode - spam - blocks
	for k,v in pairs(self.actionlist) do
		for a,s in pairs(v.sequence) do
			s.conditioncodebugged = nil
		end
	end
end

-- Renders the profile template into the SM "main" window
function sm_skill_profile:Render()
	
	if ( not ml_global_information.GameState == GW2.GAMESTATE.GAMEPLAY or not ml_global_information.Player_CastInfo ) then 
		return 		
	end
	
	if ( GUI:TreeNode(GetString("Profile Editor")) ) then
		GUI:PushItemWidth(150)
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Custom Name:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Give the Profile a custom name (The filename will not change!).")) end
		GUI:SameLine(150)
		local changed 	
		self.name,changed = GUI:InputText("##smp1",self.name or self.filename)
		if ( changed ) then self.modified = true end
		
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Profession:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("The Profession this Profile is for.")) end
		GUI:SameLine(150)
		self.profession, changed = GUI:Combo("##smp2",self.profession, self.professions)
		if ( changed ) then self.modified = true end
		if ( not Player.profession or self.profession ~= Player.profession ) then			
			GUI:TreePop()
			return
		end
		
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Fight Range:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("'Dynamic'- Adjusts the range depending on the available spells. 'Custom'-Tries to stay at that range during fights.")) end
		GUI:SameLine(150)
		self.fightrangetype, changed = GUI:Combo("##smfightrangetype",self.fightrangetype or 1, { [1] = GetString("Dynamic"), [2] = GetString("Custom"), })
		if ( changed ) then self.modified = true end
		
		if ( self.fightrangetype == 2 ) then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(GetString("Fight Distance:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("While fighting, the bot tries to stay at this distance to the target.")) end
			GUI:SameLine(150)
			self.fixedfightrange, changed = GUI:InputInt("##smfightdistance", self.fixedfightrange or ml_global_information.AttackRange or 154, 1, 10, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
			if ( changed ) then self.modified = true end
			if ( self.fixedfightrange <= 154 ) then self.fixedfightrange = 154 end
		end
						
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Cast Speed:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Setting this too fast, can result in misfired skills or failing to cast, depending on the situation and profile skills. (Smaller value means faster casting)")) end
		GUI:SameLine(150)
		self.castspeed, changed = GUI:SliderInt("##smcastspeed",self.castspeed or 750, 500, 1500)		
		if ( changed ) then self.modified = true end
		
		GUI:PopItemWidth()
		GUI:Separator()
-- DEBUG 

		GUI:Text("DEBUG: maxattackrange  : "..tostring(ml_global_information.AttackRange))
		GUI:Text("DEBUG: fightrange  : "..tostring(self.fixedfightrange))
		GUI:Text("DEBUG: used range  : "..tostring(gw2_skill_manager.GetActiveSkillRange()))		
		if ( self.actionlist[self.currentaction] and self.actionlist[self.currentaction].sequence[self.currentactionsequence]) then 
			GUI:Text("DEBUG: currentaction  : "..tostring(self.actionlist[self.currentaction].name))
			GUI:Text("DEBUG: sequence  : "..tostring(self.currentactionsequence))
		end

-- CodeEditor
		local _,maxy = GUI:GetContentRegionAvail()
		GUI:SetNextTreeNodeOpened(false,GUI.SetCond_Once)
		if ( GUI:TreeNode(GetString("CodeEditor")) ) then			
			local x,y = GUI:GetWindowSize()
			if ( y < 700 ) then y = 700 end
			GUI:SetWindowSize(650,y)
			if ( GUI:IsItemHovered() ) then GUI:SetTooltip(GetString( "Write custom lua code which gets called all the time! So don't spam useless stuff here!" ) )end
			local maxx,_ = GUI:GetContentRegionAvail()
			local changed = false
			self.mainmenucode, changed = GUI:InputTextEditor( "##smmainmenueditor", self.mainmenucode, maxx, math.max(maxy/2,300) , GUI.InputTextFlags_AllowTabInput)
			if ( changed ) then self.menucodechanging = true self.modified = true end
			if ( self.menucodechanging ) then
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
				GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
				if ( GUI:Button(GetString("Save Changes"),maxx,20) ) then						
					self:Save()					
				end				
				GUI:PopStyleColor(4)
			end
			GUI:PushItemWidth(600)
			GUI:Dummy(600,1)
			GUI:PopItemWidth()
			GUI:TreePop()
		else
			local x,y = GUI:GetWindowSize()
			if ( y < 400 ) then y = 400 end
			GUI:SetWindowSize(310,y) -- locl width
		end
		
		GUI:Separator()

-- Skill List
		GUI:Text(GetString("Action List:"))
		if ( GUI:IsItemHovered() ) then GUI:SetTooltip(GetString("Click and drag actions to switch places. Action List is a Priority List!")) end
		local wx,wy = GUI:GetContentRegionAvail()
		if ( wy < 200 ) then wy = 200 end -- minumum of 200 y size
		GUI:BeginChild("##actionlistgrp",wx-10,wy)
		local imgsize = 25
		local hoveringaction
		GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 0, 4)
		GUI:PushStyleVar(GUI.StyleVar_FramePadding, 0, 0)

		if (not self.sets) then self.sets = self:GetCurrentSkillSets() end
		
		for k,v in pairs(self.actionlist) do
			local size = imgsize
			local skilldatas = {}
			local skillsets = {}
			for q,w in pairs(v.sequence) do
				skilldatas[q], skillsets[q] = self:GetSkillAndSkillSet(w.id)
			end
			local texture = skilldatas[1] ~= nil and self.texturecache.."\\default.png" or self.texturecache.."\\blank.png"			
			local cd = 0
			local colorset
			local labelx,labely = GUI:GetCursorScreenPos()
			local label
			local recx,recy,recw,rech
			
			if ( self.selectedactionid == k ) then	
				size = 45							
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
				GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
				colorset = true
				labelx = labelx + 55
				labely = labely + size/3
				label = v.name
				
				for q,s in pairs(v.sequence) do
					if ( not skilldatas[q] ) then
						if ( s.id > 0 ) then
							label = "[Missing Skill Data ID: "..tostring(s.id)	
						else
							label = "[Empty Action]"
						end
					end
				end
				
			elseif ( table.size(skilldatas) > 0 ) then				
				local currenltycast				
				for q,s in pairs(skilldatas) do
					if ( ml_global_information.Player_CastInfo and ((self.currentaction == k and self.currentactionsequence == q and ml_global_information.Player_CastInfo.skillid ~= 0) or (ml_global_information.Player_CastInfo.skillid == s.id))) then
						GUI:PushStyleColor(GUI.Col_ButtonHovered,0.18,1.0,0.0,0.8)
						GUI:PushStyleColor(GUI.Col_ButtonActive,0.18,1.0,0.0,0.9)
						GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
						GUI:PushStyleColor(GUI.Col_Button,0.18,1.0,0.0,0.7)
						colorset = true	
						labelx = labelx + 35
						labely = labely + size/4
						if ( q > 1 ) then
							label = v.name.." ("..GetString("Active ")..tostring(q).." / "..tostring(#skilldatas)..")"
						else
							label = v.name.." ("..GetString("Active")..")"
						end
						currenltycast = true
						break
					end
				end
						
				if ( not currenltycast ) then
					local count = 0
					for q,s in pairs(skilldatas) do
						if ( s.cooldownmax and s.cooldownmax > 0 ) then 
							if ( s.cooldown and s.cooldown > 0 ) then
								cd = cd + (100 - math.round(s.cooldown*100 / s.cooldownmax, 0))
							else
								cd = cd + 100
							end
							count = count + 1
						end
					end
					if ( count > 0 ) then 	cd = math.round(cd / count,0) end
					
					if ( count > 0 and cd ~= 100 ) then					
						local r,g,b = GUI:ColorConvertHSVtoRGB( cd*0.0045, 0.706, 0.63)					
						GUI:PushStyleColor(GUI.Col_ButtonHovered,r, g, b, 0.8)
						GUI:PushStyleColor(GUI.Col_ButtonActive,r, g, b, 0.9)
						GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
						GUI:PushStyleColor(GUI.Col_Button,r, g, b, 0.7)
						colorset = true
						recx = labelx
						recy = labely 
						recw = labelx+GUI:GetContentRegionAvail()-10 
						rech = labely+size
						labelx = labelx + 35
						labely = labely + size/4
						if ( cd < 0 ) then cd = 0 end
						label = v.name.." ("..tostring(cd).."%)"					
					
					else
						labelx = labelx + 35
						labely = labely + size/4
						if (table.size(skilldatas)> 1) then
							label = v.name .." (".. tostring(table.size(skilldatas))..")"
						else
							label = v.name
						end
					end				
				end
				
			elseif ( v.sequence[1].id > 0 ) then
				labelx = labelx + 35
				labely = labely + size/4
				label = "[Missing Skill Data ID: "..tostring(v.sequence[1].id)	
			else
				labelx = labelx + 35
				labely = labely + size/4
				label = "[Empty Action]"				
			end
			
			local cancast = true
			for q,s in pairs(skilldatas) do
				if ( not skillsets[q] or not v:CanCastSkill(self, skillsets[q], q, s)) then
					cancast = false
					break
				end
			end
			if ( cancast ) then
				GUI:ImageButton("##actionlistentry"..tostring(k), texture,size,size)
			else
				GUI:ImageButton("##actionlistentry"..tostring(k), texture,size,size,0,0,1,1,-1, 0,0,0,0,  1,1, 1, 0.4) -- last 4 numbers are rgba
			end
			GUI:SameLine()
			local width = cd~=0 and (GUI:GetContentRegionAvail()-10)/100*cd or  (GUI:GetContentRegionAvail()-10)
			-- Apply drag n drop color
			if ( self.dragid ) then
				if ( self.dragid == k ) then
					GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.5)
				elseif ( self.dropidhover and self.dropidhover == k ) then
					GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.6)
				end
			end

			if ( GUI:Button("##actionlistentrybar"..tostring(k),width,size) ) then
				if ( self.selectedactionid and self.actionlist[self.selectedactionid] ) then self.actionlist[self.selectedactionid]:Deselect() end
				self.selectedskillset = nil
				self.selectedactionid = k
				self.actioneditoropen = true
				self.actionlist[self.selectedactionid].deletecount = nil
			end	
			if ( colorset ) then GUI:PopStyleColor(4) end
			if ( self.dragid and (self.dragid == k or self.dropidhover and self.dropidhover == k )) then GUI:PopStyleColor() end
			
			if ( GUI:IsItemHoveredRect() ) then
				hoveringaction = true				
			end
			-- Drag n Drop to switch places
			if ( GUI:IsItemClicked() ) then
				self.dragid = k
			elseif ( self.dragid and self.dragid ~= k and GUI:IsItemHoveredRect() ) then
				self.dropidhover = k
				if ( GUI:IsMouseReleased(0) ) then
					self.dropid = k
				end
			end
			
	
			-- Draw label
			if ( recx ) then
				GUI:AddRect( recx, recy, recw, rech, GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,0.2))
			end
						
			GUI:AddText( labelx, labely, GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,0.80), label)	
		end
		GUI:PopStyleVar(2)
				
		-- When moving the mouse outside the window while dragging actions around
		if ( (self.dragid or self.dropidhover) and (hoveringaction == nil and not GUI:IsWindowHovered())) then
			self.dragid = nil
			self.dropidhover = nil
		end
		
		-- Apply Drag n Drop
		if ( self.dragid and self.dropid ) then
			local tmp = self.actionlist[self.dragid]
			table.remove(self.actionlist,self.dragid)
			table.insert(self.actionlist,self.dropid,tmp)
			-- don't flip skill when it is being edited
			if ( self.selectedactionid and self.actionlist[self.selectedactionid] ) then self.selectedactionid = self.dropid end
			self.dragid = nil
			self.dropid = nil
			self.dropidhover = nil
			self.modified = true
		end
		
		-- Render 'empty' skill slot on the bottom to add new entries
		local nextid = table.size(self.actionlist) + 1
		if ( GUI:Button("+##"..tostring(nextid), imgsize,imgsize) ) then 
			-- Create a new cast list entry
			local action = sm_action:new()
			action.editskill = 1
			table.insert(self.actionlist,action)
			if ( self.selectedactionid and self.actionlist[self.selectedactionid] ) then self.actionlist[self.selectedactionid]:Deselect() end
			self.selectedskillset = nil
			self.selectedactionid = nextid
			self.actioneditoropen = true
		end
		GUI:EndChild()
		
-- Show Action Editor of the current "selected" action
		if ( self.selectedactionid and self.actionlist[self.selectedactionid] ) then
			local x,y = GUI:GetWindowPos()
			local w,h = GUI:GetWindowSize()
			GUI:SetNextWindowPos( x+w+5, y, GUI.SetCond_Always)
			GUI:SetNextWindowSize(w,h,GUI.SetCond_Appearing)
			local visible
			self.actioneditoropen,visible = GUI:Begin(GetString("Action Editor").."##mlsma", self.actioneditoropen, GUI.WindowFlags_NoSavedSettings+GUI.WindowFlags_AlwaysAutoResize+GUI.WindowFlags_NoCollapse)

			local result = self.actionlist[self.selectedactionid]:Render(self)
			if ( result == -1 ) then
				-- Delete the currently opened action
				table.remove(self.actionlist,self.selectedactionid)
				self.selectedskillset = nil
				self.selectedactionid = nil
				self.actioneditoropen = nil
				self.modified = true						
			end
			
			GUI:End()
			if ( visible == false ) then
				if ( self.selectedactionid and self.actionlist[self.selectedactionid] ) then self.actionlist[self.selectedactionid]:Deselect()  end
				self.selectedskillset = nil
				self.selectedactionid = nil
				self.actioneditoropen = nil
			end
		end
		GUI:TreePop()
	end
end

-- Show the SkillSet Editor and Skill Selector
function sm_skill_profile:RenderSkillSetEditor(currentaction)
	GUI:BulletText(GetString("Available Skill Sets:"))
	
	-- Make sure we have at least the "unsortedskillset" Group
	if ( not self.skillsets["All"] ) then
		self:UpdateCurrentSkillsetData()
		if( not self.skillsets["All"] ) then
			self.selectedskillset = self.skillsets["All"]
		end
	end
	
	-- When opening the editor, select the current skillset and skill
	if ( currentaction.id ~= 0 ) then
		for k,set in pairs(self.skillsets) do
			if (self.selectedskillset ~= nil ) then break end
			for n,m in pairs(set.skills) do
				if (n == currentaction.id) then
					self.selectedskillset = set
					break
				end
			end			
		end		
		-- Select our current active skill
		if (not self.selectedskill and self.selectedskillset and self.selectedskillset.skills[currentaction.id]) then
			self.selectedskill = currentaction.id
		end
	end
	-- 1st time opening this, pick the default list
	if ( not self.selectedskillset ) then self.selectedskillset = self.skillsets["All"] end
	
	GUI:Spacing()
	-- Draw all skillset group buttons, draw the "all skills" first
	if ( self.selectedskillset.id == "All" ) then
		GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
		GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
		GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
		GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
		GUI:Button(self.skillsets["All"].name.."##"..tostring(k),120,25)
		GUI:PopStyleColor(4)
	else
		if ( GUI:Button(self.skillsets["All"].name.."##"..tostring(k),120,25) ) then	
			self.selectedskillset = self.skillsets["All"]
		end
	end
	if ( table.size(self.skillsets) > 1 ) then GUI:SameLine() end
	
	local count = 2
	for k,v in pairs(self.skillsets) do
		if ( k ~= "All" ) then
			if ( k == self.selectedskillset.id ) then
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
				GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
				GUI:Button(v.name.."##"..tostring(k),120,25)
				GUI:PopStyleColor(4)
			else
				if ( GUI:Button(v.name.."##"..tostring(k),120,25) ) then	
					self.selectedskillset = v
				end
			end		
			if ( math.fmod(count,5) ~= 0 ) then GUI:SameLine() end
			count = count + 1
		end
	end
	
	-- Refresh button to let it add new sets (can't be automated since it somethings creates bonky sets when the game data is slow in updating on switching weapons etc
	if (GUI:ImageButton("##smrefreshsets",self.texturepath.."\\change.png",20,20)) then
		self:UpdateCurrentSkillsetData()
	end
	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add your current weaponset to the list.")) end
	
	GUI:Separator()

		
	-- Drawing the actual set details	
	if ( self.selectedskillset ) then
		local profession = SkillManager:GetPlayerProfession() or 0
		GUI:BulletText(GetString("Set Details:"))
		GUI:PushItemWidth(180)
		GUI:Columns(2,"##smbasicedit",false)
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Set Name:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Give this Skillset a name.")) end
		GUI:SameLine(120)
		local	changed
		self.selectedskillset.name, changed = GUI:InputText("##smp3",self.selectedskillset.name)
		if ( changed ) then self.modified = true end
		
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Set ID:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Internal Skillset ID.")) end
		GUI:SameLine(120)
		self.selectedskillset.id = GUI:InputText("##smp4",self.selectedskillset.id,GUI.InputTextFlags_ReadOnly)		
		
		GUI:NextColumn()
		
	-- Main Skilllist - Refresh /Add / Delete Set buttons
		if ( self.selectedskillset.id == "All" ) then
			--if ( GUI:ImageButton("##smadd",sm_skill_profile.texturepath.."\\addon.png",35,35)) then 				
				--self:UpdateCurrentSkillsetData()
				--modified = true
			--end
			--if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add your current Skills.")) end
			GUI:SameLine(310)			
			if ( GUI:ImageButton("##smclear",self.texturepath.."\\w_delete.png",15,15)) then
				for k,v in pairs(	self.skillsets["All"].skills ) do
					if ( not self:IsSkillInUse(k) ) then -- checks if the current actionlist is using this skill
						self.skillsets["All"].skills[k] = nil
					end
				end
				self.modified = true
			end
			if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Remove all unused skills of this Set.")) end
		end
		GUI:Columns(1)
		
		-- Set Activate & Deactivate 
		if ( self.selectedskillset and self.selectedskillset.id ~= "All" and table.size(self.selectedskillset.skills) > 0 ) then						
			local combolist = {}
			local prof = SkillManager:GetPlayerProfession()
			
			-- Ele's attunements
			if ( prof == GW2.CHARCLASS.Elementalist and (self.selectedskillset.weaponsetid == 4 or self.selectedskillset.weaponsetid == 5 or self.selectedskillset.weaponsetid == 0)) then
				if ( self.selectedskillset.transformid == 1 ) then self.selectedskillset.activateskillid = 13 end -- Fire
				if ( self.selectedskillset.transformid == 2 ) then self.selectedskillset.activateskillid = 14 end -- Water
				if ( self.selectedskillset.transformid == 3 ) then self.selectedskillset.activateskillid = 15 end -- Air
				if ( self.selectedskillset.transformid == 4 ) then self.selectedskillset.activateskillid = 16 end -- Earth
			
			-- Hardcoded special poop
			elseif ( self.hardcodedsets[self.selectedskillset.id] ~= nil ) then
				local b = self.hardcodedsets[self.selectedskillset.id]				
				self.selectedskillset.activateskillid = b.activateskillid
				self.selectedskillset.deactivateskillid = b.deactivateskillid				
			
			
			-- Bundles and Transformations need a defined activate & deactivate skill for the set
			elseif ( self.selectedskillset.weaponsetid == 2 or self.selectedskillset.weaponsetid == 3) then
				for k,v in pairs(self.selectedskillset.skills) do
					combolist[k] = v.name
				end
				GUI:AlignFirstTextHeightToWidgets()
				GUI:Text(GetString("Activate Set:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Select the Skill that activates this Skillset.")) end
				GUI:SameLine(120)
				if ( self.selectedskillset.activateskillid > 2 and self.selectedskillset.skills[self.selectedskillset.activateskillid] ) then
					GUI:ImageButton("##smactivate",self.texturecache.."\\default.png",20,20)				
				else
					GUI:ImageButton("##smactivate",self.texturepath.."\\gear.png",20,20)
				end
				GUI:SameLine(155) self.selectedskillset.activateskillid = GUI:Combo("##smactivate",self.selectedskillset.activateskillid or 1, combolist)
				
				-- If this skillset is activated, we also need a deactivate skill id:
				if ( self.selectedskillset.weaponsetid == 3 and self.selectedskillset.activateskillid > 2 ) then
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("Deactivate Set:"))  if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Select the Skill that deactivates this Skillset.")) end
					GUI:SameLine(120) 
					if ( self.selectedskillset.deactivateskillid and self.selectedskillset.deactivateskillid > 2 and self.selectedskillset.skills[self.selectedskillset.deactivateskillid] ) then
						GUI:ImageButton("##smdeactivate",sm_skill_profile.texturecache.."\\default.png",20,20)					
					else
						GUI:ImageButton("##smdeactivate",sm_skill_profile.texturepath.."\\gear.png",20,20)
					end
					GUI:SameLine(155) self.selectedskillset.deactivateskillid = GUI:Combo("##smdeactivate",self.selectedskillset.deactivateskillid or 1, combolist)
				end			
			end
		end
		GUI:Separator()
		
-- List the Skills of the SkillSet
		GUI:BulletText(GetString("Skill List:"))
		if ( self.selectedskillset ) then
			if (  self.selectedskillset.id == "All" ) then
				GUI:TextColored( 1.0, 0.75, 0, 1, GetString("Mouse-Right-Click to manage skills"))
			else
				GUI:TextColored( 1.0, 0.75, 0, 1, GetString("1: Move Skills from the Main-Set to this set."))
				GUI:TextColored( 1.0, 0.75, 0, 1, GetString("2: A Skillset must hold ONLY the skills from ONE Weapon / Kit / Stance / Transformation! "))
			end
		end
		if ( self.selectedskillset and table.size(self.selectedskillset.skills) > 0 ) then
			GUI:PushStyleVar(GUI.StyleVar_FramePadding, 2, 2)
			GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 6, 4)
			
			-- Make 15 columns, insert skills accordingly
			GUI:Columns(16,"##small",false)
			for i=1,16 do			
				GUI:SetColumnOffset(i,i*45)	
				-- Add all skills which are in that "slot"
				local slot = i > 10 and i + 2 or i					
				GUI:Text(sm_skill_profile.slotnames[slot])
				for id,skill in pairs(self.selectedskillset.skills) do						
					if (skill.slot and skill.slot == slot ) then 
						local highlight
						if ( self.selectedskill and self.selectedskill == id ) then 
							highlight = true
							GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.8)
							GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.9)
							GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,1.0)
						end
						if ( not skill.name ) then skill.name = GetString("Unknown Name") end
						if ( GUI:ImageButton(skill.name.."##"..tostring(id), sm_skill_profile.texturecache.."\\default.png", 30,30) ) then self.selectedskill = id end if (GUI:IsItemHovered()) then GUI:SetTooltip( skill.name or "" ) end						
						if ( highlight ) then GUI:PopStyleColor(3) end
						-- Right click - Context Menu Spawn
						
						if ( GUI:BeginPopupContextItem("##ctx"..tostring(id)) ) then								
							-- custom sets can only remove / move skills to the Main skill list
							if ( self.selectedskillset.id ~= "All" ) then
								if ( GUI:Selectable(GetString("Move to Main Set"),false) ) then 
									self.skillsets["All"].skills[id] = skill
									self.selectedskillset.skills[id] = nil									
									self.modified = true
								end	
								-- Options to move skill to all other sets
							else
								for k,v in pairs(self.skillsets) do
									if (k ~= "All" ) then
										if ( GUI:Selectable(GetString("Move to "..v.name.."##"..tostring(k)),false )) then											
											self.skillsets[k].skills[id] = skill
											self.skillsets["All"].skills[id] = nil
											self.modified = true 
										end
									end
								end
							
								-- If not used, offer Remove option
								local used = false
								if ( not self:IsSkillInUse(id) ) then
									if ( GUI:Selectable(GetString("Remove"),false) ) then
										self.skillsets["All"].skills[id] = skill
										self.selectedskillset.skills[id] = nil  
										self.modified = true 
									end
								end
							end
							GUI:EndPopup()
						end						
					end
				end
				GUI:NextColumn()
			end
			GUI:Columns(1)			
			GUI:PopStyleVar(2)
			
			-- Delete skillset in case it holds no skills anymore
			if ( table.size(self.selectedskillset.skills) == 0) then										
				self.skillsets[self.selectedskillset.id] = nil
				self.selectedskillset = nil				
			end
						
			-- Selected Skill Details
			if ( self.selectedskill and self.selectedskillset and self.selectedskillset.skills[self.selectedskill] and (self.selectedskillset.id == "All" or self.selectedskillset.activateskillid <= 18 or (self.selectedskillset.activateskillid > 18 and self.selectedskillset.activateskillid and self.selectedskillset.activateskillid > 2 ))) then
				GUI:Separator()
				local skill = self.selectedskillset.skills[self.selectedskill]
				
				GUI:Columns(2,"##smskilldetails",false)
				GUI:SetColumnOffset(1,60)
				GUI:Dummy(50,10)
				GUI:ImageButton(tostring(skill.name),sm_skill_profile.texturecache.."\\default.png", 40,40) if (GUI:IsItemHovered()) then GUI:SetTooltip( tostring(skill.name) ) end
				GUI:NextColumn()
				
				GUI:BulletText(GetString("Name:")) GUI:SameLine(150) GUI:Text(skill.name)
				GUI:BulletText(GetString("Skill ID:")) GUI:SameLine(150) GUI:Text(skill.id)				
				GUI:BulletText(GetString("Slot:")) GUI:SameLine(150) GUI:Text(skill.slot ~= nil and tostring(skill.slot) or tostring(0))
				GUI:BulletText(GetString("Slot Name:")) GUI:SameLine(150) GUI:Text(skill.slot_name ~= nil and tostring(skill.slot_name) or tostring(""))
				GUI:BulletText(GetString("Type:")) GUI:SameLine(150) GUI:Text(skill.type ~= nil and tostring(skill.type) or tostring(0))
				GUI:BulletText(GetString("Weapon:")) GUI:SameLine(150) GUI:Text(skill.weapon_type ~= nil and tostring(skill.weapon_type) or tostring(0))
				if ( skill.maxrange and skill.maxrange > 0) then GUI:BulletText(GetString("Max.Range:")) GUI:SameLine(150) GUI:Text(tostring(skill.maxrange)) end
				if ( skill.minrange and skill.minrange > 0) then GUI:BulletText(GetString("Min.Range:")) GUI:SameLine(150) GUI:Text(tostring(skill.minrange)) end
				if ( skill.radius and skill.radius > 0 ) then GUI:BulletText(GetString("Radius:")) GUI:SameLine(150) GUI:Text(tostring(skill.radius)) end
				if ( skill.power and skill.power > 0 ) then GUI:BulletText(GetString("Req.Power:")) GUI:SameLine(150) GUI:Text(tostring(skill.power)) end
				if ( skill.flip_level and skill.flip_level > 0 ) then GUI:BulletText(GetString("Chain Level:")) GUI:SameLine(150) GUI:Text(tostring(skill.flip_level)) end
				GUI:Columns(1)
				
				GUI:Separator()
				GUI:Spacing()
				local width = GUI:GetContentRegionAvailWidth()
				if ( currentaction.id ~= 0 ) then
					GUI:SameLine((width/3)-40)
					if ( GUI:Button(GetString("Cancel"), 80,35) ) then
						return -1
					end
					GUI:SameLine((width/3*2)-40)
				else
					GUI:SameLine((width/2)-40)
				end				
				if ( GUI:Button(GetString("Accept"), 80,35) ) then
					currentaction.id = self.selectedskill
					self.selectedskillset = nil					
					return -2
				end
			else
				GUI:Separator()
				GUI:Spacing()
				GUI:Dummy(50,10)
				local width = GUI:GetContentRegionAvailWidth()
				GUI:SameLine((width/3)-40)
				if ( GUI:Button(GetString("Cancel"), 80,35) ) then
					return -1
				end				
			end
		end
	end
end

-- Grabs a "snapshot" of the current skills the player has and extends each entry with additional data from the "gw2_skill_data.lua" table.
-- Creates "missing" skill sets and adds skills to the current profile...now this is some major ugly bullshit function ...thanks anet for your chaos profession mechanic!
function sm_skill_profile:UpdateCurrentSkillsetData()	
	local skilldb = self.skilldata
	local result = {}			-- Holds all skills of the current set, key is skillID
	for i = 1, ml_global_information.MAX_SKILLBAR_SLOTS-1 do	-- 1 to 19
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if (skill) then
			local sID = skill.skillid
			result[sID] = {}
			for k,v in pairs (skill) do 
				result[sID][k] = v
			end
			result[sID]["slot"] = i
			result[sID]["flip_level"] = 0
			
			-- Add the additional skill data from the anet api file
			local data = self:GetSkillDataByID(sID)
			if ( data ) then
				for k,v in pairs (data) do 
					result[sID][k] = v
				end
				
				-- Check and add 1st Chain/Flipskill
				if ( data.flip_skill ~= 0 ) then	--flip_skill is the skillID 
					local flip1 = self:GetSkillDataByID(data.flip_skill)
					if ( flip1 ) then
						result[flip1.id] = {}
						for k,v in pairs (flip1) do 
							result[flip1.id][k] = v
						end						
						result[flip1.id]["slot"] = i
						result[flip1.id]["flip_level"] = 1
									
						-- 2nd Chain/Flipskill
						if ( flip1.flip_skill ~= 0 ) then
							local flip2 = self:GetSkillDataByID(flip1.flip_skill)
							if ( flip2 ) then
								result[flip2.id] = {}
								for k,v in pairs (flip2) do 
									result[flip2.id][k] = v
								end
								result[flip2.id]["slot"] = i
								result[flip2.id]["flip_level"] = 2								
							end				
						end
					end
				end
			end
		end
	end
	--[[-- Add one more custom skill for "weapon swap"
	local ws = Player:GetCurrentWeaponSet()
	if ( ws == 4 or ws == 5 ) then
		result[2] = {
			id = 2,
			skillid = 2,
			slot = 18,
			flip_level = 0,
			slot_name = "None",
			type = "0",
			weapon_type = "0",
			name = GetString("Swap Weapons"),
		}
	end--]]
	
	-- Check, Create and update "Unsorted Skills"
	if ( not self.skillsets["All"] ) then
		local set = sm_skillset:new()
		set.id = "All"
		set.name = GetString("All Skills")		
		set.skills = {}		
		self.skillsets["All"] = set
	end
	
	local w = Player:GetCurrentWeaponSet()
	local t = Player:GetTransformID()
		
	 -- bundles and picked up weapons have all id 2, use additionally skill3 id to seperat them
	if ( w == 2 or w == 3 ) then
		if ( self.currentskills and self.currentskills[3] ) then--reaper
			if ( t ~= 6 ) then
				self:CreateSetFromSkillData(w, self.currentskills[3].skillid, 0, result, 1, 5)		
			else
				self:CreateSetFromSkillData(w, t, 0, result, 1, 5)
			end
		end
			
	else
	
		local weapon1, weapontype1, weapon2, weapontype2				
		-- for all water weapons
		if ( w == 0 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon)
			if ( item ) then weapon1 = 0  weapontype1 = item.weapontype end
		elseif( w == 1 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon)
			if ( item ) then weapon1 = 0  weapontype1 = item.weapontype end
		
		-- Main & Offhand 
		elseif ( w == 4 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
			if ( item ) then weapon1 = 4  weapontype1 = item.weapontype end	-- Mainhand
			local item2 = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
			if ( item2 ) then weapon2 = 5  weapontype2 = item2.weapontype end	-- Offhand
		
		-- 2nd Main & Offhand 
		elseif ( w == 5 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon)
			if ( item ) then weapon1 = 4  weapontype1 = item.weapontype end	-- Mainhand
			local item2 = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon)
			if ( item2 ) then weapon2 = 5  weapontype2 = item2.weapontype end	-- Offhand
		end
		
		if ( t >= 12 and t <=17 ) then
			if ( weapon2 and not self:IsTwoHandWeapon(weapontype1)) then
				self:CreateSetFromSkillData(weapon1,0,weapontype1, result, 1, 3)
				self:CreateSetFromSkillData(weapon2,0,weapontype2, result, 4, 5)
			else
				if ( self:IsTwoHandWeapon(weapontype1) ) then
					self:CreateSetFromSkillData(weapon1,0,weapontype1, result, 1, 5)
				else
					self:CreateSetFromSkillData(weapon1,0,weapontype1, result, 1, 3)
				end
			end
			self:CreateSetFromSkillData(0,t,0, result, 6, 10)
		else
		
			if ( weapon2 and not self:IsTwoHandWeapon(weapontype1)) then
				self:CreateSetFromSkillData(weapon1,t,weapontype1, result, 1, 3)
				self:CreateSetFromSkillData(weapon2,t,weapontype2, result, 4, 5)								
			else
				if ( self:IsTwoHandWeapon(weapontype1) ) then
					self:CreateSetFromSkillData(weapon1,t,weapontype1, result, 1, 5)
				else
					self:CreateSetFromSkillData(weapon1,t,weapontype1, result, 1, 3)
				end
			end
		end
	end
	
	-- Add remaining skills to our unsorted skills if we don't have them yet
	for k,v in pairs ( result ) do
		if ( not self:GetSkillAndSkillSet(k) ) then
			self.skillsets["All"].skills[k] = v
		end
	end
end

-- Helper to reduce the redudant code spam
function sm_skill_profile:CreateSetFromSkillData(w, t, weapontype, currentskills, slotmin, slotmax)
	local id
	local prof = SkillManager:GetPlayerProfession()
	if ( w == 2 or w == 3) then
		id = tostring(w).."_"..tostring(t)
		
	elseif ( t >= 12 and t <=17 ) then -- revenant has "sets" which hold different heal - elite skills
		id = tostring(t)
	
	elseif ( t == 6 ) then -- necro death shroud
		id = tostring(t).."_"..tostring(ml_global_information.Player_SwimState)
		
	elseif (prof == GW2.CHARCLASS.Necromancer or prof == GW2.CHARCLASS.Necromancer or prof == GW2.CHARCLASS.Necromancer ) then
		id = tostring(w).."_"..tostring(t).."_"..tostring(weapontype)
	else
		id = tostring(w).."_"..tostring(weapontype)
	end
	
	if ( not self.skillsets[id] ) then
		local set = sm_skillset:new()
		set.id = id
		set.weaponsetid = w
		set.transformid = t
		set.weapontype = weapontype
		set.skills = {}
		
		for k,v in pairs ( currentskills ) do
			if ( v.slot >= slotmin and v.slot <= slotmax ) then set.skills[k] = v end
					
			if ( v.weapon_type and v.weapon_type ~= "None" ) then 
				if ( (slotmin == 1 and v.slot == 1) or (slotmin == 4 and v.slot == 4)) then
					set.name = v.weapon_type				
				end
			end
		end
				
		if ( (w == 2 or w == 3 ) and set.name == "" or set.name == "None") then
			if ( self.hardcodedsets[id] ~= nil ) then
				set.name = self.hardcodedsets[id].name
			else
				set.name = GetString("Bundle")
			end			
		
		else
			if ( t == 6 and ml_global_information.Player_SwimState == 0 and prof == GW2.CHARCLASS.Necromancer) then	set.name = GetString("Death Shroud")
			elseif ( t == 6 and ml_global_information.Player_SwimState == 1 and prof == GW2.CHARCLASS.Necromancer) then	set.name = GetString("Aqua Shroud")
				
			elseif ( t == 1 and prof == GW2.CHARCLASS.Elementalist ) then set.name = set.name..GetString(" Fire")
			elseif ( t == 2 and prof == GW2.CHARCLASS.Elementalist ) then set.name = set.name..GetString(" Water")
			elseif ( t == 3 and prof == GW2.CHARCLASS.Elementalist ) then set.name = set.name..GetString(" Air")
			elseif ( t == 4 and prof == GW2.CHARCLASS.Elementalist ) then set.name = set.name..GetString(" Earth")
			
			elseif ( t == 12 and prof == GW2.CHARCLASS.Revenant ) then set.name = GetString("Dragon Stance")
			elseif ( t == 13 and prof == GW2.CHARCLASS.Revenant ) then set.name = GetString("Assassin Stance")
			elseif ( t == 14 and prof == GW2.CHARCLASS.Revenant ) then set.name = GetString("Dwarf Stance")
			elseif ( t == 15 and prof == GW2.CHARCLASS.Revenant ) then set.name = GetString("Deamon Stance")
			elseif ( t == 17 and prof == GW2.CHARCLASS.Revenant ) then set.name = GetString("Centaur Stance")	
			end			
			
			if ( w == 5 ) then
				set.name = set.name.." 2"
			end
		end
				
		self.skillsets[id] = set	
		self.modified = true
	end			
end

-- Gets the additional skilldata from the gw2_skiull.data file and returns that
function sm_skill_profile:GetSkillDataByID( skillid )
	local skilldb = self.skilldata
	if (skilldb) then		
		local data = skilldb[skillid]
		if ( data ) then
			local result = {}
			for k,v in pairs (data) do 
				if ( k == "slot" ) then -- slot is also a value we use in the c++ skill table, dont wanna overwrite it
					result["slot_name"] = v
				else
					result[k] = v
				end
			end
			
			-- Trying to get the radius and range of the spell from the "facts" table
			local range = 0
			local radius = 0
				
			--[[
			if ( table.size(data.traited_facts) > 0 ) then
				for q,entry in pairs (data.traited_facts) do
					if ( entry.text and entry.text == "Range" and entry.type == "Range" and type(entry.value) == "number" and entry.value > range ) then 
						range = entry.value
					end
					if ( entry.text and entry.type == "Distance" and string.contains(entry.text,"Radius")  and entry.distance and type(entry.distance) == "number" and entry.distance > radius ) then 
						radius = entry.distance
					end
				end
			end]]
			
			if ( table.size(data.facts) > 0 ) then
				for q,entry in pairs (data.facts) do
					if ( entry.text and entry.text == "Range" and entry.type == "Range" and type(entry.value) == "number" and entry.value > range ) then 
						range = entry.value
					end
					if ( entry.text and entry.type == "Distance" and string.contains(entry.text,"Radius")  and entry.distance and type(entry.distance) == "number" and entry.distance > radius ) then 
						radius = entry.distance
					end
				end
			end

			if (radius > 0 ) then result["radius"] = radius end
			if (range > 0 ) then result["maxrange"] = range end
			
			return result
		end		
	else
		ml_error("[SkillManager] - Invalid skill data file!")
	end
end

-- Finds the skill (data) in all skillsets and returns that. A skill should be only ONCE in all skillsets ...
function sm_skill_profile:GetSkillAndSkillSet(id)
	for k,v in pairs(self.skillsets) do
		if (v.skills[id]) then
			return v.skills[id], v
		end
	end
end

-- Checks if the skill ID is used by the current profile/castlist
function sm_skill_profile:IsSkillInUse(skillid)
	for k,v in pairs(self.actionlist) do
		for a,s in pairs(v.sequence) do
			if ( s.id == skillid) then
				return true
			end
		end
	end
	return false
end


--********** SKILLSET 'CLASS' *************
-- the "container class" that groups together selected skills
function sm_skillset:initialize( data )
	if ( not data ) then data = {} end
	self.id = data.id or ""													-- internal id, 0 for unsortedskillset  and 4_0 for ex. for "Main Weapon" , it is a combinated string from Weaponset and GetTransformID
	self.name = data.name or ""										-- skillset name
	self.weaponsetid = data.weaponsetid or 0					-- skillset Player:GetCurrentWeaponSet()	
	self.transformid = data.transformid or 0						-- skillset Player:GetTransformID()
	self.weapontype = data.weapontype or 0						-- skillset item.weapontype
	self.activateskillid = data.activateskillid or 1				-- default id for "swap weapons" is 1, else it is a skillid or ele's F1-F4 or Necros skill IDs
	self.deactivateskillid = data.deactivateskillid or nil
	self.skills = data.skills or {}										-- all skills of this set,  tablekey is skillid
end


--********** ACTION 'CLASS' *************

-- Action "class" used by the Actionlist. Holding all variables and data for skills, conditions etc.
-- Default Class ctor
function sm_action:initialize(data)
	if ( not data ) then		
		self.sequence = { [1] = {id = 0, settings = {}, conditions = {} }}
	else
		self:Load(data)
	end
end
-- Saves all action data into a table and returns that for saving
function sm_action:Save()
	local data = {}
	data.name = self.name or GetString("[Empty Action]")
	data.sequence = {}
	local idx = 1
	for a,s in pairs ( self.sequence ) do
		s.conditioncodefunc = nil
		data.sequence[idx] = { id = s.id, settings = s.settings, conditioncode = s.conditioncode, conditions = {}, }		
		if ( table.valid(s.conditions) ) then
			for i,or_group in pairs(s.conditions) do			
				for k,v in pairs(or_group) do
					if ( type(v) == "table") then
						if ( not data.sequence[idx].conditions[i] ) then data.sequence[idx].conditions[i] = {} end
						data.sequence[idx].conditions[i][k] = v:Save()
					end				
				end
			end
		end
		idx = idx + 1
	end	
	return data
end
-- Loads the action from a former saved data table
function sm_action:Load(data)	
	self.name = data.name
	self.sequence = {}
	for a,s in pairs ( data.sequence ) do
		self.sequence[a] = {}
		self.sequence[a].id = s.id
		self.sequence[a].settings = s.settings or {}
		self.sequence[a].conditioncode = s.conditioncode
		self.sequence[a].conditions = {}		
		if ( table.valid(s.conditions) ) then		
			for i,or_group in pairs(s.conditions) do			
				self.sequence[a].conditions[i] = {}	-- create the "OR" group			
				for k,v in pairs(or_group) do
					if ( string.valid(v.class) ) then
						local condtemplate = SkillManager:GetCondition(v.class)				
						if ( condtemplate ) then
							local condition = condtemplate:new()	
							condition:Load(v)					
							self.sequence[a].conditions[i][k] = condition
						else
							ml_error("[SkillManager] - Unable To Load Condition, condition class not registered in SkillManager: "..tostring(v.class))
						end
							
					else
						ml_error("[SkillManager] - Unable To Load Condition, Invalid Condition Class on skill ID "..tostring(self.sequence[a].id))
					end
				end			
			end
		end
	end
end

function sm_action:Deselect()
	self.editskill = nil
	self.selectedskill = nil
	for k,v in pairs(self.sequence) do
		v.deletecount = nil
	end
end

-- Renders the Action Info, Details, Editor etc.
function sm_action:Render(profile)
	if ( not self.selectedskill ) then 
		self.selectedskill = select(1,next(self.sequence))		
		if ( self.selectedskill and self.sequence[self.selectedskill].id == 0 ) then 
			self.editskill = self.selectedskill
		end
	end
		
	if ( self.editskill ) then 
		local result = profile:RenderSkillSetEditor(self.sequence[self.editskill])
		if ( result == -1 ) then -- cancel
			self.editskill = nil 
		elseif ( result == -2 ) then -- accept
			if ( not self.name or not string.valid(self.name) or self.name == GetString("[Empty Action]") or table.size(self.sequence) == 1 ) then
				local skill = profile:GetSkillAndSkillSet(self.sequence[self.editskill].id)
				if ( skill ) then self.name = skill.name end
			end
			self.editskill = nil 
			profile.modified = true
		end
			
	else
		
		GUI:AlignFirstTextHeightToWidgets()
		GUI:PushItemWidth(180)
		GUI:Text(GetString("Name:"))
		local changed
		GUI:SameLine(100)
		self.name, changed = GUI:InputText( "##actionname", self.name or GetString("[Empty Action]"))
		GUI:PopItemWidth()
		if ( changed ) then profile.modified = true end	
			
		GUI:SameLine(599)	
		local highlighted
		if ( self.deletecount ) then
			GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
			GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
			GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
			GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
			highlighted = true
		end
		if ( GUI:ImageButton("##smdelete",profile.texturepath.."\\w_delete.png",13,13)) then -- delete whole action, not just a single skill of the sequence
			self.deletecount = self.deletecount ~= nil and 2 or 1
			if ( self.deletecount == 2 ) then
				GUI:PopStyleColor(4)
				return -1 
			end		
		end
		if ( highlighted ) then GUI:PopStyleColor(4) end
		GUI:Separator()
		
	-- Skill Sequence Buttons
		GUI:Text(GetString("Skill Sequence:"))
		if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add multiple skills to create a Combo. Skills are cast in order from 'Left' to 'Right'!")) end
		local neededheight = math.max(40, math.ceil(#self.sequence / 11)*40 )
		GUI:BeginChild("##actionsequence", 600,neededheight)
		local count = 1
		for k,v in pairs ( self.sequence ) do
			local highlight
			if ( self.selectedskill == k ) then
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.9)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,1.0)
				highlight = true
			end		
			local skill = profile:GetSkillAndSkillSet(v.id)	
			if ( skill ) then
				if ( GUI:ImageButton("##smseq"..tostring(k), profile.texturecache.."\\default.png",30,30) ) then				
					self.selectedskill = k				
				end
			else
				if ( GUI:ImageButton("##smseq"..tostring(k), profile.texturecache.."\\blank.png",30,30) ) then
					self.selectedskill = k
				end
			end
			if ( highlight ) then GUI:PopStyleColor(3) end
			local name = skill and skill.name or GetString("Skill")
			if (GUI:IsItemHovered()) then GUI:SetTooltip( name or "Unknown") end
			
			count = count + 1
			if (count % 13 ~= 0) then GUI:SameLine() end			
		end
		
		-- Add new Skill to Sequence button		
		if ( GUI:Button("+##sequence", 35, 35) ) then 
			-- Create a new cast list entry
			table.insert(self.sequence, {id = 0, settings = {}, conditions = {} })
			self.editskill = #self.sequence
			self.selectedskill = #self.sequence
		end		
		if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Add a Skill to the Sequence, to create a Combo")) end
		GUI:EndChild()
	
		GUI:Separator()
		if ( self.selectedskill and self.sequence[self.selectedskill] ) then
			GUI:Text(GetString("Skill Details:"))
		-- Skill Delete button
			if ( #self.sequence > 1 ) then
				GUI:SameLine(599)	
				local highlighted
				if ( self.sequence[self.selectedskill].deletecount ) then
					GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
					GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
					GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
					GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
					highlighted = true
				end
				if ( GUI:ImageButton("##smdeleteskill",profile.texturepath.."\\w_delete.png",13,13)) then -- delete whole action, not just a single skill of the sequence
					self.sequence[self.selectedskill].deletecount = self.sequence[self.selectedskill].deletecount ~= nil and 2 or 1
					if ( self.sequence[self.selectedskill].deletecount == 2 ) then
						GUI:PopStyleColor(4)
						table.remove(self.sequence,self.selectedskill)
						return true
					end		
				end
				if ( highlighted ) then GUI:PopStyleColor(4) end
			end
			
			GUI:Columns(3)
			GUI:SetColumnOffset(1,60)
			GUI:SetColumnOffset(2,325)
			GUI:Dummy(30,10)
			local skilldata, set = profile:GetSkillAndSkillSet(self.sequence[self.selectedskill].id)
			if ( skilldata ) then
				if ( GUI:ImageButton("##sm"..tostring(i), sm_skill_profile.texturecache.."\\default.png",40,40) ) then				
					self.editskill = self.selectedskill
				end
			else
				if ( GUI:ImageButton("##sm"..tostring(i), sm_skill_profile.texturecache.."\\blank.png",40,40) ) then
					self.editskill = self.selectedskill
				end
			end
			if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Change the Skill.")) end
			
			if ( skilldata ) then
				GUI:NextColumn()
			
				GUI:BulletText(GetString("Name:")) GUI:SameLine(125) GUI:Text(skilldata.name)
				GUI:BulletText(GetString("Skill ID:")) GUI:SameLine(125) GUI:Text(skilldata.id)				
				GUI:BulletText(GetString("Slot:")) GUI:SameLine(125) GUI:Text(skilldata.slot ~= nil and tostring(skilldata.slot) or tostring(0))
				GUI:BulletText(GetString("Type:")) GUI:SameLine(125) GUI:Text(skilldata.type ~= nil and tostring(skilldata.type) or tostring(0))
				GUI:BulletText(GetString("Weapon:")) GUI:SameLine(125) GUI:Text(skilldata.weapon_type ~= nil and tostring(skilldata.weapon_type) or tostring(0))
				if ( skilldata.flip_level and skilldata.flip_level > 0 ) then GUI:BulletText(GetString("Chain Level:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.flip_level)) end
				if ( skilldata.cooldownmax ) then
					if ( skilldata.cooldown ) then GUI:BulletText(GetString("Cooldown:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.cooldown).. " / "..tostring(skilldata.cooldownmax))
					else
						GUI:BulletText(GetString("Cooldown:")) GUI:SameLine(125) GUI:Text(" 0 / "..tostring(skilldata.cooldownmax))
					end
				end
				GUI:NextColumn()
				if ( skilldata.maxrange and skilldata.maxrange > 0) then GUI:BulletText(GetString("Max.Range:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.maxrange)) end
				if ( skilldata.minrange and skilldata.minrange > 0) then GUI:BulletText(GetString("Min.Range:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.minrange)) end
				if ( skilldata.radius and skilldata.radius > 0 ) then GUI:BulletText(GetString("Radius:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.radius)) end
				if ( skilldata.power and skilldata.power > 0 ) then GUI:BulletText(GetString("Req.Power:")) GUI:SameLine(125) GUI:Text(tostring(skilldata.power)) end				
				
				GUI:BulletText(GetString("Skill Set:")) GUI:SameLine(125) GUI:Text(tostring(set.name))
				local currentsets = profile:GetCurrentSkillSets()				
				for q,currentset in pairs ( currentsets ) do
					if ( currentset ) then
						GUI:BulletText(GetString("Current Set: ")) GUI:SameLine(125) GUI:Text(tostring(currentset.name))
					end
				end
			
				GUI:Columns(1)
				GUI:Separator()
		-- Skill Settings
				local changed
				GUI:Text(GetString("Skill Settings:"))	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Special Settings for this Skill" )) end
				self.sequence[self.selectedskill].settings.castonplayer, changed = GUI:Checkbox( GetString("Cast on Player"), self.sequence[self.selectedskill].settings.castonplayer or false) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, the Skill will be cast on the Player and not on the Target." )) end if (changed) then modified = true end
				if ( changed ) then profile.modified = true end
				
				if ( not self.sequence[self.selectedskill].settings.castonplayer ) then
					GUI:SameLine(200)
					self.sequence[self.selectedskill].settings.nolos, changed = GUI:Checkbox( GetString("No Line of Sight"), self.sequence[self.selectedskill].settings.nolos or false) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, the line of sight to the target will not be checked when casting." )) end if (changed) then modified = true end
					if ( changed ) then profile.modified = true end
				end
				
				if ( self.sequence[self.selectedskill].settings.maxrange and self.sequence[self.selectedskill].settings.maxrange > 154 ) then
					if ( not self.sequence[self.selectedskill].settings.castonplayer ) then
						GUI:SameLine(400)
					else
						GUI:SameLine(200)
					end
					if ( self.sequence[self.selectedskill].settings.setsattackrange == nil ) then self.sequence[self.selectedskill].settings.setsattackrange = true end
					self.sequence[self.selectedskill].settings.setsattackrange, changed = GUI:Checkbox( GetString("Sets Attackrange"), self.sequence[self.selectedskill].settings.setsattackrange) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, the 'MaxRange' of the Skill defines the Attackrange of the bot." )) end if (changed) then modified = true end				
					if ( changed ) then profile.modified = true end
				end
				
				self.sequence[self.selectedskill].settings.slowcast, changed = GUI:Checkbox( GetString("Slow Cast"), self.sequence[self.selectedskill].settings.slowcast or false) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("If Enabled, the Skill will be cast until the end. Use this if the skill gets interrupted while casting." )) end if (changed) then modified = true end
				if ( changed ) then profile.modified = true end
				
				if ( not self.sequence[self.selectedskill].settings.castonplayer ) then
					GUI:PushItemWidth(100)				
					if ( self.sequence[self.selectedskill].settings.maxrange == nil ) then self.sequence[self.selectedskill].settings.maxrange = skilldata.maxrange or 0 end
					self.sequence[self.selectedskill].settings.maxrange, changed = GUI:InputInt(GetString("Max.Range"), self.sequence[self.selectedskill].settings.maxrange, 1, 10, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)		
					if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("The max. distance to the target where this skill should be cast. Don't touch this if you don't know what you are doing!" )) end if (changed) then profile.modified = true end
					GUI:SameLine(200)
					if ( self.sequence[self.selectedskill].settings.minrange == nil ) then self.sequence[self.selectedskill].settings.minrange = skilldata.minrange or 0 end
					self.sequence[self.selectedskill].settings.minrange, changed = GUI:InputInt(GetString("Min.Range"), self.sequence[self.selectedskill].settings.minrange, 1, 10, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)		
					if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("The min. distance to the target where this skill should be cast. Don't touch this if you don't know what you are doing!" )) end if (changed) then profile.modified = true end
					GUI:SameLine(400)
					if ( self.sequence[self.selectedskill].settings.radius == nil ) then self.sequence[self.selectedskill].settings.radius = skilldata.radius or 0 end
					self.sequence[self.selectedskill].settings.radius, changed = GUI:InputInt(GetString("Radius"), self.sequence[self.selectedskill].settings.radius, 1, 10, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)		
					if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("The impact / damage / effect radius of this skill. Don't touch this if you don't know what you are doing!" )) end if (changed) then profile.modified = true end
					
					GUI:PopItemWidth()
					
				end
				
				GUI:Separator()
				
				GUI:Spacing()
		
		-- Condition Builder
				GUI:Text(GetString("Cast if:"))	if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Cast this Skill if..." )) end
				GUI:BeginChild("##actioncondigrp", 625,300)
				if ( table.size(self.sequence[self.selectedskill].conditions) > 0 ) then
					for idx,or_group in pairs(self.sequence[self.selectedskill].conditions) do
						for k,v in pairs(or_group) do
							if ( type(v) == "table") then
								if (v:Render(tostring(idx)..tostring(k))) then profile.modified = true end
								GUI:SameLine(590)
								local highlighted
								if ( v.deletecount ) then
									GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
									GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
									GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
									GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
									highlighted = true
								end	
								if ( GUI:ImageButton("##actiondelcondi"..tostring(idx)..""..tostring(k),profile.texturepath.."\\w_delete.png",15,15)) then
									v.deletecount = v.deletecount ~= nil and 2 or 1
									if ( v.deletecount == 2 ) then
										self.sequence[self.selectedskill].conditions[idx][k] = nil
										if ( table.size(self.sequence[self.selectedskill].conditions[idx]) == 0) then
											self.sequence[self.selectedskill].conditions[idx] = nil
										end
										profile.modified = true
									end
								end
								if ( highlighted ) then GUI:PopStyleColor(4) end
							end
						end
						
									
						-- Add New Condition Button
						if ( or_group.addnew ) then
							local conditions = SkillManager:GetConditions()
							if ( table.valid(conditions)) then
								local combolist = {}
								local i = 1
								for k,v in pairs(conditions) do
									combolist[i] = GetString(tostring(v))
									i = i+1
								end
								or_group.addnew = GUI:Combo("##addcondinew",or_group.addnew, combolist)
								if ( combolist[or_group.addnew]) then
									GUI:SameLine()
									if (GUI:Button(GetString("Add").."##addnewcond"..tostring(idx), 50,20)) then
										for k,v in pairs(conditions) do						
											or_group.addnew = or_group.addnew-1
											if ( or_group.addnew == 0 ) then
												local newcond = v:new()
												table.insert(self.sequence[self.selectedskill].conditions[idx], newcond)
												or_group.addnew = nil
												profile.modified = true
												break
											end
										end					
									end
								end
							else
								GUI:Text("ERROR: NO CONDITIONS REGISTERED IN THE SKILLMANAGER")
							end
						elseif ( GUI:Button(GetString("+ AND").."##addcondi"..tostring(idx), 60,20)) then 
							self.sequence[self.selectedskill].conditions[idx].addnew = 1
						end
						
						if ( idx < #self.sequence[self.selectedskill].conditions ) then
							GUI:Text(GetString("OR Cast if:"))
						end
					end
							
					-- Add a new OR Group:
					GUI:Spacing()
					if (GUI:Button(GetString("+ OR").."##addcondOR"..tostring(idx), 60,20)) then
						local newgroup = { addnew = 1, }
						table.insert(self.sequence[self.selectedskill].conditions,newgroup)
					end
					
				else
					if (GUI:Button(GetString("+ Add New Condition").."##addcondOR2", 150,20)) then
						local newgroup = { addnew = 1, }
						table.insert(self.sequence[self.selectedskill].conditions,newgroup)
					end
				end
					
				GUI:EndChild()
				
				GUI:Spacing()
				GUI:Spacing()
				GUI:Separator()
		
		-- Custom Condition editor
				local _,maxy = GUI:GetContentRegionAvail()
				GUI:SetNextTreeNodeOpened(false,GUI.SetCond_Once)
				if ( GUI:TreeNode(GetString("CUSTOM CONDITION CODE EDITOR")) ) then			
					if ( GUI:IsItemHovered() ) then GUI:SetTooltip(GetString("Write you own Lua code, when to cast this skill. Must return 'true' or 'false'!")) end
					local maxx,_ = GUI:GetContentRegionAvail()
					local changed = false
					self.sequence[self.selectedskill].conditioncode, changed = GUI:InputTextEditor( "##smactioncodeeditor", self.sequence[self.selectedskill].conditioncode or GetString("-- Return 'true' when the skill can be cast, else 'false'. Share data through 'context' table.\n \n-- You can use:'this', 'context.currentskills', 'context.casthistory'\nreturn true"), maxx, math.max(maxy/2,300) , GUI.InputTextFlags_AllowTabInput)
					if ( changed ) then self.sequence[self.selectedskill].conditioncodechanged = true profile.modified = true end
					if ( self.sequence[self.selectedskill].conditioncodechanged ) then
						GUI:PushStyleColor(GUI.Col_Button,1.0,0.75,0.0,0.7)
						GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.75,0.0,0.8)
						GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.75,0.0,0.9)
						GUI:PushStyleColor(GUI.Col_Text,1.0,1.0,1.0,1.0)
						if ( GUI:Button(GetString("Save Changes"),maxx,20) ) then
							self.sequence[self.selectedskill].conditioncodechanged = nil
							profile:Save()
						end				
						GUI:PopStyleColor(4)
					end
					GUI:PushItemWidth(600)
					GUI:Dummy(600,1)
					GUI:PopItemWidth()
					GUI:TreePop()
				end
				GUI:Separator()
			end
		end
	end
end

-- Checks if a skill of the sequence can be cast by evaluating all conditions
function sm_action:CanCastSkill(profile, targetskillset, sequenceid, skilldata, ignorerangecheck) -- ignorerangecheck is for the calls from "Update()" which evaluate which skill can be cast 
	if ( self.sequence[sequenceid] ~= nil ) then
		
		local skill = self.sequence[sequenceid]

		-- Basic Settings
		if ( not skill.settings.castonplayer and not profile.context.target ) then return false end	-- can't use skill if it is meant to be cast on a target and we don'T have one
		if ( not skill.settings.castonplayer and not skill.settings.nolos and (not profile.context.target or not profile.context.target.los)) then return false end		-- can't use skill if it requires los but we don't have los to our target - TODO: Move this below the other checks and check against "customtarget" ?				
		if ( not skill.settings.slowcast and skilldata.lastcast ) then -- normal spells have 0,5s cast time Unless checked to be cast fast or slow, use this as default 
			-- We dont have the actual casttime of the spells ...so kinda improvising here 
			if ( (sequenceid <= 1 and ml_global_information.Now - skilldata.lastcast > profile.castspeed) or ml_global_information.Now - skilldata.lastcast > 1000 ) then 
				if ( ((ml_global_information.Now - skilldata.lastcast > 1500) and (not skilldata.cooldown or skilldata.cooldown <= 0)) or ml_global_information.Now - skilldata.lastcast > 2500 ) then
					skilldata.lastcast = nil
				end
				return false
			end
		end
		if ( skilldata.cooldown and skilldata.cooldown > 0 ) then return false end
		
		-- Thief Initiative
		if ( skilldata.initiative and skilldata.initiative > 0 ) then
			if ( ml_global_information.Player_Buffs[14081] ) then -- Trickery trait equipped
				if ( (skilldata.initiative * 100 / 15) > ml_global_information.Player_Power ) then return false end	
			else
				if ( (skilldata.initiative * 100 / 12) > ml_global_information.Player_Power ) then return false end	
			end
		end
		-- Revenant Costs mechanic
		if ( skilldata.cost and skilldata.cost > 0 and skilldata.cost > ml_global_information.Player_Power ) then return false end
		
		-- Range Check
		if ( not ignorerangecheck and sequenceid <= 1 and not skill.settings.castonplayer and profile.context.target ) then
			local maxrange = skill.settings.maxrange or skilldata.maxrange or 0
			if ( maxrange == 0 ) then maxrange = skill.settings.radius or skilldata.radius or 0 end
			local minrange = skill.settings.minrange or skilldata.minrange or 0
			local targetdist = profile.context.target.distance - (profile.context.target.radius or 0)
			if ( minrange > 0 and targetdist < minrange ) then return false end
			if ( maxrange > 0 and targetdist > maxrange ) then return false end
		end
		
		-- Check if we need to swap sets and if that is possible		
		local swapresult = profile:CanSwapToSet(targetskillset, self, sequenceid)
		if ( swapresult == nil or swapresult == false )  then
			return false -- We cannot currently "reach" the skillset which contains this skill		
		end
		
		-- Evaluate custom code first		
		if ( skill.conditioncode ) then
			if ( not skill.conditioncodefunc and not skill.conditioncodebugged ) then
				local execstring = 'return function(context,this) '..skill.conditioncode..' end'
				local func = loadstring(execstring)
				if ( func ) then
					func()(profile.context, skilldata)
					skill.conditioncodefunc = func	
				else
					skill.conditioncodebugged = true
					ml_error("[SkillManager] - Custom Condition Code Editor compilation error in Action ".. tostring(self.name ~= "" and self.name or "").." at skill "..tostring(sequenceid))
					assert(loadstring(execstring)) -- print out the actual error
				end
			end
			
			if ( skill.conditioncodefunc and not skill.conditioncodefunc()(profile.context,skilldata) ) then 
				return false
			end
		end

		-- Go through all Conditions
		if ( table.size(skill.conditions) > 0 ) then
			for i,or_group in pairs( skill.conditions ) do
				-- Either of the or_groups needs to be true for the skill to be castable
				local cancast = true
				for k,v in pairs(or_group) do
					if ( type(v) == "table") then
						if ( not v:Evaluate(Player, profile.context.target) ) then
							cancast = false
							break
						end
					end
				end
				if ( cancast ) then	return true end
			end
			return false
		end
		return true -- in case there is only custom condition code or no code at all
	end
	return false
end

function sm_skill_profile:IsTwoHandWeapon(weapontype)
	return weapontype == 1 or weapontype == 2 or weapontype == 6 or weapontype == 10 or weapontype == 12 or weapontype == 19 or weapontype == 20 or weapontype == 21
end

-- Which sets we are currently having active
function sm_skill_profile:GetCurrentSkillSets()
	local availablesets = {}
	table.insert(availablesets,self.skillsets["All"])
	
	local w = Player:GetCurrentWeaponSet()
	local t = Player:GetTransformID()
	
	if ( w == 2 or w == 3 ) then
		if ( self.currentskills and self.currentskills[3] ) then--reaper
			if ( t ~= 6 ) then				
				table.insert(availablesets,self.skillsets[tostring(w).."_"..tostring(self.currentskills[3].skillid)])
			else
				table.insert(availablesets,self.skillsets[tostring(w).."_"..tostring(t)])
			end
		end
			
	elseif ( t == 6 ) then
		table.insert(availablesets,self.skillsets[tostring(t).."_"..tostring(ml_global_information.Player_SwimState)])
		
	else
	
		local weapon1, weapontype1, weapon2, weapontype2				
		-- for all water weapons
		if ( w == 0 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon)
			if ( item ) then weapon1 = 0  weapontype1 = item.weapontype end
		elseif( w == 1 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon)
			if ( item ) then weapon1 = 0  weapontype1 = item.weapontype end
		
		-- Main & Offhand 
		elseif ( w == 4 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon)
			if ( item ) then 
				weapon1 = 4  weapontype1 = item.weapontype -- Mainhand				
			end			
			if ( not item or not self:IsTwoHandWeapon(weapontype1) ) then
				local item2 = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon)
				if ( item2 ) then weapon2 = 5  weapontype2 = item2.weapontype end	-- Offhand			
			end
			
		-- 2nd Main & Offhand 
		elseif ( w == 5 ) then
			local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
			if ( item ) then 
				weapon1 = 4  weapontype1 = item.weapontype -- Mainhand				
			end
			if ( not item or not self:IsTwoHandWeapon(weapontype1) ) then				
				local item2 = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon) or Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
				if ( item2 ) then weapon2 = 5  weapontype2 = item2.weapontype end	-- Offhand			
			end
			
		end
						
		if ( t >= 12 and t <=17 ) then
			if ( weapon2 ) then
				table.insert(availablesets,self.skillsets[tostring(weapon1).."_0_"..tostring(weapontype1)])
				table.insert(availablesets,self.skillsets[tostring(weapon2).."_0_"..tostring(weapontype2)])
			else
				table.insert(availablesets,self.skillsets[tostring(weapon1).."_0_"..tostring(weapontype1)])
			end
			table.insert(availablesets,self.skillsets[tostring(t)]) 
			
		else
			local prof = SkillManager:GetPlayerProfession()		
			if ( t >= 12 and t <=17 ) then
				if ( weapon2 ) then
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_0_"..tostring(weapontype1)])
					table.insert(availablesets,self.skillsets[tostring(weapon2).."_0_"..tostring(weapontype2)])
				else
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_0_"..tostring(weapontype1)])
				end
				table.insert(availablesets,self.skillsets[tostring(t)]) 
				
			elseif (prof == GW2.CHARCLASS.Necromancer or prof == GW2.CHARCLASS.Elementalist or prof == GW2.CHARCLASS.Revenant ) then
				if ( weapon2 ) then
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_"..tostring(t).."_"..tostring(weapontype1)])
					table.insert(availablesets,self.skillsets[tostring(weapon2).."_"..tostring(t).."_"..tostring(weapontype2)])
				else
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_"..tostring(t).."_"..tostring(weapontype1)])
				end
			else
				if ( weapon2 ) then
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_"..tostring(weapontype1)])
					table.insert(availablesets,self.skillsets[tostring(weapon2).."_"..tostring(weapontype2)])
				else
					table.insert(availablesets,self.skillsets[tostring(weapon1).."_"..tostring(weapontype1)])
				end
			end
		end
	end	
	return availablesets
end

-- checks if the currently equipped weapons equal the passed weapontype, so we know if switching a weapon would enable us to cast a spell from that weapon
function sm_skill_profile:HasWeaponAvailable(skillset)
	if ( table.size(self.weaponsets) > 0 ) then
		for k,v in pairs(self.weaponsets) do
			if ( v.weapontype == skillset.weapontype and v.weaponsetid == skillset.weaponsetid ) then
				return true
			end
		end
	end
	return false
end

-- Little helper to reduce the redudant code
function sm_skill_profile:CanSwapWeapon()	
	return ( Player:CanSwapWeaponSet() and prof ~= GW2.CHARCLASS.Elementalist and prof ~= GW2.CHARCLASS.Engineer or Player:GetCurrentWeaponSet() == 2)
end

-- Returns the skill ID to cast, for the case we have to swap to the Targetskillset. Returns false if it cannot reach the wanted set, returns true if it is already on the set
function sm_skill_profile:CanSwapToSet(targetskillset, action , sequenceid)
	-- happens
	if ( not ml_global_information.Player_Alive or not self.sets or table.size(self.sets) == 0 ) then return false end
		
	-- We have the targetskill set on our current bar
	for k,v in pairs (self.sets) do
		if ( v.id == targetskillset.id ) then
			-- Check additionally if the wanted skill is available / can be cast
			local skill = action.sequence[sequenceid]
			local skilldata, skillset = self:GetSkillAndSkillSet(skill.id)		
			if ( not skilldata or not self.currentskills[skilldata.slot] or (self.currentskills[skilldata.slot].skillid ~= skill.id and sequenceid == 1 )) then --and skilldata.flip_level == 0)) then -- exclude all skilldata.flip_level > 0, to allow combos				
				return false		-- Skill is not on the position where it should be on our current sets
			else
				return true		-- Skill on our current sets
			end
		end
	end
	-- ADD A CHECK FOR "ARE WE IN A TRANSFORMATION (w == 3)  where we cannot go out from ?
		
		
		
	-- We need to switch to the target skillset in order to reach the skill we want to cast, check if the set can be swapped to
	if ( targetskillset.weaponsetid == 0 and targetskillset.transformid < 12) then -- underwater set
		if (ml_global_information.Player_SwimState == 0 or not self:HasWeaponAvailable(targetskillset) or not self:CanSwapWeapon()) then -- we are not under water
			return false
		else
			return -1	-- we need to swap weapons
		end		
	
	elseif ((targetskillset.weaponsetid == 2 or targetskillset.weaponsetid == 3) and (targetskillset.id ~= "3_6" and targetskillset.id ~= "3_10633" and targetskillset.id ~= "3_10663")) then --Bundles, Transformations and pickup weapons, check if the skillID to actiavte the bundle is on our current set and can be activated
		local skilldata, skillset = self:GetSkillAndSkillSet(targetskillset.activateskillid)
		
		if ( not skilldata or not self.currentskills[skilldata.slot] or self.currentskills[skilldata.slot].skillid ~= skilldata.id or not self.currentskills[skilldata.slot].cancast) then
			return false
		else			
			-- Engi special fuck gren case
			if (skilldata.id == 5805 and ((targetskillset.id == "2_5808" and ml_global_information.Player_SwimState == 1) or (targetskillset.id == "2_6169" and ml_global_information.Player_SwimState == 0))) then -- not allowing underwater gren kit on land and the other way around
				return false
			else
				return skilldata.slot	-- Returning the slot that has to be cast to activate the skillset
			end
		end

	else
	
		local prof = SkillManager:GetPlayerProfession()
		-- Ele's attunements
		if ( prof == GW2.CHARCLASS.Elementalist and (targetskillset.weaponsetid == 4 or targetskillset.weaponsetid == 5) ) then
			if ( targetskillset.transformid == 1 and self:HasWeaponAvailable(targetskillset) and self.currentskills[13] and self.currentskills[13].cancast ) then return 13 end
			if ( targetskillset.transformid == 2 and self:HasWeaponAvailable(targetskillset) and self.currentskills[14] and self.currentskills[14].cancast ) then return 14 end
			if ( targetskillset.transformid == 3 and self:HasWeaponAvailable(targetskillset) and self.currentskills[15] and self.currentskills[15].cancast ) then return 15 end
			if ( targetskillset.transformid == 4 and self:HasWeaponAvailable(targetskillset) and self.currentskills[16] and self.currentskills[16].cancast ) then return 16 end
			return false
		end
		
		-- Revenant's stances
		if ( prof == GW2.CHARCLASS.Revenant and (targetskillset.transformid == 12 or targetskillset.transformid == 13 or targetskillset.transformid == 14 or targetskillset.transformid == 15 or targetskillset.transformid == 17)) then
			-- Check for both slots which could hold the swap stance skill
			if ( targetskillset.transformid == 12 ) then -- Dragon 
				if ( self.currentskills[13] and self.currentskills[13].skillid == 28229 and self.currentskills[13].cancast ) then return 13
				elseif (self.currentskills[17] and self.currentskills[17].skillid == 28229 and self.currentskills[17].cancast) then return 17
				end
			end
			
			if ( targetskillset.transformid == 13 ) then -- Assassin				
				if ( self.currentskills[13] and self.currentskills[13].skillid == 27659 and self.currentskills[13].cancast ) then return 13
				elseif (self.currentskills[17] and self.currentskills[17].skillid == 27659 and self.currentskills[17].cancast) then return 17
				end
			end
				
			if ( targetskillset.transformid == 14 ) then -- Dwarf
				if ( self.currentskills[13] and self.currentskills[13].skillid == 26650 and self.currentskills[13].cancast ) then return 13
				elseif (self.currentskills[17] and self.currentskills[17].skillid == 26650 and self.currentskills[17].cancast) then return 17
				end
			end
			
			if ( targetskillset.transformid == 15 ) then -- Deamon
				if ( self.currentskills[13] and self.currentskills[13].skillid == 28376 and self.currentskills[13].cancast ) then return 13
				elseif (self.currentskills[17] and self.currentskills[17].skillid == 28376 and self.currentskills[17].cancast) then return 17
				end
			end			
	
			if ( targetskillset.transformid == 15 ) then -- Centaur
				if ( self.currentskills[13] and self.currentskills[13].skillid == 28141 and self.currentskills[13].cancast ) then return 13
				elseif (self.currentskills[17] and self.currentskills[17].skillid == 28141 and self.currentskills[17].cancast) then return 17
				end
			end		
			
			return false
		end
		
		
		-- Necro 
		if (prof == GW2.CHARCLASS.Necromancer ) then
			if ( targetskillset.id == "6_0" or targetskillset.id == "6_1" or targetskillset.id == "3_6" ) then -- normal shroud, underwater shroud and reaper shroud
				if ( self.currentskills[13] and self.currentskills[13].cancast and self.currentskills[13].skillid == targetskillset.activateskillid ) then 
					return 13
				else
					return false
				end
			elseif(targetskillset.id == "3_10633" or targetskillset.id == "3_10663") then -- Lich & Plaque
				if ( self.currentskills[10] and self.currentskills[10].cancast and self.currentskills[10].skillid == targetskillset.activateskillid ) then 									
					return 10
				else
					return false
				end
			end
		end

		-- All remaining cases, should be only switch weapons ?
		if ( targetskillset.activateskillid == 1 ) then			
			--d("self:HasWeaponAvailable(targetskillset): "..tostring(targetskillset.name).. " : "..tostring(self:HasWeaponAvailable(targetskillset)))
			if ((targetskillset.weaponsetid == 4 or targetskillset.weaponsetid == 5) and ml_global_information.Player_SwimState == 0 and self:HasWeaponAvailable(targetskillset) and self:CanSwapWeapon() ) then
				return -1	-- good to swap				
			else
				return false
			end		
		end
		
	end
	d("UNHANDLED CASE : "..tostring(targetskillset.name).. " ID " ..tostring(targetskillset.id).." - weaponsetid "..tostring(targetskillset.weaponsetid))
end

-- Gets "next" skill that can be cast.
function sm_skill_profile:GetNextSkillForCasting()
	-- We casted an action before, check if this action is a sequence and pick the next skill if possible
	if ( self.currentaction ) then
		self.currentactionsequence = self.currentactionsequence + 1 
		local action = self.actionlist[self.currentaction]
		if ( action.sequence[self.currentactionsequence] ) then			
			local skilldata, skillset = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence].id)
			if ( skilldata and action:CanCastSkill(self, skillset, self.currentactionsequence, skilldata)) then				
				return true -- continue to cast the sequence / combo
			end
		end
	end
	
	-- We need a new action which we can cast
	for k,action in pairs(self.actionlist) do
		-- check if all skills in an action sequence can be cast, before selecting it ... this has some limitations obviously in the cancast conditions...
		local cancast = true
		for i,skill in pairs(action.sequence) do
			local skilldata, skillset = self:GetSkillAndSkillSet(skill.id)
			if ( not skilldata or not action:CanCastSkill(self, skillset, i, skilldata)) then				
				cancast = nil
			end			
		end
		if ( cancast ) then
			self.currentaction = k
			self.currentactionsequence = 1
			return true
		end
	end
	self.currentaction = nil
	self.currentactionsequence = nil	
end

-- to make these stupid flipskills work in a combo
function sm_skill_profile:NextSkillIsChainSkill()
	if ( self.currentaction ) then
		local action = self.actionlist[self.currentaction]
		if ( action.sequence[self.currentactionsequence+1] ) then
			local skilldata, skillset = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence].id)
			local skilldata2, skillset2 = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence+1].id)							
			if ( skilldata and skilldata2 and skilldata.slot == skilldata2.slot and skilldata2.flip_level > skilldata.flip_level and action:CanCastSkill(self, skillset2, self.currentactionsequence+1, skilldata2)) then
				return true -- continue to cast the sequence / combo
			end
		end
	end
	return false
end

-- Casting
function sm_skill_profile:Cast()	
		
	if ( not ml_global_information.Player_CastInfo ) then d("[SkillManager] - No Player CastInfo table !?") return end
	
	-- Setting a "current action to cast"
	if ( not self.currentaction ) then self:GetNextSkillForCasting() end
	
	if ( self.currentaction ) then
		local action = self.actionlist[self.currentaction]
		if ( not action or not action.sequence[self.currentactionsequence]) then 
			-- someone deleted an action from the list
			self.currentaction = nil
			self.currentactionsequence = nil	
			return
		end
		local skilldata, skillset = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence].id)		
		if ( skilldata ) then
			
			-- Make sure we can still cast the spell that we picked earlier, if somethign changed and we cannot cast it, get a new skill instead
			if ( not ml_global_information.Player_CastInfo.skillid == skilldata.id and not action:CanCastSkill(self, skillset, self.currentactionsequence, skilldata)) then					
				self.currentaction = nil
				self.currentactionsequence = nil	
				if (self:GetNextSkillForCasting() ) then	-- get a new spell
					action = self.actionlist[self.currentaction]
					skilldata, skillset = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence].id)								
				else
					return
				end
			end

			-- If skill is already on CD, or if it is a spammable skill and our lastskillid is showing we cast it, get the next skill in the sequence OR a new action
			-- or when we have a chainskill..?
			if (skilldata and ((skilldata.cooldown and skilldata.cooldown ~= 0) or ( not action.sequence[self.currentactionsequence].settings.slowcast and (skilldata.lastcast and (ml_global_information.Now - skilldata.lastcast > self.castspeed ))) or (skilldata.cooldownmax and skilldata.cooldownmax == 0 and ml_global_information.Player_CastInfo.lastskillid == skilldata.id) 
				or ( ml_global_information.Player_CastInfo.skillid == skilldata.id and self:NextSkillIsChainSkill() and (not self.context.lastcast or (self.lasttick - self.context.lastcast >= self.castspeed))))) then
				if (self:GetNextSkillForCasting() ) then-- get a new / next skill
					action = self.actionlist[self.currentaction]
					skilldata, skillset = self:GetSkillAndSkillSet(action.sequence[self.currentactionsequence].id)								
				else
					return
				end
			end
								
			-- We are not casting the skill yet,...trying to do so ...
			if (skilldata and action and action.sequence[self.currentactionsequence] and (not skilldata.cooldown or skilldata.cooldown == 0) and (not skilldata.lastcast or (ml_global_information.Now - skilldata.lastcast > self.castspeed)) and (ml_global_information.Player_CastInfo.skillid ~= skilldata.id or (skilldata.slot == 1 and skilldata.cooldownmax and skilldata.cooldownmax == 0))) then
				-- Ensure the correct Weapon Set
				local switchslot = self:CanSwapToSet(skillset,action,self.currentactionsequence) 
				if ( switchslot == false ) then
					d("Could not swap to weaponset which holds "..tostring(skilldata.name))
					
				elseif( switchslot == true ) then
					--- all good
					
				elseif ( switchslot == -1 ) then
					-- swap weapons
					Player:SwapWeaponSet()
					self.context.lastcast = self.lasttick
					d("Swapping Main Weaponset")
					return
					
				elseif ( switchslot >= 0 ) then
					-- cast spell to swap sets
					Player:CastSpell(GW2.SKILLBARSLOT["Slot_" .. switchslot])
					d("Swapping weaponset to "..tostring(GW2.SKILLBARSLOT["Slot_" .. switchslot]))
					self.context.lastcast = self.lasttick
					return
					
				else
					d("Unhandled CanSwapToSet case in castspell ! : "..tostring(switchslot))
					return 
				end
				
				
				-- Cast
				local target = self.context.target
				if ( not target or action.sequence[self.currentactionsequence].settings.castonplayer) then
					target = Player
				end
				
				if ( not target ) then return end
				local castresult
				
				if (skilldata.isgroundtargeted) then
					local pos = target.pos
					local ppos = ml_global_information.Player_Position
					local targetdist = target.distance
					local targetradius = target.radius or 0
					local maxrange = action.sequence[self.currentactionsequence].settings.maxrange or skilldata.maxrange or 0
					if ( maxrange == 0 ) then maxrange = action.sequence[self.currentactionsequence].settings.radius or skilldata.radius or 0 end
					-- In case the target is "on the outside border of where we can throw/place the aoe spell and just the impact radius of the skill will still hit the target
					if ( not action.sequence[self.currentactionsequence].settings.castonplayer and targetdist >= maxrange ) then
						-- Calculate the position on the outside radius of the target towards our player
						local vec = { x = pos.x - ppos.x, y = pos.y - ppos.y, z = pos.z - ppos.z }
						local vec2 = math.normalize(vec)						
						pos.x = ppos.x + (vec2.x*maxrange)
						pos.y = ppos.y + (vec2.y*maxrange)
						pos.z = ppos.z + (vec2.z*maxrange )
												
					else
						-- Use target prediciton in case the target is moving
						d("TODO: Use target prediciton in case the target is moving ")
						
					end
					
					if (target.isgadget) then
						castresult = Player:CastSpell(GW2.SKILLBARSLOT["Slot_" .. skilldata.slot] , pos.x, pos.y, (pos.z - target.height)) -- need to cast at the top of the gadget, else no los errors on larger things
					else
						castresult = Player:CastSpell(GW2.SKILLBARSLOT["Slot_" .. skilldata.slot] , pos.x, pos.y, pos.z)
					end
				else
					
					if ( skilldata.flip_level > 0 ) then
						castresult = Player:CastSpellNoChecks(GW2.SKILLBARSLOT["Slot_" .. skilldata.slot] , target.id)
					else
						castresult = Player:CastSpell(GW2.SKILLBARSLOT["Slot_" .. skilldata.slot] , target.id)
					end
				end
			
				if ( castresult ) then
					if ( skilldata.flip_level > 0 ) then
						-- add a temp cooldown on the spell, else they will never be removed from the queue
						skilldata.cooldown = 750
						 if ( not self.context.cooldownlist ) then self.context.cooldownlist = {} end
						self.context.cooldownlist[skilldata.id] = { tick = self.lasttick, cd = 750 }					
					end
					--if ( self.context.lastcast ) then
						--d("LAST CAST : "..tostring(self.lasttick-self.context.lastcast))
					--end
					
					-- building a cast history
					if ( self.context ) then 
						if ( not self.context.casthistory ) then self.context.casthistory = {} end
						-- don't spam-add the skill1 
						if ( not skilldata.slot == 1 or not self.context.casthistory[1] or self.context.casthistory[1].skillid ~= skilldata.id ) then
							table.insert(self.context.casthistory,1, { name=skilldata.name, skillid=skilldata.id, casttime = self.lasttick, targetid = target.id, })
							if ( table.size(self.context.casthistory) > 5 ) then table.remove(self.context.casthistory,6) end
						end
					end
					self.context.lastcast = self.lasttick
					skilldata.lastcast=self.lasttick
					d("Casting: "..skilldata.name)					
					return true
				else
					d("Casting Failed: "..skilldata.name)
				end
							
			end
		else
			ml_error("[SkillManager] - Invalid Skilldata for casting, ID : "..tostring(action.sequence[self.currentactionsequence].id))
		end
	end	
end

function sm_skill_profile:Evade()
	if (Settings.GW2Minion.evade) then
		gw2_common_functions.Evade()
	end
end

function sm_skill_profile:DoCombatMovement()
	
	local fightdistance = ml_global_information.AttackRange
	if ( table.valid(self.context.target) and self.context.target.distance <= (fightdistance + 250) and not self.combatmovement.range and ml_global_information.Player_Alive and ml_global_information.Player_OnMesh and ml_global_information.Player_Health.percent < 99) then
		local isimmobilized	
		if ( table.size(ml_global_information.Player_Buffs) > 0 ) then
			for id,v in pairs (ml_global_information.Player_Buffs) do
				if ( ml_global_information.ImmobilizeConditions[id] ) then
					isimmobilized = true
					break
				end
			end
		end
		
		if (not isimmobilized) then		
			local forward,backward,left,right,forwardLeft,forwardRight,backwardLeft,backwardRight = GW2.MOVEMENTTYPE.Forward,GW2.MOVEMENTTYPE.Backward,GW2.MOVEMENTTYPE.Left,GW2.MOVEMENTTYPE.Right,4,5,6,7
			local currentMovement = ml_global_information.Player_MovementDirections
			local movementDirection = {[forward] = true, [backward] = true,[left] = true,[right] = true,}
			local tDistance = self.context.target.distance
			
			-- Stop walking into range.
			if (self.combatmovement.range and tDistance < fightdistance - 250) then Player:StopMovement() self.combatmovement.range = false end  -- "range" is "moving into combat range"
			-- Face target.
			local tpos = self.context.target.pos
			Player:SetFacingExact(tpos.x, tpos.y, tpos.z)
			-- Range, walking too close to enemy, stop walking forward.
			if (fightdistance > 300 and tDistance < (fightdistance / 2)) then movementDirection[forward] = false end
			-- Range, walking too far from enemy, stop walking backward.
			if (fightdistance > 300 and tDistance > fightdistance * 0.95) then movementDirection[backward] = false end
			-- Melee, walking too close to enemy, stop walking forward.
			if (tDistance < self.context.target.radius) then movementDirection[forward] = false end
			-- Melee, walking too far from enemy, stop walking backward.
			if (tDistance > fightdistance) then movementDirection[backward] = false end
			-- We are strafing too far from target, stop walking left or right.
			if (tDistance > fightdistance) then
				movementDirection[left] = false
				movementDirection[right] = false
			end
			-- Can we move in direction, while staying on the mesh.
			if (movementDirection[forward] and gw2_common_functions.CanMoveDirection(forward,400) == false) then movementDirection[forward] = false end
			if (movementDirection[backward] and gw2_common_functions.CanMoveDirection(backward,400) == false) then movementDirection[backward] = false end
			if (movementDirection[left] and gw2_common_functions.CanMoveDirection(left,400) == false) then movementDirection[left] = false end
			if (movementDirection[right] and gw2_common_functions.CanMoveDirection(right,400) == false) then movementDirection[right] = false end
			--
			if (movementDirection[forward]) then
				if (movementDirection[left] and gw2_common_functions.CanMoveDirection(forwardLeft,300) == false) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and gw2_common_functions.CanMoveDirection(forwardRight,300) == false) then
					movementDirection[right] = false
				end
			elseif (movementDirection[backward]) then
				if (movementDirection[left] and gw2_common_functions.CanMoveDirection(backwardLeft,300) == false) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and gw2_common_functions.CanMoveDirection(backwardRight,300) == false) then
					movementDirection[right] = false
				end
			end

			-- Can we move in direction, while not walking towards potential enemy's.
			local targets = CharacterList("alive,los,notaggro,attackable,hostile,maxdistance=1500,exclude="..self.context.target.id)

			if (movementDirection[forward] and table.size(gw2_common_functions.filterRelativePostion(targets,forward)) > 0) then movementDirection[forward] = false end
			if (movementDirection[backward] and table.size(gw2_common_functions.filterRelativePostion(targets,backward)) > 0) then movementDirection[backward] = false end
			if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,left)) > 0) then movementDirection[left] = false end
			if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,right)) > 0) then movementDirection[right] = false end
			--
			if (movementDirection[forward]) then
				if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,forwardLeft)) > 0) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,forwardRight)) > 0) then
					movementDirection[right] = false
				end
			elseif (movementDirection[backward]) then
				if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,backwardLeft)) > 0) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,backwardRight)) > 0) then
					movementDirection[right] = false
				end
			end

			-- We know where we can move, decide where to go.
			if (movementDirection[forward] and movementDirection[backward]) then -- Can move forward and backward, choose.
				
				-- Range, try to stay back from target.
				if (fightdistance > 300) then
					movementDirection[forward] = false
					if (tDistance >= fightdistance - 25) then
						movementDirection[backward] = false
					end
				end
				-- Melee, try to stay close to target.
				if (fightdistance <= 300) then
					movementDirection[backward] = false
					if (tDistance <= fightdistance - 25) then
						movementDirection[forward] = false
					end
				end
				
			end
			if (movementDirection[left] and movementDirection[right]) then -- Can move left and right, choose.
				if (currentMovement.left) then -- We are moving left already.
					if (math.random(0,250) ~= 3) then -- Keep moving left gets higher chance.
						movementDirection[right] = false
					else
						movementDirection[left] = false
					end
				elseif (currentMovement.right) then -- We are moving right already.
					if (math.random(0,250) ~= 3) then -- Keep moving right gets higher chance.
						movementDirection[left] = false
					else
						movementDirection[right] = false
					end
				end
			end

			-- Execute combat movement.
			for direction,canMove in pairs(movementDirection) do
				if (canMove) then
					Player:SetMovement(direction)
				end
			end
			self.combatmovement.combat = true
			return
		end
	
	elseif(self.combatmovement.combat) then -- Stop active combat movement.		 
		Player:StopMovement()
		self.combatmovement.combat = false
	end
end

-- Updates the Data of the current SkillSets
function sm_skill_profile:UpdateSkillData()
	self.currentskills = {}
	self.context.maxskillrange = 154
	self.context.activeskillrange = 154
			
	-- Use the current gamedata to update the skillset data
	for i = 1, ml_global_information.MAX_SKILLBAR_SLOTS-1 do	-- 1 to 19
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if (skill) then
			self.currentskills[i] = skill
			local skilldata, skillset = self:GetSkillAndSkillSet(skill.skillid)
			if (skilldata and skillset ) then
				self.currentskills[i].skilldata = skilldata
				self.currentskills[i].skillset = skillset
				skilldata.cooldown = skill.cooldown
				skilldata.cooldownmax = skill.cooldownmax
				if ( skilldata.isgroundtargeted == nil ) then skilldata.isgroundtargeted = skill.isgroundtargeted end
				if ( skilldata.slot >= 7 and skilldata.slot <=9 ) then
					skilldata.slot = i
				end
			end
		end
	end
	
	-- We now have the current skilldata, update our current "sets"
	self.sets = self:GetCurrentSkillSets()
		
	-- Go through our action list and check the maxrange from each instance of the skill					
	if ( table.valid(self.currentskills)) then	
		for i,skill in pairs(self.currentskills) do			
			for k,v in pairs(self.actionlist) do			
				for a,s in pairs(v.sequence) do				
					if ( s.id == skill.skillid) then					
						if ( not s.settings.castonplayer and s.settings.setsattackrange) then
							local range = 0
							if ( s.settings.maxrange and s.settings.maxrange > range ) then range = s.settings.maxrange end
							if ( s.settings.radius and s.settings.radius > range ) then range = s.settings.radius end
							if ( range > self.context.maxskillrange ) then 
								self.context.maxskillrange = range 
							end
																
							if ( range > self.context.activeskillrange and table.valid(self.context.target) and (not skill.skilldata.flip_level or skill.skilldata.flip_level <= 1) ) then 
								local ha = v:CanCastSkill(self, skill.skillset, a, skill.skilldata, true)
								--d(tostring(skilldata.name) .." - " ..tostring(ha).. " -- " ..tostring(range))										
								if ( ha ) then
									self.context.activeskillrange = range					
								end
							end
						end
					end
				end
			end
		end
	end
		
	-- Make that current skills available to our context
	if ( self.context ) then 
		self.context.currentskills = {}
		for k,v in pairs (self.currentskills) do				
			self.context.currentskills[k] = v
		end
		
		-- Clear old cast history
		if ( table.size(self.context.casthistory) > 0 ) then 
			for k,v in pairs (self.context.casthistory) do				
				if ( self.lasttick - v.casttime > 5000 ) then
					table.remove(self.context.casthistory,k) 
				end
			end				
		end
	end		
	
	if ( not self.context.cooldownlist ) then self.context.cooldownlist = {} end
	local cdlist = Player:GetCoolDownList()	
	if ( cdlist ) then
		for id,e in pairs(cdlist) do
			local skilldata = self:GetSkillAndSkillSet(id)
			if (skilldata ) then
				skilldata.cooldown = e.cooldown
				self.context.cooldownlist[id] = { tick = self.lasttick, cd = e.cooldown }
			end
		end
	end
	
	-- in case our skill arrived at 0 cooldown, it would disappear from the GetCoolDownList, this code makes sure our data is set back to 0 
	if ( table.valid(self.context.cooldownlist) ) then 
		for id, e in pairs (self.context.cooldownlist) do
			if ( self.lasttick - e.tick >= e.cd ) then
				local skilldata = self:GetSkillAndSkillSet(id)
				if (skilldata ) then
					skilldata.cooldown = 0
				end
				self.context.cooldownlist[id] = nil
			end		
		end
	end
	
	-- save the current weapon set UDs available, used a lot in cancast etc checks
	local w = Player:GetCurrentWeaponSet()		
	self.weaponsets = {}
		if (ml_global_information.Player_SwimState == 0) then-- we are on land
		local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 4} ) end
		item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 5} ) end
		item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 4} ) end
		item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 5} ) end
	
	elseif ( Player.swminning == 1) then -- we are diving
		local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 0} ) end
		item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon)
		if ( item ) then table.insert(self.weaponsets, { weapontype = item.weapontype, weaponsetid = 0} ) end
	end

end

-- function called from skillmgr.lua and from diverse BTree places. Just sets the current target
function sm_skill_profile:Use(targetid)	
	self.targetid = targetid
	self.targetlastupdated = ml_global_information.Now
end

-- Main loop, called by skill_mgr.lua
function sm_skill_profile:Update()	
	if ( not self.lasttick or ml_global_information.Now - self.lasttick > 250) then
		self.lasttick = ml_global_information.Now
				
		-- Check if we (still) have an active target and update that. Make sure it is not our player.
		if ( self.targetid and (self.targetlastupdated and self.lasttick - self.targetlastupdated < 2000) and Player.id ~= self.targetid) then			
			self.context.target = CharacterList:Get(self.targetid) or GadgetList:Get(self.targetid) --or AgentList:Get(self.targetid)			
		else
			self.context.target = nil
		end		
		if ( self.context.target and self.context.target.attackable and self.context.target.dead ) then
			self.context.target = nil
		end

		-- Update self.currentskills , sets, cooldowns, and the self.context.maxskillrange and self.context.activeskillrange
		self:UpdateSkillData()
		
		-- Set the correct attackrange depending on our situation
		if (not self.targetid and not ml_global_information.Player_InCombat ) then
			ml_global_information.AttackRange = self.context.maxskillrange			
		else
			if ( self.fightrangetype == 1 ) then -- Dynamic fight range
				ml_global_information.AttackRange = self.context.activeskillrange
			else -- fixed fight range
				ml_global_information.AttackRange = self.fixedfightrange or self.context.activeskillrange
			end
		end
			
		-- Go crazy
		if ( BehaviorManager:Running() and (ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive or ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Downed)) then
			
			-- Cast (but only every 1 second on the player if we have no target)
			if ( self.context.target or ( not self.lastcastonplayer or self.lasttick-self.lastcastonplayer> 1000)) then
				self.lastcastonplayer = self.lasttick
				self:Cast()
			end
			
			-- Evade
			local evaded
			if ( ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive and ml_global_information.Player_InCombat and ml_global_information.Player_CastInfo and (ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.None or ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.Slot_1 )) then
				evaded = self:Evade()
			end
			
			-- Combatmovement			
			if ( not evaded and ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive and Settings.GW2Minion.combatmovement ) then
				self:DoCombatMovement()
			end
		
		else
			
			self.currentaction = nil
			self.currentactionsequence = nil
			if ( self.combatmovement.combat ) then
				Player:StopMovement()
				self.combatmovement.combat = false
			end
		end		
	end
	
	-- Nil the data so it doesn't get accidently reused in a later pulse and cause crashes
	self.context.target = nil
end

-- To load the additional skill data
function sm_skill_profile.Init()
	sm_skill_profile.skilldata = FileLoad(GetStartupPath()  .. "\\LuaMods\\SkillManager\\gw2_skill_data.lua")
	if ( not table.valid(sm_skill_profile.skilldata) ) then
		ml_error("[SkillManager] - Failed to load Skill Data!")
	end
end
RegisterEventHandler("Module.Initalize",sm_skill_profile.Init)


-- Register this template in the SM Mgr
SkillManager:RegisterProfileTemplate( sm_skill_profile )