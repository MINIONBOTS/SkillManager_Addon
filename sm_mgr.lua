local table = _G["table"]
local string = _G["string"]
sm_mgr = {}
sm_mgr.open = false
sm_mgr.luamodspath = GetLuaModsPath()
sm_mgr.texturepath = GetStartupPath() .. "\\GUI\\UI_Textures"
sm_mgr.iconpath = sm_mgr.luamodspath .. "SkillManager\\iconcache"
sm_mgr.profiles = {}				-- SM profiles
sm_mgr.conditions = {}		-- SM condition "classes" which are used in the condition builder/editor for the "cast if ..." check per skill
sm_mgr.skillpalettes = {}		-- For each Profession, a different set of palettes are "hardcoded" and available in here. These include the functions to swap to the palette in order to cast the spell on it
sm_mgr.filesizefunc = _G["FileSize"]

-- Extend this or overwrite this for other games::
sm_mgr.profilepath = GetLuaModsPath()  .. "GW2Minion\\\SkillManagerProfiles"
function sm_mgr.GetPlayerProfession() return Player.profession end

-- Register the SM UI Button:
function sm_mgr.ModuleInit()	
	_G["ml_gui"].ui_mgr:AddMember({ id = "GW2MINION##SKILLMANAGER", name = "SkillManager", onClick = function() sm_mgr.open = not sm_mgr.open end, tooltip = GetString("Open the \"Skill Manager\" window."), texture = GetStartupPath().."\\GUI\\UI_Textures\\sword.png"},"GW2MINION##MENU_HEADER")	
	sm_mgr.CheckImageFiles()
	sm_mgr.RefreshSkillPalettes()
end
RegisterEventHandler("Module.Initalize",sm_mgr.ModuleInit,"sm_mgr.ModuleInit")


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

function sm_mgr.CheckImageFiles()
	-- image files can be corrupted sometimes due to whatever reason 	
	if ( FolderExists(sm_mgr.iconpath)) then
		local files = FolderList(sm_mgr.iconpath)
		if ( files and type(files) == "table" and #files > 0 ) then
			for i,k in pairs ( files ) do
				if ( string.sub(k,-string.len("_tmp"))=="_tmp" or sm_mgr.filesizefunc(sm_mgr.iconpath.."\\"..k) < 100 ) then
					d("[SkillManager] - Deleting invalid or corrupted image " ..sm_mgr.iconpath.."\\"..k)
					FileDelete(sm_mgr.iconpath.."\\"..k)
				end
			end
		end
	end
end


-- Get all SkillSets / Palettes from the local folder
function sm_mgr.RefreshSkillPalettes()
	sm_mgr.skillpalettes = {}
	if( sm_mgr.ModuleFunctions.GetModuleFiles and sm_mgr.ModuleFunctions.ReadModuleFile ) then
		local fileinfo = sm_mgr.ModuleFunctions.GetModuleFiles("skillpalettes")				
		for _,k in pairs(fileinfo) do
			local fileString = sm_mgr.ModuleFunctions.ReadModuleFile(k) -- the loaded files are NOT having access to the private stack the rest here is inside
			if (fileString) then
				assert(loadstring(fileString))()
			end
		end
	else
		 local fileinfo = FolderList(sm_mgr.luamodspath .. [[\SkillManager\skillpalettes\]],[[.*txt]])
        for _,profileName in pairs(fileinfo) do			
            local fileFunction, errorMessage  = loadfile(sm_mgr.luamodspath .. [[\SkillManager\skillpalettes\]] .. profileName)
            if (fileFunction) then
				fileFunction()
            else
                d("Syntax error:")
                d(errorMessage)
            end
        end
    end
	
	-- Make a list of all spells, this is used by the conditions for example, so we get a "id - name" list
	SkillManager.skilllist = {}
	for profid,data in pairs(sm_mgr.skillpalettes) do
		if ( profid ) then
			for suid, sp in pairs(data) do				
				for i,k in pairs( sp ) do
					if ( k.skills_luacode ) then
						for id,s in pairs (k.skills_luacode) do
							if ( not SkillManager.skilllist[id] ) then
								SkillManager.skilllist[id] = { id = id, name = s.icon }
							end
						end
					end				
				end
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
RegisterEventHandler("Module.AllInitialized",sm_mgr.RefreshProfileFiles,"sm_mgr.RefreshProfileFiles")

-- Gets all skill conditions from all "sm_conditions" folders
function sm_mgr.RefreshConditions()
	sm_mgr.conditions = {}
	if( sm_mgr.ModuleFunctions.GetModuleFiles and sm_mgr.ModuleFunctions.ReadModuleFile ) then
		local fileinfo = sm_mgr.ModuleFunctions.GetModuleFiles("conditions")				
		for _,k in pairs(fileinfo) do
			local fileString = sm_mgr.ModuleFunctions.ReadModuleFile(k)
			if (fileString) then
				assert(loadstring(fileString))()
			end
		end
	else
		 local fileinfo = FolderList(sm_mgr.luamodspath .. [[\SkillManager\conditions\]],[[.*txt]])
        for _,profileName in pairs(fileinfo) do
            local fileFunction, errorMessage  = loadfile(sm_mgr.luamodspath .. [[\SkillManager\conditions\]] .. profileName)
            if (fileFunction) then
				fileFunction()
            else
                d("Syntax error:")
                d(errorMessage)
            end
        end
    end
end
RegisterEventHandler("Module.AllInitialized",sm_mgr.RefreshConditions, "sm_mgr.RefreshConditions")


-- Load the default/last used SM profile for our profession
function sm_mgr:LoadLastProfileForProfession(profession)	
	local default = {
			[GW2.CHARCLASS.Guardian] = "Guardian.sm",
			[GW2.CHARCLASS.Warrior] = "Warrior.sm",
			[GW2.CHARCLASS.Engineer] = "Engineer.sm",
			[GW2.CHARCLASS.Ranger] = "Ranger.sm",
			[GW2.CHARCLASS.Thief] = "Thief.sm",
			[GW2.CHARCLASS.Elementalist] = "Elementalist.sm",
			[GW2.CHARCLASS.Mesmer] = "Mesmer.sm",
			[GW2.CHARCLASS.Necromancer] = "Necromancer.sm",
			[GW2.CHARCLASS.Revenant] = "Revenant.sm",
	}
	
	local profession = self.GetPlayerProfession()
	if ( not Settings.SkillManager.lastProfiles ) then Settings.SkillManager.lastProfiles = default end
	
	for i, p in pairs(self.profiles) do
		if ( p.temp.filename == Settings.SkillManager.lastProfiles[profession] ) then
			self.profile = sm_profile:new(p)
			self.lastprofession = profession
			d("[SkillManager] - Loaded last used Profile : "..self.profile.temp.filename)
			return
		end	
	end
	-- If we are here, no profile was loaded, try to load a default one
	Settings.SkillManager.lastProfiles[profession] = default[profession]
end

-- Draws the SkillManager window, profile management and calls Profile:Render() to populate stuff
function sm_mgr.DrawMenu(event,ticks)
	-- Ingame and rdy
	ml_global_information.GameState = GetGameState()
	if ( not ml_global_information.GameState == GW2.GAMESTATE.GAMEPLAY ) then
		return
	end
	if(Player) then
		ml_global_information.Player_CastInfo = Player.castinfo
	end
	 if( not ml_global_information.Player_CastInfo ) then 
		return
	end
	
	local updateandcast
	if ( not sm_mgr.lasttick or ticks - sm_mgr.lasttick > 50 ) then
		sm_mgr.lasttick = ticks
		updateandcast = true
	end
	
	if ( updateandcast ) then
		-- Check for valid player profession and or changes
		local profession = sm_mgr.GetPlayerProfession()
		if ( profession and ( not sm_mgr.lastprofession or sm_mgr.lastprofession ~= profession or not sm_mgr.profile)) then
			if (sm_mgr.lastprofession ~= profession) then 
				sm_mgr.RefreshProfileFiles()
			end
			sm_mgr:LoadLastProfileForProfession(profession)
		end
			
		-- Update GameData & Context & Skills etc.
		if ( sm_mgr.profile ) then
			sm_mgr.profile:UpdateContext()
		end
	end
	
	-- SkillManager Main Window
	if (sm_mgr.open) then
		GUI:SetNextWindowSize(280,150,GUI.SetCond_Once)
		--GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
		sm_mgr.visible, sm_mgr.open = GUI:Begin(GetString("Skill Manager").."##smmgr", sm_mgr.open,GUI.WindowFlags_NoResize)
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
				GUI:OpenPopup(GetString("New SkillManager Profile"))
			end
			if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("Create New Profile")) end
			
			if ( sm_mgr.profile) then
				if(sm_mgr.profile.temp.modified) then
					GUI:PushStyleColor(GUI.Col_Button,1.0,0.39,0.0,0.6)
					GUI:PushStyleColor(GUI.Col_ButtonHovered,1.0,0.39,0.0,0.8)
					GUI:PushStyleColor(GUI.Col_ButtonActive,1.0,0.39,0.0,0.9)
				else
					GUI:PushStyleColor(GUI.Col_Button,0.19,0.19,0.19,0.6)
					GUI:PushStyleColor(GUI.Col_ButtonHovered,0.19,0.19,0.19,0.6)
					GUI:PushStyleColor(GUI.Col_ButtonActive,0.19,0.19,0.19,0.6)					
				end
				local maxx,_ = GUI:GetContentRegionAvail()
				local btnstr = sm_mgr.profile.temp.modified and GetString("Save Changes") or GetString("No Changes")
				if ( GUI:Button(btnstr,maxx,20) ) then
					if(sm_mgr.profile.temp.modified) then
						sm_mgr.profile:Save()
					end
				end				
				GUI:PopStyleColor(3)
			end
					
	-- Popup Handler NEW window
			if (GUI:BeginPopupModal(GetString("New SkillManager Profile"))) then
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
				sm_mgr.profile.temp.open = true
				sm_mgr.profile:Render()
			end
			
		end
		GUI:End()
	end
		
	-- Casting time
	if ( updateandcast and sm_mgr.profile ) then
		sm_mgr.profile.temp.open = false	-- this is needed to set the target(s) in order to be able to check the skill cancast in the UI without the bot running
		sm_mgr.profile:Cast()
	end
end
RegisterEventHandler("Gameloop.Draw", sm_mgr.DrawMenu,"sm_mgr.DrawMenu")

function sm_mgr:AddSkillPalette( palette )
	if ( not sm_mgr.skillpalettes[0] ) then 
		sm_mgr.skillpalettes = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}}
	end	
	if ( not sm_mgr.skillpalettes[palette.profession][palette.uid] ) then
		if (palette.profession == 0) then -- common set, add it to all professions
			for i=1,9 do
				sm_mgr.skillpalettes[i][palette.uid] = palette
			end
		else		
			sm_mgr.skillpalettes[palette.profession][palette.uid] = palette
			--d("[SkillManager] - Skill Palette with uid "..palette.uid.." added.")
		end
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
SkillManager.skilllist = {} -- holds id - name pair of all skills in our palettes
-- if the BTree is calling Player:Interact or Player:Gather, this one is called right after, using it to delay casting spells
function SkillManager.PlayerIsInteracting()
	if(sm_mgr.profile and sm_mgr.profile.temp.lasttick) then
		-- sm_mgr.profile.temp.lasttick = ml_global_information.Now + 500
		-- sm_mgr.profile.temp.interactionstart = sm_mgr.profile.temp.lasttick 
		sm_mgr.profile.temp.interactionstart = ml_global_information.Now + 500
	end
end
RegisterEventHandler("Gameloop.Interact",SkillManager.PlayerIsInteracting,"SkillManager.PlayerIsInteracting")

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
	if ( sm_mgr.profile and GetGameState() == GW2.GAMESTATE.GAMEPLAY ) then
		sm_mgr.profile:RenderCodeEditor()
	end 
end
function SkillManager:Cast()
	-- not letting anything outside out "logic" call cast, else shit happens when it is not updated
end
function SkillManager:Use(targetid) --- old fucntion, backwardcompa
	if ( sm_mgr.profile ) then
		sm_mgr.profile:SetTargets(targetid, nil)
	end
end
function SkillManager:SelectProfile(name)
	local profile
	for i,p in pairs(sm_mgr.profiles) do
		if ( p.temp.filename == name) then
			profile = p
			break
		end
	end
	if ( profile ) then
		sm_mgr.profile = sm_profile:new(profile)
		Settings.SkillManager.lastProfiles[sm_mgr.GetPlayerProfession()] = sm_mgr.profile.temp.filename
		Settings.SkillManager.lastProfiles = Settings.SkillManager.lastProfiles -- trigger save
		sm_mgr.lastprofession = sm_mgr.GetPlayerProfession()
		d("[SkillManager] - Switched to Profile: ".. sm_mgr.profile.temp.filename)
	else
		d("[SkillManager] - Could not find Profile: ".. name)
	end	
end

function SkillManager:SkillStopsMovement()
	if(sm_mgr.profile and type(sm_mgr.profile) == "table") then
		return sm_mgr.profile:SkillStopsMovement()
	end
	return false
end

function SkillManager:PredictedPositionAndDistance(target)
	return sm_movementprediction:GetPosDistance(target)
end

-- auto generating default profiles, leaving it here for future changes I guess
function sm_mgr:GenetateDefaultProfile()
	--Gettting all skill infos and sorting the shit a bit + adding a "distance" condition to each
	local heals = {}
	local weapons = {}
	local wpspam = {}
	local utility = {}
	for i,sp in pairs (sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()]) do
		for j,s in pairs (sp.skills_luacode) do
			local sinfo = Player:GetSpellInfoByID(j)
			if (sinfo) then
				local entry = {}
				entry.id = j
				entry.slot = s.slot
				entry.activationtime = s.activationtime
				entry.icon = s.icon
				entry.parent = s.parent
				entry.instantcast = s.instantcast
				entry.nounderwater = s.nounderwater
				entry.range = sinfo.maxrange
				if ( sinfo.radius and sinfo.radius > entry.range )  then 
					entry.range = sinfo.radius
				end
				entry.skillpaletteuid = i
				
				if ( s.slot == GW2.SKILLBARSLOT.Slot_6 ) then
					table.insert(heals,entry)
				elseif( s.slot == GW2.SKILLBARSLOT.Slot_1 ) then
					table.insert(wpspam,entry)
				elseif( s.slot > GW2.SKILLBARSLOT.Slot_1 and s.slot <= GW2.SKILLBARSLOT.Slot_5) then
					table.insert(weapons,entry)	
				else
					table.insert(utility,entry)
				end
			end
		end
	end
	
	self.profile.actionlist = {}
	
	for i,k in pairs(heals) do
		local n = sm_skill:new()
		n.id = k.id
		n.skillpaletteuid = k.skillpaletteuid
		n.setsattackrange = false
		local condi = { healthtype = 3, operator = 1, target = 2, uid = "Health", value = 75, }
		n.conditions[1] = { [1] = sm_mgr.conditions["Health"]:new(condi) }
		n.conditions[1].casttarget = 2
		table.insert(self.profile.actionlist,n)
	end
	
	for i,k in pairs(weapons) do
		local n = sm_skill:new()
		n.id = k.id
		n.skillpaletteuid = k.skillpaletteuid
		n.setsattackrange = true		
		local condi = { operator = 1, target = 1, uid = "Distance", value = k.range }
		local ct = 1
		if ( not k.range or k.range == 0 ) then
			condi = { operator = 1, target = 1, uid = "CombatState" }
			ct = 2
		end
		n.conditions[1] = { [1] = sm_mgr.conditions[condi.uid]:new(condi) }
		n.conditions[1].casttarget = ct
		table.insert(self.profile.actionlist,n)
	end
	
	for i,k in pairs(utility) do
		local n = sm_skill:new()
		n.id = k.id
		n.skillpaletteuid = k.skillpaletteuid
		n.setsattackrange = false		
		local condi = { operator = 1, target = 1, uid = "CombatState" }		
		n.conditions[1] = { [1] = sm_mgr.conditions[condi.uid]:new(condi) }
		n.conditions[1].casttarget = 2
		table.insert(self.profile.actionlist,n)
	end
	
	for i,k in pairs(wpspam) do
		local n = sm_skill:new()
		n.id = k.id
		n.skillpaletteuid = k.skillpaletteuid
		n.setsattackrange = true		
		local condi = { operator = 1, target = 1, uid = "Distance", value = k.range }
		local ct = 1
		if ( not k.range or k.range == 0 ) then
			condi = { operator = 1, target = 1, uid = "CombatState" }
			ct = 2
		end
		n.conditions[1] = { [1] = sm_mgr.conditions[condi.uid]:new(condi) }
		n.conditions[1].casttarget = ct		
		table.insert(self.profile.actionlist,n)
	end
	
	--self.profile.temp.filename = "default.sm"
	self.profile:Save()
	self.RefreshProfileFiles()
	sm_mgr:LoadLastProfileForProfession(sm_mgr.GetPlayerProfession())
	
end
function SkillManager:GenetateDefaultProfile()
	if ( sm_mgr.profile ) then
		sm_mgr:GenetateDefaultProfile() 
	end 
end
function SkillManager:ToggleHelper()
	sm_mgr.sethelper.open = not sm_mgr.sethelper.open
end

function SkillManager:API_ProfileList()
    local smlist = {}
    for i,p in pairs(sm_mgr.profiles) do
        table.insert(smlist, p.temp.filename)
    end
    return smlist
end


-- some little helper window to update/see the skill data needed to build the hardcoded skill sets
sm_mgr.sethelper = {}
sm_mgr.sethelper.open = false
-- Draws the SkillManager window, profile management and calls Profile:Render() to populate stuff
function sm_mgr.sethelper.DrawMenu(event,ticks)

	if (sm_mgr.sethelper.open) then
		GUI:SetNextWindowSize(300,500,GUI.SetCond_Once)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Once)
		sm_mgr.sethelper.visible, sm_mgr.sethelper.open = GUI:Begin(GetString("Skill Set Helper").."##smhelper", sm_mgr.sethelper.open,GUI.WindowFlags_NoSavedSettings)
		if (sm_mgr.sethelper.visible) then
			local shitlist = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, }
			sm_mgr.sethelper.idx, changed = GUI:Combo("##smhelperskill", sm_mgr.sethelper.idx or 1, shitlist )
			if ( sm_mgr.sethelper.idx ) then
				local weapons = false
				local utility = false
				local toolbar = false
				if ( sm_mgr.sethelper.idx >= 0 and sm_mgr.sethelper.idx <= 5 ) then
					weapons = true
				end
				if ( sm_mgr.sethelper.idx >= 6 and sm_mgr.sethelper.idx <= 10 ) then
					utility = true
				end
				if ( sm_mgr.sethelper.idx >= 11 and sm_mgr.sethelper.idx <= 16 ) then
					toolbar = true
				end
				
				if ( not weapons and not utility and not toolbar) then
					local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(sm_mgr.sethelper.idx)])
					if ( skill ) then
						sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(sm_mgr.sethelper.idx)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
			
					end
				else
					if ( weapons ) then
						sm_mgr.sethelper.skillinfo = nil
						for i=0,5 do
							local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(i)])
							if ( skill ) then
								if ( not  sm_mgr.sethelper.skillinfo or sm_mgr.sethelper.skillinfo == "" ) then							
									sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
								else
									sm_mgr.sethelper.skillinfo = sm_mgr.sethelper.skillinfo.."\n ["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
									
								end
							end
						end	
					elseif ( utility ) then
						sm_mgr.sethelper.skillinfo = nil
						for i=6,10 do
							local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(i)])
							if ( skill ) then
								if ( not  sm_mgr.sethelper.skillinfo or sm_mgr.sethelper.skillinfo == "" ) then							
									sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
								else
									sm_mgr.sethelper.skillinfo = sm_mgr.sethelper.skillinfo.."\n ["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
									
								end
							end
						end
					elseif ( toolbar ) then
						sm_mgr.sethelper.skillinfo = nil
						for i=12,16 do
							local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. tostring(i)])
							if ( skill ) then
								if ( not  sm_mgr.sethelper.skillinfo or sm_mgr.sethelper.skillinfo == "" ) then							
									sm_mgr.sethelper.skillinfo = "["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
								else
									sm_mgr.sethelper.skillinfo = sm_mgr.sethelper.skillinfo.."\n ["..tostring(skill.id).."] = { \n\t slot = GW2.SKILLBARSLOT.Slot_"..tostring(i)..", \n\t activationtime = 0.5, \n\t icon = '"..skill.name.."',  \n },"
									
								end
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
RegisterEventHandler("Gameloop.Draw", sm_mgr.sethelper.DrawMenu,"sm_mgr.sethelper.DrawMenu")