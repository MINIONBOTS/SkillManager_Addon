-- Profile class for the Skill Manager. Renders Skills and handles casting etc.
local table = _G["table"]
local string = _G["string"]
sm_profile = class('sm_profile')
sm_profile.gw2_combat_movement = _G["gw2_combat_movement"]
-- this function is automatically called when a new "instance" of the class('..') is created with sm_profile:new(...)
function sm_profile:initialize(profiledata)
   local default_profiles = {
      ["Angryneer.sm"] = true,
      ["Elementalist.sm"] = true,
      ["Engineer.sm"] = true,
      ["Guardian.sm"] = true,
      ["Mesmer.sm"] = true,
      ["Necromancer.sm"] = true,
      ["Necromancer2.sm"] = true,
      ["Ranger.sm"] = true,
      ["Ranger-general.sm"] = true,
      ["Revenant.sm"] = true,
      ["Stryfe Mesmer.sm"] = true,
      ["Thief.sm"] = true,
      ["Warrior.sm"] = true
   }

   for i, k in pairs(profiledata) do
      if (i ~= "actionlist") then
         self[i] = k
      end
   end
   self.actionlist = {}
   if (profiledata.actionlist) then
      for i, k in pairs(profiledata.actionlist) do
         self.actionlist[i] = sm_skill:new(k)
         -- Make a copy of the actually used skillpalettes, so we can go through n Deactivate sets when not knowing which one is active
         if (not self.temp.activeskillpalettes) then
            self.temp.activeskillpalettes = {}
         end
         if (not self.temp.activeskillpalettes[self.actionlist[i].skillpaletteuid]) then
            self.temp.activeskillpalettes[self.actionlist[i].skillpaletteuid] = sm_mgr.skillpalettes[sm_mgr.GetPlayerProfession()][self.actionlist[i].skillpaletteuid]
         end
      end
   end

   self.temp.isdefaultprofile = default_profiles[profiledata.temp.filename]
   self.temp.weaponswapmode = self.temp.isdefaultprofile and Settings.SkillManager.weaponswapmode or self.weaponswapmode
   self.temp.fightrangetype = self.temp.isdefaultprofile and Settings.SkillManager.fightrangetype or self.fightrangetype
   self.temp.networklatency = self.temp.isdefaultprofile and Settings.SkillManager.networklatency or self.networklatency
   self.temp.simpleprediction = self.temp.isdefaultprofile and Settings.SkillManager.simpleprediction or self.simpleprediction

   sm_movementprediction:Enabled(self.temp.simpleprediction)
end

function sm_profile:Save()
   if (FolderExists(self.temp.folderpath)) then
      local copy = {}
      for i, k in pairs(self) do
         if (i ~= "class" and i ~= "temp" and i ~= "actionlist") then
            copy[i] = k
         end
      end
      copy.actionlist = {}
      if (self.actionlist) then
         for i, k in pairs(self.actionlist) do
            if (k and k.id) then
               copy.actionlist[i] = k:Save()
            end
         end
      end
      FileSave(self.temp.folderpath .. self.temp.filename, copy)
      self.temp.modified = nil
      d("[SkillManager::sm_profile] - Saved Profile : " .. self.temp.filename)
      self.temp.botmainmenu_luacode_bugged = nil
      self.temp.botmainmenu_luacode_compiled = nil
   else
      ml_error("[SkillManager::sm_profile] - Could not save Profile, invalid Profile folder: " .. self.temp.folderpath)
   end
end

-- Updates all Skilldata and the shared context and metatables and target and and and
function sm_profile:UpdateContext()
   if (not self.temp.context) then
      self.temp.context = {}
   end

   -- reset range
   self.temp.activemaxattackrange = 154
   self.temp.maxattackrange = 154
   self.temp.skillstopsmovement = false
   self.temp.context.actionlist = self.actionlist
   local allskills = Player:GetCompleteSpellInfo()
   if (allskills) then
      self.temp.context.skillbar = allskills
   end

   self.temp.context.player = setmetatable({}, {
      __index = function(self, key)
         local val = Player[key]
         if (val) then
            self.key = val
         end
         return val
      end })

   -- Update currently equipped weapons
   self.temp.context.player.weaponset = Player:GetCurrentWeaponSet()
   self.temp.context.player.transformid = Player:GetTransformID()
   self.temp.context.player.canswapweaponset = Player:CanSwapWeaponSet()
   self.temp.context.player.squad = Player:GetSquad()
   self.temp.context.player.party = Player:GetParty()
   self.temp.context.player.specs = Player:GetSpecs()
   self.temp.context.player.buffs = Player.buffs
   self.temp.context.player.pet = Player:GetPet()

   local item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
   if (item) then
      self.temp.context.player.mainhand = item.weapontype
   else
      self.temp.context.player.mainhand = nil
   end
   item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateMainHandWeapon)
   if (item) then
      self.temp.context.player.mainhand_alt = item.weapontype
   else
      self.temp.context.player.mainhand_alt = nil
   end

   item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
   if (item) then
      self.temp.context.player.offhand = item.weapontype
   else
      self.temp.context.player.offhand = nil
   end
   item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateOffHandWeapon)
   if (item) then
      self.temp.context.player.offhand_alt = item.weapontype
   else
      self.temp.context.player.offhand_alt = nil
   end

   item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AquaticWeapon)
   if (item) then
      self.temp.context.player.aquatic = item.weapontype
   else
      self.temp.context.player.aquatic = nil
   end
   item = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.AlternateAquaticWeapon)
   if (item) then
      self.temp.context.player.aquatic_alt = item.weapontype
   else
      self.temp.context.player.aquatic_alt = nil
   end

   -- helper for ele's crazy weaver
   if (Player.profession == GW2.CHARCLASS.Elementalist) then
      if (specs) then
         for i, s in pairs(specs) do
            if (s.id == 65) then
               self.temp.context.player.isweaver = true
            end
         end
      end
      self.temp.context.player.lasttransformid = Player:GetLastTransformID() -- ele's Weaver crap
   end

   -- If the bot is not active, we still need a target set in order to see the skills can be cast or not
   if (self.temp.open) then
      local target = Player:GetTarget()
      if (target) then
         if (target.attitude ~= GW2.ATTITUDE.Friendly) then
            self.temp.attack_targetid = target.id
            self.temp.attack_target_lastupdate = ml_global_information.Now
         elseif (target.attitude == GW2.ATTITUDE.Friendly) then
            self.temp.heal_targetid = target.id
            self.temp.heal_target_lastupdate = ml_global_information.Now
         end
      end
   end

   if (not self.temp.heal_targetid) then
      local lowesthp = 101
      if (self.temp.context.player.party) then
         for id, p in pairs(self.temp.context.player.party) do
            if (p.id ~= ml_global_information.Player_ID) then
               local e = CharacterList:Get(p.id)
               if (e) then
                  local ehp = e.health
                  if (e.distance < 1200 and ehp and ehp.percent < lowesthp) then
                     lowesthp = ehp.percent
                     self.temp.heal_targetid = p.id
                     self.temp.heal_target_lastupdate = ml_global_information.Now
                  end
               end
            end
         end
      end
      if (self.temp.context.player.squad) then
         for id, p in pairs(self.temp.context.player.squad) do
            if (p.id ~= ml_global_information.Player_ID) then
               local e = CharacterList:Get(p.id)
               if (e) then
                  local ehp = e.health
                  if (e.distance < 1200 and ehp and ehp.percent < lowesthp) then
                     lowesthp = ehp.percent
                     self.temp.heal_targetid = p.id
                     self.temp.heal_target_lastupdate = ml_global_information.Now
                  end
               end
            end
         end
      end

      if (not self.temp.heal_targetid) then
         local clist = CharacterList("friendly,player,maxdistance=1200,lowesthealthpercent,alive")
         for id, e in pairs(clist) do
            local ehp = e.health
            if (e.distance < 1200 and ehp and ehp.percent < lowesthp) then
               lowesthp = ehp.percent
               self.temp.heal_targetid = e.id
               self.temp.heal_target_lastupdate = ml_global_information.Now
            end
         end
      end
   end


   -- Check if we (still) have an active target to attack and update that. Make sure it is not our player.
   local attacktargetvalid = false
   if (self.temp.attack_targetid) then
      self.temp.attack_target = CharacterList:Get(self.temp.attack_targetid) or GadgetList:Get(self.temp.attack_targetid) or AgentList:Get(self.targetid)
      if (self.temp.attack_target and (self.temp.attack_target_lastupdate and ml_global_information.Now - self.temp.attack_target_lastupdate < 1000) and not self.temp.attack_target.dead and (self.temp.attack_target.attackable or (self.temp.attack_target.isentity and self.temp.attack_target.attitude == GW2.ATTITUDE.Hostile and not self.temp.attack_target.isgadget and not self.temp.attack_target.ischaracter and not self.temp.attack_target.health))) then
         self.temp.context.attack_target = setmetatable({}, {
            __index = function(self, key)
               local val = sm_mgr.profile.temp.attack_target[key]
               if (val) then
                  self.key = val
               end
               return val
            end })
         self.temp.context.attack_targetid = self.temp.attack_targetid
         attacktargetvalid = true

         sm_movementprediction:Update(self.temp.attack_target)

      end
   end
   if (not attacktargetvalid) then
      self.temp.attack_target = nil
      self.temp.attack_targetid = nil
      self.temp.context.attack_target = nil
      self.temp.context.attack_targetid = nil
   end

   -- Update Heal Target
   local healtargetvalid = false
   if (self.temp.heal_targetid) then
      self.temp.heal_target = CharacterList:Get(self.temp.heal_targetid) or GadgetList:Get(self.temp.heal_targetid) --or AgentList:Get(self.targetid)
      if (self.temp.heal_target and (self.temp.heal_target_lastupdate and ml_global_information.Now - self.temp.heal_target_lastupdate < 1000) and self.temp.heal_target.selectable and self.temp.heal_target.attitude ~= GW2.ATTITUDE.Hostile) then
         self.temp.context.heal_target = setmetatable({}, {
            __index = function(self, key)
               local val = sm_mgr.profile.temp.heal_target[key]
               if (val) then
                  self.key = val
               end
               return val
            end })
         self.temp.context.heal_targetid = self.temp.heal_targetid
         healtargetvalid = true
      end
   end
   if (not healtargetvalid) then
      self.temp.heal_target = nil
      self.temp.heal_targetid = nil
      self.temp.context.heal_target = nil
      self.temp.context.heal_targetid = nil
   end

   local clist = CharacterList("")
   local ppos = self.temp.context.player.pos
   self.temp.context.player.friends_nearby = {}
   self.temp.context.player.enemies_nearby = {}

   for i, k in pairs(clist) do
      local cpos = k.pos
      local att = k.attitude
	  if k.dead == false and k.attackable == true then
			if (att < 3) then
				if (att == 0) then
				-- Friendly
					self.temp.context.player.friends_nearby[i] = { pos = cpos } -- leaving this to be a table, maybe other shit is needed later on
				else
					self.temp.context.player.enemies_nearby[i] = { pos = cpos }
				end
			end
		end
   end


   -- Update Spelldata and attack/heal range and cancast
   if (self.actionlist) then
      for i, a in pairs(self.actionlist) do
         a:UpdateData(self.temp.context)
      end
   end

   if (self.temp.fightrangetype == 1) then
      -- Dynamic fight range
      ml_global_information.AttackRange = (self.temp.activemaxattackrange and self.temp.activemaxattackrange >= 154) and self.temp.activemaxattackrange or 154 -- (self.temp.maxattackrange or 154)
   else
      -- fixed fight range
      ml_global_information.AttackRange = self.fixedfightrange or ((self.temp.activemaxattackrange and self.temp.activemaxattackrange > 154) and self.temp.activemaxattackrange or 154) -- self.temp.maxattackrange or 154)
   end
   --d(tostring(self.temp.activemaxattackrange) .. " - STATIC:" ..tostring(self.temp.maxattackrange))
end

-- Setting Targets
function sm_profile:SetTargets(attacktargetid, healtargetid)
   self.temp.attack_targetid = attacktargetid
   self.temp.attack_target_lastupdate = ml_global_information.Now
   self.temp.heal_targetid = healtargetid
   self.temp.heal_target_lastupdate = ml_global_information.Now
end

-- Current skill does not allow any movement during cast
function sm_profile:SkillStopsMovement()
   return self.temp.skillstopsmovement == true
end

-- The actual casting part
local gw2_common_functions = _G.gw2_common_functions -- set this here. wont ever change and setting it each 'Cast()' call is insanity.
function sm_profile:Cast()

   local runloop = true

   -- Hold the casting until the to-be-deactivated palett is not active or max 500ms
   if (self.temp.deactivateSkillPalette) then
      runloop = false
      if (not self.temp.deactivateSkillPalette:IsActive(self.temp.context)) then
         runloop = true
         self.temp.deactivateSkillPalette = nil
         self.temp.deactivateSkillPalette_start = nil
         --self.temp.lasttick = ml_global_information.Now + 150 -- wait one more tick, else stuff is too fast sometimes

      else
         if (ml_global_information.Now - self.temp.deactivateSkillPalette_start > 300) then
            -- fallback check to not get stuck
            runloop = true
            self.temp.deactivateSkillPalette = nil
            self.temp.deactivateSkillPalette_start = nil
         end
      end
   end

   -- Hold the casting until the targeted skill palette is active or max 500ms
   if (not self.temp.deactivateSkillPalette and self.temp.switchToSkillPalette) then
      runloop = false
      if (self.temp.switchToSkillPalette:IsActive(self.temp.context)) then
         runloop = true
         self.temp.switchToSkillPalette = nil
         self.temp.switchToSkillPalette_start = nil
         --self.temp.lasttick = ml_global_information.Now + 150 -- wait one more tick, else stuff is too fast sometimes

      else
         if (ml_global_information.Now - self.temp.switchToSkillPalette_start > 300) then
            -- fallback check to not get stuck
            runloop = true
            self.temp.switchToSkillPalette = nil
            self.temp.switchToSkillPalette_start = nil
         end
      end
   end

   if (runloop and (not self.temp.lasttick or ml_global_information.Now - self.temp.lasttick > 50)) then
      -- Expose this 100 to lua to make shit even faster ?) then
      self.temp.lasttick = ml_global_information.Now

      if (BehaviorManager:Running() and ml_global_information.Player_HealthState ~= GW2.HEALTHSTATE.Dead and not self.temp.interactionstart) then

         local skipnoneinstantactions
         if self.temp.attack_target then
            if Settings.SkillManager.auto_mount_engage and self.temp.attack_target and self.temp.attack_target.distance < 600 and ml_global_information.Player_IsMounted then
               if self.temp.context.skillbar and self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_1] and not SkillManager:HasSkillID(self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_1].id) then
                  if (ml_global_information.Player_CastInfo.skillid ~= self.temp.context.skillbar[GW2.SKILLBARSLOT.Slot_1].id) then
                     Player:CastSpell(GW2.SKILLBARSLOT.Slot_1, self.temp.attack_targetid)
                     d("[SkillManager]: Skillprofile does not contain conditions for the current engage skill. Using it to dismount with style.")
                     return
                  end
               end
            end
         end

         for i, a in pairs(self.actionlist) do
            local action
            --override the action to cast our combos
            if (self.temp.nextcomboaction) then
               if (ml_global_information.Now - self.temp.nextcomboactionEndTime > 300) then
                  -- we did not cast the combo yet, something went probably wrong so we stop attempting to finish the combo
                  self.temp.nextcomboaction = nil
                  self.temp.nextcomboactionEndTime = nil
               else
                  action = self.temp.nextcomboaction
               end
            end
            if (not action) then
               action = a
            end

            self.temp.skillstopsmovement = (action.stopsmovement and not action.instantcast)

            ml_global_information.Player_CastInfo = Player.castinfo
            if (action.temp.cancast and ((ml_global_information.Player_CastInfo.skillid ~= action.id and not skipnoneinstantactions) or action.instantcast)) then
               -- .cancast includes Cooldown, Power and "Do we have that set and skill at all" checks

               local cancastnormal = (not self.temp.nextcast or ml_global_information.Now - self.temp.nextcast > 0)

               if ((cancastnormal or action.instantcast) and action:IsCastTargetValid()) then
                  if (not action.skillpalette:IsActive(self.temp.context)) then

                     if (self.temp.weaponswapmode and self.temp.weaponswapmode == 1) then
                        local deactivated
                        for uid, sp in pairs(sm_mgr.profile.temp.activeskillpalettes) do
                           if (action.skillpalette.uid ~= uid) then
                              if (sp:IsActive(self.temp.context)) then
                                 d("[SkillManager] - Deactivating Skill Set " .. tostring(uid))
                                 if (sp:Deactivate(self.temp.context)) then
                                    self.temp.deactivateSkillPalette_start = self.temp.lasttick
                                    self.temp.deactivateSkillPalette = sp
                                    deactivated = true
                                    skipnoneinstantactions = true
                                    break
                                 end
                              end
                           end
                        end
                        if (not deactivated) then
                           d("[SkillManager] - Activating Skill Set " .. tostring(action.skillpaletteuid) .. " to cast " .. tostring(action.name))
                           action.skillpalette:Activate(self.temp.context)
                           self.temp.switchToSkillPalette_start = self.temp.lasttick
                           self.temp.switchToSkillPalette = action.skillpalette
                           break -- breaks the main actionlist loop !
                        end
                     end

                  else

                     if (ml_global_information.Player_CastInfo.skillid ~= action.id) then
                        local dbug = { [1] = "Enemy", [2] = "Player", [3] = "Friend" }
                        local ttlc = self.temp.lastcast and (ml_global_information.Now - self.temp.lastcast) or 0
                        local target = action:GetCastTarget()
                        local ppos = self.temp.context.player.pos

                        sm_movementprediction:SetActivationTime(target, action.activationtime)

                        if (target) then
                           local castresult
                           local pos, distance = sm_movementprediction:GetPosDistance(target)
                           -- check for slot 555 first, fictional slot for non skill skills.
                           -- needed for things like dodge and swap, maybe others too.
                           if (action.slot == 555) then
                              if (action.id == 10) then
                                 -- id 10 == normal dodge forward. (todo, need some directional stuff?)
                                 Player:Evade(3)
                              elseif (action.id == 20) then
                                 -- id 20 == swap weaponset.
                                 Player:SwapWeaponSet()
                              elseif (action.id == 30) then
                                 -- id 30 == switch pet
                                 Player:SwitchPet()
                              end
                           elseif (action.isgroundtargeted) then
                              if not target.ischaracter and not target.isgadget then
                                 local RC = {}
                                 local fallback = true
                                 for i=pos.z, pos.z - target.height, -target.height/5 do
                                    RC.hit, RC.x, RC.y, RC.z = RayCast(ppos.x,ppos.y,ppos.z-35,pos.x,pos.y,i)
                                    if RC.hit and RC.x ~= 0 and RC.y ~=0 and RC.z ~= 0 then
                                       local distxy = math.distance2d(RC,pos)
                                       if distxy <= target.radius and RC.z <= pos.z and RC.z >= pos.z - target.height then
                                          local mag = math.distance3d(RC,ppos)
                                          local raddif = target.radius - math.distance2d(RC,pos)
                                          local hx1 = raddif*(RC.x - ppos.x)/mag
                                          local hy1 = raddif*(RC.y - ppos.y)/mag
                                          local player_to_target = math.distance2d(pos,ppos)
                                          local castloc_to_target = math.distance2d(RC.x-hx1, RC.y-hy1, pos.x, pos.y)
                                          if player_to_target-24 < castloc_to_target and ppos.z < pos.z and ppos.z > pos.z - target.height then
                                             local hx1 = 24*(pos.x - ppos.x)/player_to_target
                                             local hy1 = 24*(pos.y - ppos.y)/player_to_target
                                             castresult = Player:CastSpell(action.slot, ppos.x+hx1, ppos.y+hy1, ppos.z)
                                          else
                                             castresult = Player:CastSpell(action.slot, RC.x-hx1, RC.y-hy1, RC.z)
                                          end
                                          fallback = false
                                          break
                                       end
                                    end
                                 end
                                 if fallback then
                                    RC.hit, RC.x, RC.y, RC.z = RayCast(pos.x,pos.y,pos.z,pos.x,pos.y,pos.z+100)

                                    if RC.hit then
                                       local newz  = RC.z
                                       for i=newz, pos.z, (pos.z - newz)/5 do
                                          RC.hit, RC.x, RC.y, RC.z = RayCast(ppos.x,ppos.y,ppos.z-35,pos.x,pos.y,i)
                                          if RC.hit and RC.x ~= 0 and RC.y ~=0 and RC.z ~= 0 then
                                             local distxy = math.distance2d(RC,pos)
                                             if distxy <= target.radius and RC.z <= pos.z and RC.z >= pos.z - target.height then
                                                local mag = math.distance3d(RC,ppos)
                                                local raddif = target.radius - math.distance2d(RC,pos)
                                                local hx1 = raddif*(RC.x - ppos.x)/mag
                                                local hy1 = raddif*(RC.y - ppos.y)/mag
                                                local player_to_target = math.distance2d(pos,ppos)
                                                local castloc_to_target = math.distance2d(RC.x-hx1, RC.y-hy1, pos.x, pos.y)
                                                if player_to_target-24 < castloc_to_target and ppos.z < pos.z and ppos.z > pos.z - target.height then
                                                   local hx1 = 24*(pos.x - ppos.x)/player_to_target
                                                   local hy1 = 24*(pos.y - ppos.y)/player_to_target
                                                   castresult = Player:CastSpell(action.slot, ppos.x+hx1, ppos.y+hy1, ppos.z)
                                                else
                                                   castresult = Player:CastSpell(action.slot, RC.x-hx1, RC.y-hy1, RC.z)
                                                end
                                                fallback = false
                                                break
                                             end
                                          end
                                       end
                                    end
                                    if fallback then
                                       castresult = Player:CastSpell(action.slot, pos.x, pos.y, (pos.z-target.height))
                                    end
                                 end
                              elseif target.isgadget then
                                 local RC = {}
                                 local fallback = true
                                 for i=pos.z, pos.z - target.height, -target.height/5 do
                                    RC.hit, RC.x, RC.y, RC.z = RayCast(ppos.x,ppos.y,ppos.z-35,pos.x,pos.y,i)
                                    if RC.hit and RC.x ~= 0 and RC.y ~=0 and RC.z ~= 0 then
                                       local distxy = math.distance2d(RC,pos)
                                       if distxy <= target.radius and RC.z <= pos.z and RC.z >= pos.z - target.height then
                                          local mag = math.distance3d(RC,ppos)
                                          local raddif = target.radius - math.distance2d(RC,pos)
                                          local hx1 = raddif*(RC.x - ppos.x)/mag
                                          local hy1 = raddif*(RC.y - ppos.y)/mag
                                          local player_to_target = math.distance2d(pos,ppos)
                                          local castloc_to_target = math.distance2d(RC.x-hx1, RC.y-hy1, pos.x, pos.y)
                                          if player_to_target-24 < castloc_to_target and ppos.z < pos.z and ppos.z > pos.z - target.height then
                                             local hx1 = 24*(pos.x - ppos.x)/player_to_target
                                             local hy1 = 24*(pos.y - ppos.y)/player_to_target
                                             castresult = Player:CastSpell(action.slot, ppos.x+hx1, ppos.y+hy1, ppos.z)
                                          else
                                             castresult = Player:CastSpell(action.slot, RC.x-hx1, RC.y-hy1, RC.z)
                                          end
                                          fallback = false
                                          break
                                       end
                                    end
                                 end
                                 if fallback then
                                    castresult = Player:CastSpell(action.slot, pos.x, pos.y, (pos.z-target.height))
                                 end
                              else
                                 castresult = Player:CastSpell(action.slot, pos.x, pos.y, pos.z)
                              end

                           else

                              Player:SetTarget(target.id)
                              --if (  and target.distance > 100 and BehaviorManager:CurrentBTreeName() ~= GetString("AssistMode")) then -- dont face targets in assist mode. Might need more logic for firing skills while using "moveto" or similar task, if that is a thing we do.
                              --Player:SetFacing(pos.x, pos.y, pos.z)
                              --end
                              if (action.slot == GW2.SKILLBARSLOT.Slot_1 or action.instantcast) then
                                 castresult = Player:CastSpellNoChecks(action.slot, target.id)

                              else
                                 castresult = Player:CastSpell(action.slot, target.id)
                              end
                           end
                           if (castresult) then
                              d("[SkillManager] - Casting " .. tostring(action.name) .. " at " .. tostring(dbug[action.temp.casttarget]) .. " - " .. tostring(ttlc))

                              -- Add an internal cd, else spam
                              local mincasttime = action.activationtime * 1010
                              mincasttime = mincasttime + (self.temp.networklatency or 0)
                              action.temp.internalcd = ml_global_information.Now + mincasttime
                              if (not action.instantcast) then
                                 self.temp.nextcast = ml_global_information.Now + mincasttime
                                 self.temp.lastcast = ml_global_information.Now
                              end

                              -- Check if we cast a combo action
                              if (action.skill_next) then
                                 self.temp.nextcomboaction = action.skill_next
                                 local combotime = action.skill_next.activationtime * 1000
                                 if (combotime == 0) then
                                    combotime = 750
                                 end
                                 self.temp.nextcomboactionEndTime = ml_global_information.Now + mincasttime + combotime
                              else
                                 self.temp.nextcomboaction = nil
                                 self.temp.nextcomboactionEndTime = nil
                              end
                              break
                           end
                        end
                     end
                  end
               end
            end
            if (self.temp.nextcomboaction) then
               break -- dont loop through the actionlist when we override the action anyway with out combo that still needs to get finished
            end
         end

         -- Evade
         local evaded
         if (ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Alive) then
            if (not self:SkillStopsMovement() and ml_global_information.Player_InCombat and ml_global_information.Player_CastInfo and (ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.None or ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.Slot_1)) then
               evaded = gw2_common_functions.Evade(self.temp.context.attack_target == nil and 3 or nil) -- if we dont have a target, evade forward. (3 == forward)
            end

            -- Combatmovement
            if (not evaded and Settings.GW2Minion.combatmovement) then
               if (self:SkillStopsMovement()) then
                  sm_profile.gw2_combat_movement:PreventCombatMovement()
               end
               sm_profile.gw2_combat_movement:DoCombatMovement(self.temp.context.attack_target)
            end
         end

      else
         -- Call combatmovement without a target to stop all combatmovement related movement.
         sm_profile.gw2_combat_movement:DoCombatMovement()

         -- Handling that the player is Interacting / finishing / stuff
         if (self.temp.interactionstart and ml_global_information.Player_CastInfo) then
            local interactiontime = ml_global_information.Now - self.temp.interactionstart

            -- when to stop the interaction
            if (interactiontime > 250) then
               if (ml_global_information.Player_CastInfo.slot == GW2.SKILLBARSLOT.None and ml_global_information.Player_CastInfo.skillid == 0) then
                  self.temp.interactionstart = nil
               end
            end

            if (interactiontime > 5000) then
               -- fallback for whatever crazy shit may happen
               self.temp.interactionstart = nil
            end
         end
      end
   end
end

-- Renders elements into the SM Main Window
function sm_profile:Render()
   local content
   GUI:PushItemWidth(120)
   GUI:AlignFirstTextHeightToWidgets()
   GUI:BeginGroup()
   GUI:Text(GetString("Fight Range:"))

   GUI:SameLine(150)
   if (self.temp.isdefaultprofile) then
      Settings.SkillManager.fightrangetype, changed = GUI:Combo("##smfightrangetype", Settings.SkillManager.fightrangetype or 1, { [1] = GetString("Dynamic"), [2] = GetString("Custom"), })
      self.temp.fightrangetype = Settings.SkillManager.fightrangetype
   else
      self.fightrangetype, changed = GUI:Combo("##smfightrangetype", self.fightrangetype or 1, { [1] = GetString("Dynamic"), [2] = GetString("Custom"), })
      self.temp.fightrangetype = self.fightrangetype
   end
   if (changed) then
      self.temp.modified = true
   end
   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("'Dynamic' - Adjusts the range depending on the available spells.") .. "\n" .. GetString("'Custom' - Tries to stay at that range during fights."))
   end

   GUI:BeginGroup()
   if (self.temp.fightrangetype == 2) then
      GUI:AlignFirstTextHeightToWidgets()
      GUI:Text(GetString("Fight Distance:"))
      GUI:SameLine(150)
      self.fixedfightrange, changed = GUI:InputInt("##smfightdistance", self.fixedfightrange or ml_global_information.AttackRange or 154, 1, 10, GUI.InputTextFlags_CharsDecimal + GUI.InputTextFlags_CharsNoBlank)
      if (changed) then
         self.temp.modified = true
      end
      if (self.fixedfightrange <= 154) then
         self.fixedfightrange = 154
      end
   end
   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("While fighting, the bot tries to stay at this distance to the target."))
   end

   GUI:BeginGroup()
   GUI:AlignFirstTextHeightToWidgets()
   GUI:Text(GetString("Swap Weapons:"))
   GUI:SameLine(150)
   if (self.temp.isdefaultprofile) then
      Settings.SkillManager.weaponswapmode, changed = GUI:Combo("##smweaponswapmode", Settings.SkillManager.weaponswapmode or 1, { [1] = GetString("Automatic"), [2] = GetString("Manual"), })
      self.temp.weaponswapmode = Settings.SkillManager.weaponswapmode
   else
      self.weaponswapmode, changed = GUI:Combo("##smweaponswapmode", self.weaponswapmode or 1, { [1] = GetString("Automatic"), [2] = GetString("Manual"), })
      self.temp.weaponswapmode = self.weaponswapmode
   end
   if (changed) then
      self.temp.modified = true
   end
   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("'Automatic' - Automatically switches Weapons/Kits/Stances.") .. "\n" .. GetString("'Manual' - You switch Weapons/Kits/Stances."))
   end

   GUI:BeginGroup()
   GUI:AlignFirstTextHeightToWidgets()
   GUI:Text(GetString("Network Latency:"))
   GUI:SameLine(150)
   if (self.temp.isdefaultprofile) then
      Settings.SkillManager.networklatency, changed = GUI:SliderInt("##swnetworklatency", Settings.SkillManager.networklatency or 0, 0, 1000)
      self.temp.networklatency = Settings.SkillManager.networklatency
   else
      self.networklatency, changed = GUI:SliderInt("##swnetworklatency", self.networklatency or 0, 0, 1000)
      self.temp.networklatency = self.networklatency
   end
   if (changed) then
      self.temp.modified = true
   end
   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("This value (in ms) is added to the duration of each skill that is cast.") .. "\n" .. GetString("If you have a high ping or network latency, increasing this will try to prevent the bot from interrupting skills."))
   end

   GUI:BeginGroup()
   GUI:AlignFirstTextHeightToWidgets()
   GUI:Text(GetString("Auto Mount Engage:"))
   GUI:SameLine(150)
   content, changed = GUI:Checkbox("##MountEngage", Settings.SkillManager.auto_mount_engage or false)
   if (changed) then
      Settings.SkillManager.auto_mount_engage = content
   end
   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("When your current Skillprofile does not contain the\ncurrent mounts engage skill SkillManager will use it automatically."))
   end

   GUI:BeginGroup()
   GUI:AlignFirstTextHeightToWidgets()
   GUI:Text(GetString("Movement prediciton:"))
   GUI:SameLine(150)
   if (self.temp.isdefaultprofile) then
      Settings.SkillManager.simpleprediction, changed = GUI:Checkbox("##swsimpleprediction", Settings.SkillManager.simpleprediction or false)
      self.temp.simpleprediction = Settings.SkillManager.simpleprediction
   else
      self.simpleprediction, changed = GUI:Checkbox("##simpleprediction", self.simpleprediction or false)
      self.temp.simpleprediction = self.simpleprediction
   end
   if (changed) then
      self.temp.modified = true
      sm_movementprediction:Enabled(self.temp.simpleprediction)
   end

   GUI:EndGroup()
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("The bot will try to look a small amount of time into the future."))
   end

   GUI:PopItemWidth()
   GUI:Separator()


   -- Main Menu CodeEditor
   local maxx, maxy = GUI:GetContentRegionAvail()
   local x, y = GUI:GetWindowSize()
   GUI:SetNextTreeNodeOpened(false, GUI.SetCond_Once)
   if (GUI:TreeNode(GetString("Main Menu Code Editor"))) then
      x = 650
      if (GUI:IsItemHovered()) then
         GUI:SetTooltip(GetString("Lua Code which gets executed from the Main Bot Menu, to render Profile Settings etc. there."))
      end
      local maxx, _ = GUI:GetContentRegionAvail()
      if (maxx < 650) then
         maxx = x
      end
      local changed = false
      self.botmainmenu_luacode, changed = GUI:InputTextEditor("##smmainmenueditor", self.botmainmenu_luacode or "", maxx, 450, GUI.InputTextFlags_AllowTabInput)
      if (changed) then
         self.temp.modified = true
      end
      GUI:TreePop()
   else
      x = 400
   end
   if (self.temp.wndMaxSizeY) then
      y = self.temp.wndMaxSizeY
   end

   local padding_y = 10 -- No double scrollbars please
   local style = GUI:GetStyle()
   if (table.valid(style) and table.valid(style.windowpadding) and type(style.windowpadding.y) == "number") then
      padding_y = style.windowpadding.y
   end
   GUI:SetWindowSize(x, y + padding_y)

   GUI:Separator()

   self.temp.skillfilter = GUI:InputText(GetString("Filter") .. "##skfilter1", self.temp.skillfilter or "")
   if (GUI:IsItemHovered()) then
      GUI:SetTooltip(GetString("'To filter the List of Skills below. You cannot drag / drop / sort the list while this filter is active!"))
   end

   GUI:Separator()

   -- Action List Rendering
   GUI:BeginChild("##skilllistgrp", 0, self.temp.skilllistgrpheight or 200)
   local _, height = GUI:GetCursorPos()
   if (self.actionlist) then
      --GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 2, 4)
      GUI:PushStyleVar(GUI.StyleVar_FramePadding, 2, 2)

      for i, a in pairs(self.actionlist) do
         if (self.temp.skillfilter == "" or (string.valid(a.name) and string.contains(string.lower(a.name), string.lower(self.temp.skillfilter)))) then
            local clicked, dragged, released = a:RenderActionButton(self.temp.selectedaction, self.temp.draggedaction, i)
            if (clicked) then
               self.temp.selectedactionidx = i
               self.temp.selectedaction = a
               self.temp.draggedaction = nil
               self.temp.draggedactionidx = nil
               self.temp.draggedcounter = nil
            elseif (self.temp.skillfilter == "" and dragged) then
               -- a few ms delay to avoid bouncy buttons
               self.temp.draggedcounter = self.temp.draggedcounter and self.temp.draggedcounter + 1 or 1
               if (self.temp.draggedcounter > 5) then
                  self.temp.draggedaction = a
                  self.temp.draggedactionidx = i
               end
            elseif (self.temp.skillfilter == "" and released) then
               if (self.temp.draggedactionidx) then
                  -- sometimes nil
                  if (self.temp.draggedaction and self.temp.draggedaction ~= a and self.temp.draggedactionidx ~= i) then
                     table.insert(self.actionlist, i, table.remove(self.actionlist, self.temp.draggedactionidx))
                     self.temp.modified = true
                  end
                  local tmp = self.actionlist
                  self.actionlist = {}
                  for i, k in pairs(tmp) do
                     table.insert(self.actionlist, k)
                  end
               end
               self.temp.draggedaction = nil
               self.temp.draggedactionidx = nil
               self.temp.draggedcounter = nil
               break
            end
         end
      end
      -- Draw an icon for the dragging
      if (self.temp.skillfilter == "" and self.temp.draggedaction) then
         if (GUI:IsMouseReleased(0) or not GUI:IsWindowFocused()) then
            self.temp.draggedaction = nil
            self.temp.draggedactionidx = nil

         elseif (self.temp.draggedaction) then
            local mx, my = GUI:GetMousePos()
            local cx, cy = GUI:GetCursorPos()
            local action = self.temp.draggedaction
            if (action.icon and FileExists(sm_mgr.iconpath .. "\\" .. action.icon .. ".png")) then
               GUI:FreeImageButton("##drag" .. action.id, sm_mgr.iconpath .. "\\" .. action.icon .. ".png", mx - 15, my - 15, 30, 30)
            end
            GUI:SetCursorPos(cx, cy)
         end
      end

      GUI:PopStyleVar()
   end

   -- Add new Skill button if the profile is not private
   if (FolderExists(self.temp.folderpath) and GUI:ImageButton("##skillnew", sm_mgr.texturepath .. "\\addon.png", 25, 25)) then
      if (not self.actionlist) then
         self.actionlist = {}
      end
      table.insert(self.actionlist, sm_skill:new())
      self.temp.selectedactionidx = #self.actionlist
      self.temp.selectedaction = self.actionlist[#self.actionlist]
   end
   local _, endheight = GUI:GetCursorPos()
   self.temp.skilllistgrpheight = (endheight - height) + 50
   local _, sm = GUI:GetScreenSize()
   if (self.temp.skilllistgrpheight > (sm * 3 / 5)) then
      self.temp.skilllistgrpheight = (sm * 3 / 5) - height
   end

   GUI:EndChild()

   -- Save the last Y position in our window so we can proper resize to it in the next draw call
   _, self.temp.wndMaxSizeY = GUI:GetCursorPos()

   -- Skill Editor / Skillpalette Selector
   if (self.temp.selectedaction) then
      self.temp.selectedaction:Render()
   end
end

-- Renders Custom Profile UI Elements into the Main Menu of the Bot
function sm_profile:RenderCodeEditor()
   if (self.botmainmenu_luacode and self.botmainmenu_luacode ~= "") then
      if (not self.temp.botmainmenu_luacode_compiled) then
         if (not self.temp.modified) then
            local execstring = 'return function(context) ' .. self.botmainmenu_luacode .. ' end'
            local func = loadstring(execstring)
            if (func) then
               func()(self.temp.context)
               self.temp.botmainmenu_luacode_compiled = func
            else
               self.temp.botmainmenu_luacode_compiled = nil
               if (not self.temp.botmainmenu_luacode_bugged) then
                  ml_error("[SkillManager] - Main Menu Code has a BUG !!")
                  assert(loadstring(execstring)) -- print out the actual error
                  self.temp.botmainmenu_luacode_bugged = true
               end
            end
         end
      else
         --executing the already loaded function
         self.temp.botmainmenu_luacode_compiled()(self.temp.context)
      end
   end
end
