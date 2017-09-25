-- Profile class for the Skill Manager. Renders Skills and handles casting etc.

sm_profile = class('sm_profile')

-- this function is automatically called when a new "instance" of the class('..') is created with sm_profile:new(...)
function sm_profile:initialize(profiledata)
	for i,k in pairs(profiledata) do
		if ( i ~= "actionlist" ) then
			self[i] = k
		end
	end
	self.actionlist = {}
	if ( profiledata.actionlist) then
		for i,k in pairs ( profiledata.actionlist ) do
			self.actionlist[i] = sm_skill:new(k)
			-- Make a copy of the actually used skillpalettes, so we can go through n Deactivate sets when not knowing which one is active
			if ( not self.temp.activeskillpalettes ) then self.temp.activeskillpalettes = {} end
			if ( not self.temp.activeskillpalettes[self.actionlist[i].skillpaletteuid] ) then
				self.temp.activeskillpalettes[self.actionlist[i].skillpaletteuid] = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][self.actionlist[i].skillpaletteuid]
			end
		end
	end	
end

function sm_profile:Save()
	if ( FolderExists(self.temp.folderpath) ) then
		local copy = {}
		for i,k in pairs(self) do
			if ( i~= "class" and i~="temp" and i ~= "actionlist") then
				copy[i] = k
			end
		end
		copy.actionlist = {}
		if(self.actionlist) then
			for i,k in pairs(self.actionlist) do
				if (k and k.id ) then
					copy.actionlist[i] = k:Save()
				end
			end
		end
		FileSave(self.temp.folderpath..self.temp.filename, copy)
		self.temp.modified = nil		
		d("[SkillManager::sm_profile] - Saved Profile : "..self.temp.filename)
		self.temp.botmainmenu_luacode_bugged = nil
	else
		ml_error("[SkillManager::sm_profile] - Could not save Profile, invalid Profile folder: "..self.temp.folderpath)
	end		
end

-- Updates all Skilldata and the shared context and metatables and target and and and
function sm_profile:UpdateContext()
	if ( not self.temp.context ) then self.temp.context = {} end
	
	self.temp.context.actionlist = self.actionlist
	local allskills = Player:GetCompleteSpellInfo()
	if ( allskills ) then
		self.temp.context.skillbar = allskills
	end
	
	self.temp.context.player = setmetatable({}, {
			__index = function (self, key)
								 local val = Player[key]
								 if( val ) then
									self.key = val
								end
								return val
							end})
	
	-- Update currently equipped weapons
	self.temp.context.player.weaponset = Player:GetCurrentWeaponSet()
	self.temp.context.player.transformid = Player:GetTransformID()
	self.temp.context.player.canswapweaponset = Player:CanSwapWeaponSet()
	local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
	if ( item ) then
		self.temp.context.player.mainhand = item.weapontype
	else
		self.temp.context.player.mainhand = nil
	end
	item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon)
	if ( item ) then
		self.temp.context.player.mainhand_alt = item.weapontype
	else
		self.temp.context.player.mainhand_alt = nil
	end
	
	item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
	if ( item ) then
		self.temp.context.player.offhand = item.weapontype
	else
		self.temp.context.player.offhand = nil
	end
	item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon)
	if ( item ) then
		self.temp.context.player.offhand_alt = item.weapontype
	else
		self.temp.context.player.offhand_alt = nil
	end
	
	item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon)
	if ( item ) then
		self.temp.context.player.aquatic = item.weapontype
	else
		self.temp.context.player.aquatic = nil
	end
	item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon)
	if ( item ) then
		self.temp.context.player.aquatic_alt = item.weapontype
	else
		self.temp.context.player.aquatic_alt = nil
	end
		
	
	self.temp.context.player.squad = Player:GetSquad()
	self.temp.context.player.party = Player:GetParty()
	
	-- Default targets
	local target = Player:GetTarget()
	if ( target ) then
		if ( target.attitude ~= GW2.ATTITUDE.Friendly and not self.temp.attack_targetid ) then			
			self.temp.attack_targetid = target.id
			self.temp.attack_target_lastupdate = ml_global_information.Now
		elseif( target.attitude == GW2.ATTITUDE.Friendly and not self.temp.heal_targetid ) then
			self.temp.heal_targetid = target.id
			self.temp.heal_target_lastupdate = ml_global_information.Now
		end
		if ( not self.temp.heal_targetid ) then 
			self.temp.heal_targetid = self.temp.context.player.id 
			self.temp.heal_target_lastupdate = ml_global_information.Now
		end
	end	
	
	-- Check if we (still) have an active target to attack and update that. Make sure it is not our player.
	local attacktargetvalid = false
	if ( self.temp.attack_targetid ) then			
		self.temp.attack_target = CharacterList:Get(self.temp.attack_targetid) or GadgetList:Get(self.temp.attack_targetid) --or AgentList:Get(self.targetid)
		if ( self.temp.attack_target and (self.temp.attack_target_lastupdate and ml_global_information.Now - self.temp.attack_target_lastupdate < 2000) and not self.temp.attack_target.dead and self.temp.attack_target.selectable and self.temp.attack_target.attitude ~= GW2.ATTITUDE.Friendly ) then
		
			self.temp.context.attack_target = setmetatable({}, {
			__index = function (self, key)
								local val = sm_mgr.profile.temp.attack_target[key]
								if( val ) then
									self.key = val
								end
								return val
							end})
			self.temp.context.attack_targetid = self.temp.attack_targetid			
			attacktargetvalid = true
		end
	end
	if ( not attacktargetvalid ) then
		self.temp.attack_target = nil
		self.temp.attack_targetid = nil
		self.temp.context.attack_target = nil
		self.temp.context.attack_targetid = nil
	end
	
	-- Update Heal Target
	local healtargetvalid = false
	if ( self.temp.heal_targetid ) then			
		self.temp.heal_target = CharacterList:Get(self.temp.heal_targetid) or GadgetList:Get(self.temp.heal_targetid) --or AgentList:Get(self.targetid)
		if ( self.temp.heal_target and (self.temp.heal_target_lastupdate and ml_global_information.Now - self.temp.heal_target_lastupdate < 2000) and self.temp.heal_target.selectable and self.temp.heal_target.attitude ~= GW2.ATTITUDE.Hostile ) then
			self.temp.context.heal_target = setmetatable({}, {
			__index = function (self, key)
								 local val = sm_mgr.profile.temp.heal_target[key]
								 if( val ) then
									self.key = val
								end
								return val
							end})
			self.temp.context.heal_targetid = self.temp.heal_targetid
			attacktargetvalid = true
		end
	end
	if ( not healtargetvalid ) then
		self.temp.heal_target = nil
		self.temp.heal_targetid = nil
		self.temp.context.heal_target = nil
		self.temp.context.heal_targetid = nil
	end
	
	-- Update Spelldata and attack/heal range and cancast
	if ( self.actionlist ) then
		for i,a in pairs (self.actionlist) do	
			a:UpdateData(self.temp.context)
		end
	end
	if ( self.fightrangetype == 1 ) then -- Dynamic fight range
		ml_global_information.AttackRange = (self.temp.activemaxattackrange and self.temp.activemaxattackrange > 154) and self.temp.activemaxattackrange or self.temp.maxattackrange
	else -- fixed fight range
		ml_global_information.AttackRange = self.fixedfightrange or ((self.temp.activemaxattackrange and self.temp.activemaxattackrange > 154) and self.temp.activemaxattackrange  or self.temp.maxattackrange)
	end	
	
end

-- Setting Targets
function sm_profile:SetTargets(attacktargetid, healtargetid)
	self.temp.attack_targetid = attacktargetid	
	self.temp.attack_target_lastupdate = ml_global_information.Now
	self.temp.heal_targetid = healtargetid
	self.temp.heal_target_lastupdate = ml_global_information.Now	
end

-- The actual casting part
function sm_profile:Cast()
	if ( not self.temp.lasttick or ml_global_information.Now - self.temp.lasttick > 100 ) then	-- Expost 100 to lua ?
		self.temp.lasttick = ml_global_information.Now

		local gw2_common_functions = _G["gw2_common_functions"]
		if ( BehaviorManager:Running() and ml_global_information.Player_HealthState ~= GW2.HEALTHSTATE.Dead) then
			
			-- Casting
			-- Make sure we finished the last cast activationtime
			if ( not self.temp.nextcasttimestamp or ml_global_information.Now >= self.temp.nextcasttimestamp ) then	
				for i,action in pairs(self.actionlist) do
					local pcastinfo = Player.castinfo
					if ( action.temp.cancast and ((pcastinfo.id ~= action.id ) or (action.activationtime == 0 and action.slot > GW2.SKILLBARSLOT.Slot_5))) then --or (action.slot == GW2.SKILLBARSLOT.Slot_1)
						
						local cancastnormal = ( not self.temp.nextcast or ml_global_information.Now - self.temp.nextcast > 0 )
						
						if ( cancastnormal and not action.skillpalette:IsActive(self.temp.context)  ) then
							local deactivated
							for uid, sp in pairs (sm_mgr.profile.temp.activeskillpalettes) do
								if ( sp:IsActive(self.temp.context) ) then
									d("[SkillManager] - Deactivating Skill Set "..tostring(uid))
									sp:Deactivate(self.temp.context)
									self.temp.lasttick = self.temp.lasttick + 150	-- do not allow anything ,not even instant casts
									deactivated = true
								end
							end
							if ( not deactivated ) then
								d("[SkillManager] - Activating Skill Set "..tostring(action.skillpaletteuid))
								action.skillpalette:Activate(self.temp.context)
								self.temp.lasttick = self.temp.lasttick + 150	-- do not allow anything ,not even instant casts
							end
							
						else
							-- We have the needed set active, cast instant casts always or only when cancastnormal
							if ( cancastnormal or (action.activationtime == 0 and action.slot > GW2.SKILLBARSLOT.Slot_5)) then
								local dbug = { [1] = "Enemy", [2] = "Player", [3] = "Friend"}
								local ttlc = self.temp.lastcast and (ml_global_information.Now-self.temp.lastcast )or 0
								d("Cast "..tostring(action.name).. " at "..tostring(dbug[action.temp.context.casttarget]) .. " - " .. tostring(ttlc))
								
								local target
								if (action.temp.context.casttarget == 1) then
									target = self.temp.context.attack_target
								elseif (action.temp.context.casttarget == 2) then
									target = self.temp.context.player
								elseif (action.temp.context.casttarget == 3) then
									target = self.temp.context.heal_target
								end
								
								if (target) then
									local castresult
									local pos = target.pos
									if ( action.isgroundtargeted ) then									
										if (target.isgadget) then
											castresult = Player:CastSpell(action.slot , pos.x, pos.y, (pos.z - target.height)) -- need to cast at the top of the gadget, else no los errors on larger things
										else
											castresult = Player:CastSpell(action.slot , pos.x, pos.y, pos.z)
										end
									
									else
										Player:SetFacingExact(pos.x, pos.y, pos.z)
										if ( action.slot == GW2.SKILLBARSLOT.Slot_1 ) then
											castresult = Player:CastSpellNoChecks(action.slot , target.id)
											
										else										
											castresult = Player:CastSpell(action.slot , target.id)
										end
										
									end
									if ( castresult ) then
										
										-- Add an internal cd, else spam
										if ( action.activationtime ~= 0 or action.slot > GW2.SKILLBARSLOT.Slot_5 ) then
											local mincasttime = action.activationtime*1000
											if ( mincasttime == 0 ) then mincasttime = 750 end											
											mincasttime = mincasttime + 450	-- THIS CAN BE EXPOSED TO LUA
											action.temp.internalcd = ml_global_information.Now + mincasttime
											self.temp.nextcast = ml_global_information.Now + mincasttime
											self.temp.lastcast = ml_global_information.Now
										end
										
									end
									
								else
									d("[SkillManager] - We miss a target ?!?! ")
								end
							end
						end
						
					end
				end
			end		
			
			-- Evade
			local evaded
			if ( Settings.GW2Minion.evade and ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive and ml_global_information.Player_InCombat and ml_global_information.Player_CastInfo and (ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.None or ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.Slot_1 )) then
				evaded = gw2_common_functions.Evade(self.temp.context.attack_target == nil and 3 or nil) -- if we dont have a target, evade forward. (3 == forward)
			end
				
			-- Combatmovement			
			if ( not evaded and ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive and Settings.GW2Minion.combatmovement ) then
				gw2_common_functions:DoCombatMovement(self.temp.context.attack_target)
			end

		else
			if ( gw2_common_functions.combatmovement.combat ) then
				Player:StopMovement()
				gw2_common_functions.combatmovement.combat = false
			end		
		end
	end
end


-- Renders elements into the SM Main Window
function sm_profile:Render()
	GUI:PushItemWidth(120)
	GUI:AlignFirstTextHeightToWidgets()
	GUI:Text(GetString("Fight Range:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("'Dynamic'- Adjusts the range depending on the available spells. 'Custom'-Tries to stay at that range during fights.")) end
	GUI:SameLine(150)
	self.fightrangetype, changed = GUI:Combo("##smfightrangetype",self.fightrangetype or 1, { [1] = GetString("Dynamic"), [2] = GetString("Custom"), })
	if ( changed ) then self.temp.modified = true end
	
	if ( self.fightrangetype == 2 ) then
		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Fight Distance:")) if (GUI:IsItemHovered()) then GUI:SetTooltip( GetString("While fighting, the bot tries to stay at this distance to the target.")) end
		GUI:SameLine(150)
		self.fixedfightrange, changed = GUI:InputInt("##smfightdistance", self.fixedfightrange or ml_global_information.AttackRange or 154, 1, 10, GUI.InputTextFlags_CharsDecimal+GUI.InputTextFlags_CharsNoBlank)	
		if ( changed ) then self.temp.modified = true end
		if ( self.fixedfightrange <= 154 ) then self.fixedfightrange = 154 end
	end		
	GUI:PopItemWidth()
	GUI:Separator()
	
	-- Main Menu CodeEditor
	local maxx,maxy = GUI:GetContentRegionAvail()
	local x,y = GUI:GetWindowSize()
	GUI:SetNextTreeNodeOpened(false,GUI.SetCond_Once)
	if ( GUI:TreeNode(GetString("Main Menu Code Editor")) ) then		
		x = 650
		if ( GUI:IsItemHovered() ) then GUI:SetTooltip(GetString( "Lua Code which gets executed from the Main Bot Menu, to render Profile Settings etc. there." ) )end
		local maxx,_ = GUI:GetContentRegionAvail()
		if ( maxx < 650 ) then maxx = x end
		local changed = false
		maxy = math.max(maxy/2,300)
		self.botmainmenu_luacode, changed = GUI:InputTextEditor( "##smmainmenueditor", self.botmainmenu_luacode or "", maxx, maxy, GUI.InputTextFlags_AllowTabInput)
		if ( changed ) then self.temp.modified = true self.temp.botmainmenu_luacode_bugged = true end
		GUI:TreePop()
	else		
		x = 280
	end
	if(self.temp.wndMaxSizeY) then y = self.temp.wndMaxSizeY	end
	GUI:SetWindowSize(x, y)
	GUI:Separator()
				
				
	-- Action List Rendering
	GUI:BeginChild("##skilllistgrp",0, self.temp.skilllistgrpheight  or 50)
	local _,height = GUI:GetCursorPos()
	if ( self.actionlist ) then
		--GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 2, 4)
		GUI:PushStyleVar(GUI.StyleVar_FramePadding, 2, 2)
		
		for i,a in pairs (self.actionlist) do
			local clicked, dragged, released = a:RenderActionButton(self.temp.selectedaction, self.temp.draggedaction,i)
			if (clicked) then
				self.temp.selectedactionidx = i
				self.temp.selectedaction = a
				self.temp.draggedaction = nil
				self.temp.draggedactionidx = nil
				
			elseif(dragged) then
				self.temp.draggedaction = a
				self.temp.draggedactionidx = i
				
			elseif(released) then
				if( self.temp.draggedaction and self.temp.draggedaction ~= a and self.temp.draggedactionidx ~= i)then
					self.temp.atmp = self.actionlist[i]
					self.actionlist[i] = self.actionlist[self.temp.draggedactionidx]
					self.actionlist[self.temp.draggedactionidx] = self.temp.atmp
					self.temp.atmp = nil
				end
				self.temp.draggedaction = nil
				self.temp.draggedactionidx = nil
			end
		end		
		-- Draw an icon for the dragging
		if ( self.temp.draggedaction ) then
			if ( GUI:IsMouseReleased(0) or not GUI:IsWindowHovered() ) then
				self.temp.draggedaction = nil
				self.temp.draggedactionidx = nil
				
			elseif( self.temp.draggedaction) then					
				local mx,my = GUI:GetMousePos()
				local cx,cy = GUI:GetCursorPos()
				local action = self.temp.draggedaction
				if ( action.icon and FileExists(sm_mgr.iconpath.."\\"..action.icon..".png") ) then
					GUI:FreeImageButton("##drag"..action.id, sm_mgr.iconpath.."\\"..action.icon..".png", mx-15,my-15, 30, 30)
				end
				GUI:SetCursorPos(cx,cy)
			end
		end
		
		GUI:PopStyleVar()
	end
	
	-- Add new Skill button if the profile is not private
	if (FolderExists(self.temp.folderpath) and GUI:ImageButton("##skillnew",sm_mgr.texturepath.."\\addon.png",25,25)) then
		if (not self.actionlist ) then self.actionlist = {} end
		table.insert(self.actionlist, sm_skill:new())	
		self.temp.selectedactionidx = #self.actionlist
		self.temp.selectedaction = self.actionlist[#self.actionlist]
	end	
	local _,endheight = GUI:GetCursorPos()
	self.temp.skilllistgrpheight = endheight - height
	GUI:EndChild()	
	
	-- Save the last Y position in our window so we can proper resize to it in the next draw call
	_,self.temp.wndMaxSizeY = GUI:GetCursorPos()
		
	-- Skill Editor / Skillpalette Selector
	if ( self.temp.selectedaction ) then
		self.temp.selectedaction:Render()
	end
end

-- Renders Custom Profile UI Elements into the Main Menu of the Bot
function sm_profile:RenderCodeEditor()
	if ( self.botmainmenu_luacode and self.botmainmenu_luacode ~= "" ) then
		if ( not self.temp.botmainmenu_luacode_compiled and not self.temp.botmainmenu_luacode_bugged ) then
			local execstring = 'return function(context) '..self.botmainmenu_luacode..' end'
			local func = loadstring(execstring)
			if ( func ) then
				func()(self.temp.context)
				self.temp.botmainmenu_luacode_compiled = func	
			else
				self.temp.botmainmenu_luacode_compiled = nil
				self.temp.botmainmenu_luacode_bugged = true
				ml_error("[SkillManager] - Main Menu Code has a BUG !!")
				assert(loadstring(execstring)) -- print out the actual error
			end
		end
	end
end






