sm_mgr = {}
sm_mgr.open = false
sm_mgr.luamodspath = GetLuaModsPath()
sm_mgr.texturepath = GetStartupPath() .. "\\GUI\\UI_Textures"
sm_mgr.iconpath = sm_mgr.luamodspath .. "\\SkillManager\\iconcache"
sm_mgr.profiles = {}				-- SM profiles
sm_mgr.conditions = {}		-- SM condition "classes" which are used in the condition builder/editor for the "cast if ..." check per skill
sm_mgr.skillpalettes = {}		-- For each Profession, a different set of palettes are "hardcoded" and available in here. These include the functions to swap to the palette in order to cast the spell on it
sm_mgr.open = true

-- Extend this or overwrite this for other games::
sm_mgr.profilepath = GetLuaModsPath()  .. "GW2Minion\\\SkillManagerProfiles"
function sm_mgr.GetPlayerProfession() return Player.profession end

-- Register the SM UI Button:
function sm_mgr.ModuleInit()	
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##SKILLMANAGER", name = "SkillManager", onClick = function() sm_mgr.open = not sm_mgr.open end, tooltip = GetString("Click to open \"Skill Manager\" window."), texture = GetStartupPath().."\\GUI\\UI_Textures\\sword.png"},"GW2MINION##MENU_HEADER")	
	sm_mgr.RefreshSkillPalettes()
end
RegisterEventHandler("Module.Initalize",sm_mgr.ModuleInit)


-- On first load of all lua modules, if this is an internal module, the functions differ and allow access to the "QuestProfiles" or other EQUALLY NAMED FOLDERS IN ALL ADDONS!!
-- This way profiles can be put in private folders and be found by this manager
sm_mgr.ModuleFunctions = {}
if (GetModuleFiles ~= nil and ReadModuleFile ~= nil) then
	sm_mgr.ModuleFunctions.GetModuleFiles = GetModuleFiles
	sm_mgr.ModuleFunctions.ReadModuleFile = ReadModuleFile
end

 -- Sets the default folderpath by the game, which is used when creating "NEW" profiles in the manager
function sm_mgr:SetDefaultProfileFolder( folderpath )
	if ( FolderExists(folderpath) ) then
		self.profilepath = folderpath
	else
		ml_error("[SkillManager] - Invalid default Profile folder: "..tostring(folderpath))
	end
end

-- Get all SkillSets / Palettes from the local folder
function sm_mgr.RefreshSkillPalettes()
	sm_mgr.skillpalettes = {}
	if( sm_mgr.ModuleFunctions.GetModuleFiles and sm_mgr.ModuleFunctions.ReadModuleFile ) then
		local fileinfo = sm_mgr.ModuleFunctions.GetModuleFiles("sm_skillpalettes")				
		for _,k in pairs(fileinfo) do
			local fileString = sm_mgr.ModuleFunctions.ReadModuleFile(k) -- the loaded files are NOT having access to the private stack the rest here is inside
			if (fileString) then
				assert(loadstring(fileString))()
			end
		end
	else
		 local fileinfo = FolderList(sm_mgr.luamodspath .. [[\SkillManager\sm_skillpalettes\]],[[.*lua]])
        for _,profileName in pairs(fileinfo) do			
            local fileFunction, errorMessage  = loadfile(sm_mgr.luamodspath .. [[\SkillManager\sm_skillpalettes\]] .. profileName)
            if (fileFunction) then
				fileFunction()
            else
                d("Syntax error:")
                d(errorMessage)
            end
        end
    end
end


-- Gets all skill profiles from all "SkillManagerProfiles" folders
function sm_mgr.RefreshProfileFiles()
	sm_mgr.profiles = {}
	if( sm_mgr.ModuleFunctions.GetModuleFiles and sm_mgr.ModuleFunctions.ReadModuleFile ) then
		local fileinfo = sm_mgr.ModuleFunctions.GetModuleFiles("SkillManagerProfiles")				
		for _,k in pairs(fileinfo) do
			local fileString = sm_mgr.ModuleFunctions.ReadModuleFile(k)
			if (fileString) then
				local fileFunction, errorMessage = loadstring(fileString)
				if (fileFunction) then
					local profile = fileFunction()					
					if( profile ~= nil and type(profile) == "table" and profile.version and profile.version >= 1 and profile.profession and profile.profession == sm_mgr.GetPlayerProfession() ) then
						profile.temp = { 
							filename = k.f, 
							folderpath = sm_mgr.luamodspath.."\\"..k.m.."\\"..k.p.."\\"
							}
						table.insert(sm_mgr.profiles, profile)
						d("[SkillManager] - Found Profile : "..k.f)
					end
				end
			end
		end
		
	else
        local fileinfo = FolderList(sm_mgr.luamodspath .. [[\GW2Minion\SkillManagerProfiles\]],[[.*sm]])
        for _,profileName in pairs(fileinfo) do
            local fileFunction, errorMessage  = loadfile(sm_mgr.luamodspath .. [[\GW2Minion\SkillManagerProfiles\]] .. profileName)
            if (fileFunction) then
                local profile = fileFunction()                 
                if( profile ~= nil and type(profile) == "table" and profile.version and profile.version >= 1 and profile.profession and profile.profession == sm_mgr.GetPlayerProfession() ) then
                    profile.temp = {
                        filename = profileName,
                        folderpath = sm_mgr.luamodspath .. [[\GW2Minion\SkillManagerProfiles\]]
                        }
                    table.insert(sm_mgr.profiles, profile)
                    d("[SkillManager] - Found Profile : "..profileName)
                end
            else
                d("Syntax error:")
                d(errorMessage)
            end
        end
    end
end
RegisterEventHandler("Module.AllInitialized",sm_mgr.RefreshProfileFiles)

-- Gets all skill conditions from all "sm_conditions" folders
function sm_mgr.RefreshConditions()
	sm_mgr.conditions = {}
	if( sm_mgr.ModuleFunctions.GetModuleFiles and sm_mgr.ModuleFunctions.ReadModuleFile ) then
		local fileinfo = sm_mgr.ModuleFunctions.GetModuleFiles("sm_conditions")				
		for _,k in pairs(fileinfo) do
			local fileString = sm_mgr.ModuleFunctions.ReadModuleFile(k)
			if (fileString) then
				assert(loadstring(fileString))()
			end
		end
	else
		 local fileinfo = FolderList(sm_mgr.luamodspath .. [[\SkillManager\sm_conditions\]],[[.*lua]])
        for _,profileName in pairs(fileinfo) do
            local fileFunction, errorMessage  = loadfile(sm_mgr.luamodspath .. [[\SkillManager\sm_conditions\]] .. profileName)
            if (fileFunction) then
				fileFunction()
            else
                d("Syntax error:")
                d(errorMessage)
            end
        end
    end
end
RegisterEventHandler("Module.AllInitialized",sm_mgr.RefreshConditions)


-- Load the default/last used SM profile for our profession
function sm_mgr:LoadLastProfileForProfession(profession)	
	local profession = self.GetPlayerProfession()
	if ( not Settings.SkillManager.lastProfiles ) then Settings.SkillManager.lastProfiles = {} end
	if ( Settings.SkillManager.lastProfiles[profession] ~= nil) then
		for i, p in pairs(self.profiles) do			
			if ( p.temp.filename == Settings.SkillManager.lastProfiles[profession] ) then
				self.profile = sm_profile:new(p)
				self.lastprofession = profession
				d("[SkillManager] - Loaded last used Profile : "..self.profile.temp.filename)
				return
			end
		end
	end
	-- If we are here, no profile was loaded, try to load a default one
	d("[SkillManager] - TODO: ADD A DEFAULT PROFILE TO PROFESSION  : "..tostring(profession))
end

-- Draws the SkillManager window, profile management and calls Profile:Render() to populate stuff
function sm_mgr.DrawMenu(event,ticks)
	-- Ingame and rdy
	ml_global_information.GameState = GetGameState()
	local p = Player
	if(p) then
		ml_global_information.Player_CastInfo = p.castinfo
	end
	if ( not ml_global_information.GameState == GW2.GAMESTATE.GAMEPLAY or not ml_global_information.Player_CastInfo ) then 
		return
	end
	
	-- Check for valid player profession and or changes
	if ( not sm_mgr.lasttick or ticks - sm_mgr.lasttick > 2000 ) then
		sm_mgr.lasttick = ticks
		local profession = sm_mgr.GetPlayerProfession()
		if ( profession and ( not sm_mgr.lastprofession or sm_mgr.lastprofession ~= profession or not sm_mgr.profile)) then						
			sm_mgr:LoadLastProfileForProfession(profession)
		end
	end
		
	-- Update GameData & Context & Skills etc.
	if ( sm_mgr.profile ) then
		sm_mgr.profile:UpdateContext()
	end
		
	-- SkillManager Main Window
	if (sm_mgr.open) then
		GUI:SetNextWindowSize(280,150,GUI.SetCond_Once)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
		sm_mgr.visible, sm_mgr.open = GUI:Begin(GetString("Skill Manager").."##smmgr", sm_mgr.open,GUI.WindowFlags_NoSavedSettings)
		if (sm_mgr.visible) then
			GUI:BulletText(GetString("Current Profile:"))
			
			local smlist = { }
			local currentidx = 0
			for i,p in pairs(sm_mgr.profiles) do
				table.insert(smlist, p.temp.filename)
				if ( sm_mgr.profile and  p.temp.filename == sm_mgr.profile.temp.filename) then
					currentidx = i
				end
			end
			local maxx,maxy = GUI:GetContentRegionAvail()
			GUI:PushItemWidth(maxx>70 and maxx - 60 or maxx)
			local currentidx, changed = GUI:Combo("##smmanagercombo",currentidx, smlist)
			GUI:PopItemWidth()
			if ( changed ) then
				local profile = sm_mgr.profiles[currentidx]
				if ( profile ) then
					-- reload the file data, so former changes are included
					sm_mgr.RefreshProfileFiles()
					for i,p in pairs(sm_mgr.profiles) do
						if ( p.temp.filename == profile.temp.filename) then
							profile = p
							break
						end
					end
					sm_mgr.profile = sm_profile:new(profile)
					Settings.SkillManager.lastProfiles[sm_mgr.GetPlayerProfession()] = sm_mgr.profile.temp.filename
					Settings.SkillManager.lastProfiles = Settings.SkillManager.lastProfiles -- trigger save
					sm_mgr.lastprofession = sm_mgr.GetPlayerProfession()
					d("[SkillManager] - Switched to Profile: ".. sm_mgr.profile.temp.filename)
				end				
			end
			GUI:SameLine()
			if (GUI:ImageButton("##smrefresh",sm_mgr.texturepath.."\\change.png",14,14)) then
				sm_mgr.RefreshProfileFiles()
			end
			 if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Refresh Profile List")) end
			
			GUI:SameLine()
			if (GUI:ImageButton("##smnew",sm_mgr.texturepath.."\\addon.png",14,14)) then
				sm_mgr.newfilename  = ""
				sm_mgr.newfilepath  = sm_mgr.profilepath
				GUI:OpenPopup(GetString("NewSMProfile"))
			end
			if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Create New Profile")) end
			
			if ( sm_mgr.profile and sm_mgr.profile.temp.modified ) then
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.39,0.0,0.6)
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.39,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.39,0.0,0.9)
				local maxx,_ = GUI:GetContentRegionAvail()
				if ( GUI:Button(GetString("Save Changes"),maxx,20) ) then
					sm_mgr.profile:Save()
				end				
				GUI:PopStyleColor(3)
			end
					
	-- Popup Handler NEW window
			if (GUI:BeginPopupModal(GetString("NewSMProfile"))) then
				local valid = true
				GUI:SetWindowSize(600,230)
				GUI:Spacing()
				GUI:Dummy(100,5)
				GUI:Text(GetString("Create new SkillManager Profile")..":" )
				GUI:AlignFirstTextHeightToWidgets()
				
				GUI:Text(GetString("File Path")..":" )				
				GUI:PushItemWidth(GUI:GetContentRegionAvailWidth()-70)
				sm_mgr.newfilepath = GUI:InputText("##smfolder",sm_mgr.newfilepath,GUI.InputTextFlags_EnterReturnsTrue)
				GUI:PopItemWidth()
				if ( not string.valid(sm_mgr.newfilepath) or not FolderExists(sm_mgr.newfilepath) ) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("INVALID")) valid = false GUI:PopStyleColor() end
				GUI:Text(GetString("File Name")..":" ) 
				GUI:PushItemWidth(GUI:GetContentRegionAvailWidth()-70)
				sm_mgr.newfilename = GUI:InputText("##smfile",sm_mgr.newfilename,GUI.InputTextFlags_EnterReturnsTrue)
				GUI:PopItemWidth()
				if ( not string.valid(sm_mgr.newfilename) or string.empty(sm_mgr.newfilename)) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("INVALID")) valid = false GUI:PopStyleColor() end
				if ( valid ) then -- check for duplicates
					if ( FileExists(sm_mgr.newfilepath.."\\"..sm_mgr.newfilename..".sm") ) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("DUPLICATE")) valid = false GUI:PopStyleColor() end
				end
				GUI:Spacing()
				GUI:Separator()
				GUI:Dummy(100,40)
				local width = GUI:GetContentRegionAvailWidth()
				GUI:SameLine((width/3)-40)
				if ( GUI:Button(GetString("Cancel"),80,30) ) then	
					sm_mgr.newfilepath  = nil
					sm_mgr.newfilename  = nil
					GUI:CloseCurrentPopup()						
				end
				GUI:SameLine((width/3*2)-40)
				if ( valid and GUI:Button(GetString("Ok"),80,30) ) then					
					local validname =  string.gsub(sm_mgr.newfilename,"^%s%w()_. -+","")
					-- Create a new SM Profile
					local profile = sm_profile:new( { 	profession = sm_mgr.GetPlayerProfession(),
																		version = 1,
																		temp = {
																			filename = validname..".sm", 
																			folderpath = sm_mgr.newfilepath.."\\",
																		},
																	})
					profile:Save()
					Settings.SkillManager.lastProfiles[sm_mgr.GetPlayerProfession()] = validname..".sm"
					Settings.SkillManager.lastProfiles = Settings.SkillManager.lastProfiles -- trigger save					
					sm_mgr.RefreshProfileFiles()
					sm_mgr.newfilepath  = nil
					sm_mgr.newfilename  = nil
					sm_mgr.profile = nil	-- trigger reload
					GUI:CloseCurrentPopup()
				end
				GUI:EndPopup()
			end
			
			GUI:Separator()

			-- Render 
			if (not changed and sm_mgr.profile ) then
				sm_mgr.profile:Render()
			end
			
		end
		GUI:End()
	end
		
	-- Casting time
	if ( sm_mgr.profile ) then
		sm_mgr.profile:Cast()
	end
end
RegisterEventHandler("Gameloop.Draw", sm_mgr.DrawMenu)

function sm_mgr:AddSkillPalette( palette )
	if ( not sm_mgr.skillpalettes[palette.profession] ) then sm_mgr.skillpalettes[palette.profession] = {} end
	if ( not sm_mgr.skillpalettes[palette.profession][palette.uid] ) then 
		sm_mgr.skillpalettes[palette.profession][palette.uid] = palette
		--d("[SkillManager] - Skill Palette with uid "..palette.uid.." added.")
	else
		ml_error("[SkillManager] - Skill Palette with uid "..palette.uid.." already exists, we got a duplicate here ?")
	end
end

function sm_mgr:AddCondition( condition )
	if( condition.uid ) then 
		if ( not sm_mgr.conditions[condition.uid] ) then sm_mgr.conditions[condition.uid] = condition end		
	else
		ml_error("[SkillManager] - A Condition without unique identifier ( UID ) cannot be added!")
	end
end


-- Exposed API
_G["SkillManager"] = {}
function SkillManager:CreateSkillPalette(name)
	if (string.valid(name)) then
		return class(name,sm_skillpalette)
	end
end
function SkillManager:AddSkillPalette( palette ) 
	sm_mgr:AddSkillPalette( palette )
end
function SkillManager:AddCondition( condition ) 
	sm_mgr:AddCondition( condition )
end
function SkillManager:SetTarget(targetid, healtargetid)
	if ( sm_mgr.profile ) then
		sm_mgr.profile:SetTargets(targetid, healtargetid)
	end
end
function SkillManager:RenderCodeEditor() 
	if ( sm_mgr.profile ) then 
		sm_mgr.profile:RenderCodeEditor() 
	end 
end
function SkillManager:Cast() 
	if ( sm_mgr.profile ) then 
		sm_mgr.profile:Cast() 
	end 
end



-- some little helper window to update/see the skill data needed to build the hardcoded skill sets
sm_mgr.sethelper = {}
sm_mgr.sethelper.open = true
-- Draws the SkillManager window, profile management and calls Profile:Render() to populate stuff
function sm_mgr.sethelper.DrawMenu(event,ticks)
	
	if (sm_mgr.open) then
		GUI:SetNextWindowSize(300,500,GUI.SetCond_Once)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
		sm_mgr.sethelper.visible, sm_mgr.sethelper.open = GUI:Begin(GetString("Skill Set Helper").."##smhelper", sm_mgr.sethelper.open,GUI.WindowFlags_NoSavedSettings)
		if (sm_mgr.sethelper.visible) then
			local shitlist = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, }
			sm_mgr.sethelper.idx, changed = GUI:Combo("##smhelperskill", sm_mgr.sethelper.idx or 1, shitlist )
			if ( sm_mgr.sethelper.idx ) then
				local weapons = false
				if ( sm_mgr.sethelper.idx >= 0 and sm_mgr.sethelper.idx <= 5 ) then
					weapons = true
				end
				
				if ( not weapons ) then
					local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(sm_mgr.sethelper.idx)])
					if ( skill ) then
						sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(sm_mgr.sethelper.idx)..", \n\t activationtime = 0.0, \n\t icon = '"..skill.name.."',  \n },"
			
					end
				else
					 sm_mgr.sethelper.skillinfo = nil
					for i=0,5 do
						local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(i)])
						if ( skill ) then
							if ( not  sm_mgr.sethelper.skillinfo or sm_mgr.sethelper.skillinfo == "" ) then							
								sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.0, \n\t icon = '"..skill.name.."',  \n },"
							else
								sm_mgr.sethelper.skillinfo = sm_mgr.sethelper.skillinfo.."\n ["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.0, \n\t icon = '"..skill.name.."',  \n },"
								
							end
						end
					end				
				end
				GUI:Separator()
				--GUI:InputTextMultiline( "smhalpbox", sm_mgr.sethelper.skillinfo or "", 280, 200 , GUI.InputTextFlags_AutoSelectAll)
				GUI:InputTextEditor( "##smhalpbox", sm_mgr.sethelper.skillinfo or "", 280, 450 , GUI.InputTextFlags_AutoSelectAll)
		
			end
		end
		GUI:End()
	end
end
RegisterEventHandler("Gameloop.Draw", sm_mgr.sethelper.DrawMenu)