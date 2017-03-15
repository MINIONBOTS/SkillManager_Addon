-- This general Skill Manager provides a game-independent profile management for skill usage.

-- EXPOSED API:
-- SkillManager:SetProfileFolder( folderpath )		- Sets the default profile folder
-- SkillManager:RegisterProfile( profile )				- To register a SM profile in the manager
-- SkillManager.GetPlayerProfession( getter func )	- Set a function here that is being used to determine the current player profession, to filter available skill profiles


--IMPORTANT: Every addon and the main game need to register for the "RequestSMProfileUpdate" event, which forces the re-registering of all wanted SM Profiles.


local ml_skill_mgr = {}
ml_skill_mgr.open = true
ml_skill_mgr.profilelist = {}			-- Holds all registered SM profiles
ml_skill_mgr.profile = nil				-- The currently selected SM profile
ml_skill_mgr.texturepath = GetStartupPath() .. "\\GUI\\UI_Textures"
ml_skill_mgr.conditions = {}			-- Holds registered conditions classes which are used in the condition builder/editor for the "cast if ..." check per skill

-- Extend this or overwrite this for other games through SkillManager:GetPlayerProfession( getter func )	
function ml_skill_mgr.GetPlayerProfession()
	return Player.profession or Player.job -- gw2 & ffxiv ;) me lazy I know
end


-- In order to load the last used Skill Profile, all the main bot profiles and all addons need to be loaded & initialized first. Since MinionLib is loaded first, I'll use 2 queued events below to make sure that everything is initialized before loading our skill profile.
function ml_skill_mgr.RefreshProfileFiles()
	if ( not table.valid(Settings.minionlib.lastSMProfiles) ) then Settings.minionlib.lastSMProfiles = {} end
	ml_skill_mgr.profilelist = {}
	ml_skill_mgr.profile = nil
	QueueEvent("RequestSMProfileUpdate","arg")  --(Executed in the NEXT pulse!)
end
RegisterEventHandler("Module.Initalize",ml_skill_mgr.RefreshProfileFiles)

-- Every addon and the main game need to register for that "RequestSMProfileUpdate" event, which forces the re-registering of all wanted SM Profiles.
function ml_skill_mgr.RequestSMProfileUpdate()
	QueueEvent("LoadDefaultSMProfile","arg") -- This is executed in the next pulse, where all SM profiles area already (again) registered in this manager.
end
RegisterEventHandler("RequestSMProfileUpdate", ml_skill_mgr.RequestSMProfileUpdate)

-- Setting our last used profile after a restart or reloading of profiles
function ml_skill_mgr.LoadDefaultSMProfile()
	local profession = ml_skill_mgr.GetPlayerProfession()
	if ( profession ~= nil ) then
		if ( table.valid(Settings.minionlib.lastSMProfiles) and Settings.minionlib.lastSMProfiles[profession] ) then
			for k,v in pairs(ml_skill_mgr.profilelist) do
				if ( v.filename == Settings.minionlib.lastSMProfiles[profession] ) then
					ml_skill_mgr.profile = v:Load()
					if ( ml_skill_mgr.profile ) then
						local name = ml_skill_mgr.profile.name or ml_skill_mgr.profile.filename
						d("[SkillManager] - Loaded last used Profile : "..name)
						return true
					end
				end
			end
		end
	end
	return false
end
RegisterEventHandler("LoadDefaultSMProfile", ml_skill_mgr.LoadDefaultSMProfile)

-- Called from the game / addon code to add a skill profile to the manager
function ml_skill_mgr:RegisterProfile( filepath, filename, privatemodulefunctions, customcontext )
	local profile = ml_skill_mgr.ProfileTemplate:new(filepath, filename, privatemodulefunctions, customcontext )
	table.insert(ml_skill_mgr.profilelist,profile)
	d("[SkillManager] - Registered Profile: "..filename)
end

-- Sets the default folderpath which is used when creating "NEW" profiles in the manager
function ml_skill_mgr:SetProfileFolder( folderpath )
	if ( FolderExists(folderpath) ) then
		self.profilepath = folderpath
	else
		ml_error("[SkillManager] - Invalid default Profile folder: "..tostring(folderpath))
	end
end

-- Draws the SkillManager window, profile management and calls Profile:Render() to populate stuff
function ml_skill_mgr.Draw(event,ticks)
	-- Check for valid player profession and or changes
	if ( not ml_skill_mgr.lasttick or ticks - ml_skill_mgr.lasttick > 2000 ) then
		ml_skill_mgr.lasttick = ticks
		local profession = ml_skill_mgr.GetPlayerProfession()
		if ( profession and ( not ml_skill_mgr.lastprofession or ml_skill_mgr.lastprofession ~= profession or not ml_skill_mgr.profile)) then			
			-- Load the default SM profile for our profession
			if ( ml_skill_mgr.LoadDefaultSMProfile()	) then
				ml_skill_mgr.lastprofession = profession
			else
				d("[SkillManager] - No default Profile found or set.")
			end
		end
	end
	
	-- SkillManager Main Window
	if (ml_skill_mgr.open) then
		GUI:SetNextWindowSize(310,150,GUI.SetCond_Once)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
		ml_skill_mgr.visible, ml_skill_mgr.open = GUI:Begin(GetString("Skill Manager").."##smmgr", ml_skill_mgr.open,GUI.WindowFlags_NoSavedSettings)
		if (ml_skill_mgr.visible) then
			
			GUI:BulletText(GetString("Current Profile:"))
			
			local itemchanged,currentidx
			GUI:PushItemWidth(210)
			currentidx = 0
			-- Find the current profile & build the list for the combobox			
			local smlist = {}
			for k,v in pairs (ml_skill_mgr.profilelist) do				
				table.insert(smlist, string.valid(v.name) and v.name or v.filename)
				if ( ml_skill_mgr.profile ~= nil ) then
					if (ml_skill_mgr.profile.filename == v.filename) then
						currentidx = k						
					end
				end
			end	
			currentidx, itemchanged = GUI:Combo("##smmanagercombo",currentidx, smlist)
			GUI:PopItemWidth()
			if ( itemchanged ) then
				local profile = ml_skill_mgr.profilelist[currentidx]
				if ( profile ) then
					ml_skill_mgr.profile = profile:Load()
					if ( ml_skill_mgr.profile ) then
						local profession = ml_skill_mgr.GetPlayerProfession()
						if ( profession ~= nil ) then
							Settings.minionlib.lastSMProfiles[profession] = ml_skill_mgr.profile.filename
							Settings.minionlib.lastSMProfiles = Settings.minionlib.lastSMProfiles -- trigger save
							ml_skill_mgr.lastprofession = profession	-- dont make it load twice
						end
					end
				end				
			end
			GUI:SameLine()
			if (GUI:ImageButton("##smrefresh",ml_skill_mgr.texturepath.."\\change.png",14,14)) then
				ml_skill_mgr.RefreshProfileFiles()
			end
			GUI:SameLine()
			if ( GUI:Button(GetString("New"), 45,20) ) then
				ml_skill_mgr.newfilename  = ""
				ml_skill_mgr.newfilepath  = ml_skill_mgr.profilepath or ""
				GUI:OpenPopup(GetString("NewSMProfile"))
			end
				
			if ( ml_skill_mgr.profile and ml_skill_mgr.profile.profession and ml_skill_mgr.profile.profession ~= ml_skill_mgr.GetPlayerProfession() ) then
				GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5)
				GUI:SmallButton(GetString("PROFILE IS NOT FOR YOUR CURRENT PROFESSION"))
				GUI:PopStyleColor()		
			end
			
			if ( ml_skill_mgr.profile and ml_skill_mgr.profile.modified ) then
				GUI:PushStyleColor(GUI.Col_Button,1.0,0.39,0.0,0.6)
				GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.39,0.0,0.8)
				GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.39,0.0,0.9)
				local maxx,_ = GUI:GetContentRegionAvail()
				if ( GUI:Button(GetString("Save Changes"),maxx,20) ) then
					ml_skill_mgr.profile:Save()
				end				
				GUI:PopStyleColor(3)
			end
					
	-- Popup Handler NEW window
			if (GUI:BeginPopupModal(GetString("NewSMProfile"))) then
				local valid = true
				GUI:SetWindowSize(500,230)
				GUI:Spacing()
				GUI:Dummy(100,5)
				GUI:Text(GetString("Create new SkillManager Profile")..":" )
				GUI:AlignFirstTextHeightToWidgets()
				
				GUI:Text(GetString("File Path")..":" )				
				GUI:PushItemWidth(GUI:GetContentRegionAvailWidth()-70)
				ml_skill_mgr.newfilepath = GUI:InputText("##smfolder",ml_skill_mgr.newfilepath,GUI.InputTextFlags_EnterReturnsTrue)
				GUI:PopItemWidth()
				if ( not string.valid(ml_skill_mgr.newfilepath) or not FolderExists(ml_skill_mgr.newfilepath) ) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("INVALID")) valid = false GUI:PopStyleColor() end
				GUI:Text(GetString("File Name")..":" ) 
				GUI:PushItemWidth(GUI:GetContentRegionAvailWidth()-70)
				ml_skill_mgr.newfilename = GUI:InputText("##smfile",ml_skill_mgr.newfilename,GUI.InputTextFlags_EnterReturnsTrue)
				GUI:PopItemWidth()
				if ( not string.valid(ml_skill_mgr.newfilename) or string.empty(ml_skill_mgr.newfilename)) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("INVALID")) valid = false GUI:PopStyleColor() end
				if ( valid ) then -- check for duplicates
					if ( FileExists(ml_skill_mgr.newfilepath.."\\"..ml_skill_mgr.newfilename..".sm") ) then GUI:PushStyleColor(GUI.Col_Button,255,0,0,0.5) GUI:SameLine() GUI:SmallButton(GetString("DUPLICATE")) valid = false GUI:PopStyleColor() end
				end
				GUI:Spacing()
				GUI:Separator()
				GUI:Dummy(100,40)
				local width = GUI:GetContentRegionAvailWidth()
				GUI:SameLine((width/3)-40)
				if ( GUI:Button(GetString("Cancel"),80,30) ) then	
					ml_skill_mgr.newfilepath  = nil
					ml_skill_mgr.newfilename  = nil
					GUI:CloseCurrentPopup()						
				end
				GUI:SameLine((width/3*2)-40)
				if ( valid and GUI:Button(GetString("Ok"),80,30) ) then					
					local validname =  string.gsub(ml_skill_mgr.newfilename,"[^%s%w()_. -]+","")
					-- Create a new SM Profile
					local profile = ml_skill_mgr.ProfileTemplate:new(ml_skill_mgr.newfilepath, validname)
					profile:Save()
					local profession = ml_skill_mgr.GetPlayerProfession()
					if ( profession ~= nil ) then
						Settings.minionlib.lastSMProfiles[profession] = validname
					end
					ml_skill_mgr.RefreshProfileFiles()	-- this auto loads the new saved profile				
					ml_skill_mgr.newfilepath  = nil
					ml_skill_mgr.newfilename  = nil
					GUI:CloseCurrentPopup()
				end
				GUI:EndPopup()
			end
			
			GUI:Separator()

			
			
			-- Render PROFILE
			if ( ml_skill_mgr.profile ) then
				ml_skill_mgr.profile:Render()
			end
			
		end
		GUI:End()
	end
		
end
RegisterEventHandler("Gameloop.Draw", ml_skill_mgr.Draw)

function ml_skill_mgr:Use( targetid )
	if ( ml_skill_mgr.profile) then
		return ml_skill_mgr.profile:Use(targetid)
	else
		ml_error("[SkillManager] - No SkillManager Profile loaded.")
	end
	return false
end

-- Main Loop for the SM to update n do stuff
function ml_skill_mgr.OnUpdate()
	if ( ml_skill_mgr.profile ~= nil ) then
		ml_skill_mgr.profile:Update()
	end
end
RegisterEventHandler("Gameloop.Update", ml_skill_mgr.OnUpdate)

_G["SkillManager"] = {}
function SkillManager:RegisterProfileTemplate( template ) ml_skill_mgr.ProfileTemplate = template end -- just for internal usage, to get an instance / link to the local sm_skill_profile.lua
function SkillManager:SetProfileFolder( folderpath ) ml_skill_mgr:SetProfileFolder( folderpath ) end
function SkillManager:RegisterProfile( folderpath, filename, modfunc, context) return ml_skill_mgr:RegisterProfile( folderpath, filename, modfunc, context ) end
function SkillManager:GetPlayerProfession()	return ml_skill_mgr.GetPlayerProfession() end
function SkillManager:RenderCodeEditor() if ( ml_skill_mgr.profile ) then ml_skill_mgr.profile:RenderCodeEditor() end end	-- renders the UI code of the SM profile
function SkillManager:AddCondition(class) ml_skill_mgr.conditions[tostring(class)] = class end
function SkillManager:GetCondition(classname) if (ml_skill_mgr.conditions[classname]) then return ml_skill_mgr.conditions[classname] end end
function SkillManager:GetConditions() return ml_skill_mgr.conditions end
function SkillManager:Use(targetid) return ml_skill_mgr:Use( targetid ) end
function SkillManager:Ready() return ml_skill_mgr.profile ~= nil end

-- On / Off / Cast / Update
ml_skill_mgr.original_use = gw2_skill_manager.Use
function gw2_skill_manager:Use(targetid)
	if ( SkillManager:Ready() ) then
		if ( BehaviorManager:Running() ) then
			return SkillManager:Use( targetid )
		end
	end
	return ml_skill_mgr.original_use()
end

-- Get the range of the current active skills. Give back a larger value in case of Assist or if it should stay at a far away position instead of walking into closer range when the "long range skill" is on cooldown!
ml_skill_mgr.original_getactiveskillrange = gw2_skill_manager.GetActiveSkillRange
function gw2_skill_manager.GetActiveSkillRange()
	if ( SkillManager:Ready() ) then		
		return ml_global_information.AttackRange or 154
	end
	return ml_skill_mgr.original_getactiveskillrange()
end

ml_skill_mgr.original_canmove = gw2_skill_manager.CanMove
function gw2_skill_manager.CanMove()
	if ( SkillManager:Ready() ) then
		return not ml_skill_mgr.profile.combatmovement.combat
	end
	return ml_skill_mgr.original_canmove()
end

ml_skill_mgr.original_combatmovement = gw2_skill_manager.CombatMovement
function gw2_skill_manager.CombatMovement()	
	if ( SkillManager:Ready() ) then		
		return ml_skill_mgr.profile.combatmovement
	end
	return ml_skill_mgr.original_combatmovement()
end