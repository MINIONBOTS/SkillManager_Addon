-- Hardcoded Skill Palettes for the Necromancer Profession.
	--[[self.temp.context.player.weaponset = {
		[0] = "Aqua1",
		[1] = "Aqua2",
		[2] = "Kit/Astral",
		[3] = "LichForm, Moa, mini, tornado ",
		[4] = "Weapon1",
		[5] = "Weapon2",
	},
	
	self.temp.context.player.transformid = {
		0	NONE,
		1	ELE_FIRE, Kits, bundles , pickup weapons
		2	ELE_WATER,
		3	ELE_AIR,
		4	ELE_EARTH,
		5	UNKNOWN1,
		6	NECRO_SHROUD,
		7	WAR_ADREN1,
		8	WAR_ADREN2,
		9	WAR_ADREN3,
		10	RANGER_DRUID,
		11	RANGER_ASTRAL,
		12	UNKNOWN2,
		13	REV_DRAGON,
		14	REV_ASSASSIN,
		15	REV_DWARF,
		16	REV_DEMON,
		17	UNKNOWN3,
		18	REV_CENTAUR	
	},]]

local axe = SkillManager:CreateSkillPalette('axe')
axe.uid = "Necromancer_Axe"
axe.profession = GW2.CHARCLASS.Necromancer
axe.icon = "Axe"
-- axe.id =   --> set a skill ID if you want it to download an icon for this skillset 
axe.skills_luacode = {
	[10561] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 1,
		icon = 'Rending Claws',
	},
	[10528] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 1.75,
		icon = 'Ghastly Claws',
	},
	[10701] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 1,
		icon = 'Unholy Feast',
	},
	-- [38767] = {
		-- slot = GW2.SKILLBARSLOT.Slot_3,
		-- activationtime = 0.0,
		-- icon = "Unholy Burst",
	-- },
}
-- Additionally available:
-- context.player
-- context.player.transformid
-- context.player.weaponset
-- context.player.canswapweaponset 
-- context.player.mainhand
-- context.player.mainhand_alt 
-- context.player.offhand
-- context.player.offhand_alt
-- context.player.aquatic
-- context.player.aquatic_alt
-- others, check ingame the green ? in CUSTOM LUA CONDITION EDITOR to see all
-- IF YOU NEED OTHERS, TELL ME OR ADD THEM YOURSELF AT sm_profile.lua line ~51 -> function sm_profile:UpdateContext()
function axe:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 10561)	
end
function axe:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Axe or context.player.mainhand_alt == GW2.WEAPONTYPE.Axe) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0 -- we have an axe and a kit currently equipped
end
function axe:Activate(context)
	Player:SwapWeaponSet()
end
function axe:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( axe )



local warhorn = SkillManager:CreateSkillPalette('warhorn')
warhorn.uid = "Necromancer_Warhorn"
warhorn.profession = GW2.CHARCLASS.Necromancer
warhorn.icon = "Warhorn"
-- warhorn.id =   --> set a skill ID if you want it to download an icon for this skillset 
warhorn.skills_luacode = {
	[10556] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = 'Wail of Doom',
	},
	[10557] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.5,
		icon = 'Locust Swarm',
	},
}
function warhorn:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 10556)
end
function warhorn:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Warhorn or context.player.offhand_alt == GW2.WEAPONTYPE.Warhorn) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function warhorn:Activate(context)
	Player:SwapWeaponSet()
end
function warhorn:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( warhorn )



local staff = SkillManager:CreateSkillPalette('staff')
staff.uid = "Necromancer_Staff"
staff.profession = GW2.CHARCLASS.Necromancer
staff.icon = "Staff"
-- staff.id =   --> set a skill ID if you want it to download an icon for this skillset 
staff.skills_luacode = {
	[10596] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.75,
		icon = 'Necrotic Grasp',
	},
	[19117] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.75,
		icon = 'Mark of Blood',
	},
	[10605] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.75,
		icon = 'Chillblains',
	},
	[19116] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.75,
		icon = 'Putrid Mark',
	},
	[19115] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.75,
		icon = 'Reapers Mark',
	},
}
function staff:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 10596)
end
function staff:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Staff or context.player.mainhand_alt == GW2.WEAPONTYPE.Staff) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function staff:Activate(context)
	Player:SwapWeaponSet()
end
function staff:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( staff )



local dagger_mh = SkillManager:CreateSkillPalette('dagger_mh')
dagger_mh.uid = "Necromancer_Dagger_mh"
dagger_mh.profession = GW2.CHARCLASS.Necromancer
dagger_mh.icon = "Dagger"
-- dagger_mh.id =   --> set a skill ID if you want it to download an icon for this skillset 
dagger_mh.skills_luacode = {
	[10702] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0,
		icon = 'Necrotic Slash',
	},
	[10703] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0,
		icon = 'Necrotic Stab',
		parent = 10702,
	},
	[10704] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.25,
		icon = 'Necrotic Bite',
		parent = 10704,
	},
	[10563] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 3,
		icon = 'Life Siphon',
	},
	[10529] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 1,
		icon = 'Dark Pact',
	},
}
function dagger_mh:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 10563)
end
function dagger_mh:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Dagger or context.player.mainhand_alt == GW2.WEAPONTYPE.Dagger) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function dagger_mh:Activate(context)
	Player:SwapWeaponSet()
end
function dagger_mh:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( dagger_mh )



local dagger_oh = SkillManager:CreateSkillPalette('dagger_oh')
dagger_oh.uid = "Necromancer_Dagger_oh"
dagger_oh.profession = GW2.CHARCLASS.Necromancer
dagger_oh.icon = "Dagger"
-- dagger_oh.id =   --> set a skill ID if you want it to download an icon for this skillset 
dagger_oh.skills_luacode = {
	[10705] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = 'Deathly Swarm',
	},
	[10706] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.75,
		icon = 'Enfeebling Blood',
	},
}
function dagger_oh:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 10705)
end
function dagger_oh:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Dagger or context.player.offhand_alt == GW2.WEAPONTYPE.Dagger) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function dagger_oh:Activate(context)
	Player:SwapWeaponSet()
end
function dagger_oh:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( dagger_oh )



local greatsword = SkillManager:CreateSkillPalette('greatsword')
greatsword.uid = "Necromancer_Greatsword"
greatsword.profession = GW2.CHARCLASS.Necromancer
greatsword.icon = "Greatsword"
-- greatsword.id =   --> set a skill ID if you want it to download an icon for this skillset 
greatsword.skills_luacode = {
	[29705] = {
		 slot = GW2.SKILLBARSLOT.Slot_1,
		 activationtime = 0.75,
		 icon = 'Dusk Strike',
	},
	[30799] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.75,
		icon = 'Fading Twilight',
		parent = 29705,
	},
	[29867] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 1,
		icon = 'Chilling Scythe',
		parent = 30799,
	},
	[30163] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 1.25,
		icon = 'Gravedigger',
	},
	[30860] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 1,
		icon = 'Death Spiral',
	},
	[29855] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = 'Nightfall',
	},
	[29740] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.75,
		icon = 'Grasping Darkness',
	},
}
function greatsword:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 30163)
end
function greatsword:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Greatsword or context.player.mainhand_alt == GW2.WEAPONTYPE.Greatsword) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function greatsword:Activate(context)
	Player:SwapWeaponSet()
end
function greatsword:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( greatsword )



local scepter = SkillManager:CreateSkillPalette('scepter')
scepter.uid = "Necromancer_Scepter"
scepter.profession = GW2.CHARCLASS.Necromancer
scepter.icon = "Scepter"
-- scepter.id =   --> set a skill ID if you want it to download an icon for this skillset 
scepter.skills_luacode = {
	[10698] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Blood Curse',
	},
	[10699] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Rending Curse',
		parent = 10698,
	},
	[10552] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Putrid Curse',
		parent = 10699,
	},
	[10532] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.75,
		icon = 'Grasping Dead',
	},
	[10709] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.75,
		icon = 'Feast of Corruption',
	},
}
function scepter:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 10532)
end
function scepter:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Scepter or context.player.mainhand_alt == GW2.WEAPONTYPE.Scepter) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function scepter:Activate(context)
	Player:SwapWeaponSet()
end
function scepter:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( scepter )


local focus = SkillManager:CreateSkillPalette('focus')
focus.uid = "Necromancer_Focus"
focus.profession = GW2.CHARCLASS.Necromancer
focus.icon = "Focus"
-- focus.id =   --> set a skill ID if you want it to download an icon for this skillset 
focus.skills_luacode = {
	[10707] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.0,
		icon = 'Reapers Touch',
	},
	[10555] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.0,
		icon = 'Spinal Shivers',
	},
}
function focus:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 10707)
end
function focus:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Focus or context.player.offhand_alt == GW2.WEAPONTYPE.Focus) and (context.player.weaponset == 4 or context.player.weaponset == 5) and context.player.transformid == 0
end
function focus:Activate(context)
	Player:SwapWeaponSet()
end
function focus:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( focus )


--[[ TODO: Need scourge training, butload of point things.. not even done with reaper yet... give me time to play!
torch.uid = "torch"
torch.profession = GW2.CHARCLASS.Necromancer
torch.icon = "Torch"
-- torch.id =   --> set a skill ID if you want it to download an icon for this skillset 
torch.skills_luacode = {
	
}
function torch:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 10707)
end
function torch:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.NotInWater and context.player.offhand == GW2.WEAPONTYPE.Torch and context.player.weaponset == 4 and context.player.transformid == 0
end
function torch:Activate(context)
end
function torch:Deactivate(context)
end
SkillManager:AddSkillPalette( torch )
--]]


local trident = SkillManager:CreateSkillPalette('trident')
trident.uid = "Necromancer_Trident"
trident.profession = GW2.CHARCLASS.Necromancer
trident.icon = "Trident"
-- trident.id =   --> set a skill ID if you want it to download an icon for this skillset 
trident.skills_luacode = {
	[10623] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.0,
		icon = 'Crimson Tide',
	},
	[10624] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.0,
		icon = 'Feast',
	},
	[10625] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.0,
		icon = 'Foul Current',
	},
	[10628] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.0,
		icon = 'Sinking Tomb',
	},
	[10629] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.0,
		icon = 'Frozen Abyss',
	},
}
function trident:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 10623)
end
function trident:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.Diving and (context.player.aquatic == GW2.WEAPONTYPE.Trident or context.player.aquatic_alt == GW2.WEAPONTYPE.Trident) and (context.player.weaponset == 0 or context.player.weaponset == 1) and context.player.transformid == 0
end
function trident:Activate(context)
	Player:SwapWeaponSet()
end
function trident:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( trident )


local spear = SkillManager:CreateSkillPalette('spear')
spear.uid = "Necromancer_Spear"
spear.profession = GW2.CHARCLASS.Necromancer
spear.icon = "Spear"
-- spear.id =   --> set a skill ID if you want it to download an icon for this skillset 
spear.skills_luacode = {
	[10692] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Cruel Strike',
	},
	[10693] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.75,
		icon = 'Wicked Strike',
		parent = 10692,
	},
	[10617] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.75,
		icon = 'Reaper\'s Scythe',
		parent = 10693,
	},
	[10694] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 1.75,
		icon = 'Wicked Spiral',
	},
	[10619] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.5,
		icon = 'Deadly Feast',
	},
	[10695] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.75,
		icon = 'Deadly Catch',
	},
	[10616] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.5,
		icon = 'Dark Spear',
	},
}
function spear:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 10692)
end
function spear:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.Diving and (context.player.aquatic == GW2.WEAPONTYPE.Spear or context.player.aquatic_alt == GW2.WEAPONTYPE.Spear) and (context.player.weaponset == 0 or context.player.weaponset == 1) and context.player.transformid == 0
end
function spear:Activate(context)
	Player:SwapWeaponSet()
end
function spear:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( spear )



local reaperShroud = SkillManager:CreateSkillPalette('reaperShroud')
reaperShroud.uid = "Necromancer_ReaperShroud"
reaperShroud.profession = GW2.CHARCLASS.Necromancer
reaperShroud.icon = "Reaper Shroud" -- TODO: this right? ask fx.
reaperShroud.id = 30792 --> set a skill ID if you want it to download an icon for this skillset 
reaperShroud.skills_luacode = {
	-- [30792] = {
		-- slot = GW2.SKILLBARSLOT.Slot_13,
		-- activationtime = 0,
		-- icon = 'Reapers Shroud',
	-- },
	-- [30961] = {
		-- slot = GW2.SKILLBARSLOT.Slot_13,
		-- activationtime = 0,
		-- icon = 'Exit Reapers Shroud',
	-- },
	[29442] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Life Rend',
	},
	[29458] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Life Slash',
		parent = 29442,
	},
	[30278] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = 'Life Reap',
		parent = 29458,
	},
	[30825] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 1.25,
		icon = 'Deaths Charge',
	},
	[29958] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.0,
		icon = 'Infusing Terror',
	},
	[29709] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.5,
		icon = 'Terrify',
	},
	[30504] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 2.75,
		icon = 'Soul Spiral',
	},
	[30557] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 1.25,
		icon = 'Executioners Scythe',
	},
}
function reaperShroud:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 30961)
end
function reaperShroud:CanActivate(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 30792 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast)
end
function reaperShroud:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 30792) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) end
	end
end
function reaperShroud:Deactivate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 30961) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) end
		return true
	end
end
SkillManager:AddSkillPalette( reaperShroud )



local deathShroud = SkillManager:CreateSkillPalette('deathShroud')
deathShroud.uid = "Necromancer_DeathShroud"
deathShroud.profession = GW2.CHARCLASS.Necromancer
deathShroud.icon = "Death Shroud" -- TODO: this right? ask fx.
deathShroud.id = 10574 --> set a skill ID if you want it to download an icon for this skillset 
deathShroud.skills_luacode = {
	-- [10574] = {
		-- slot = GW2.SKILLBARSLOT.Slot_13,
		-- activationtime = 0,
		-- icon = 'Death Shroud',
	-- },
	-- [10585] = {
		-- slot = GW2.SKILLBARSLOT.Slot_13,
		-- activationtime = 0,
		-- icon = 'End Death Shroud',
	-- },
	[18504] = {
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 1,
		icon = 'Dhuumfire',
	},
	[10604] = {
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.75,
		icon = 'Dark Path',
	},
	[10588] = {
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0,
		icon = 'Doom',
	},
	[10594] = {
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 3.5,
		icon = 'Life Transfer',
	},
	[19504] = {
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.25,
		icon = 'Tainted Shackles',
	},
}
function deathShroud:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 10585)
end
function deathShroud:CanActivate(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 10574 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast)
end
function deathShroud:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 10574) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) end
	end
end
function deathShroud:Deactivate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 10585) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) end
		return true
	end
end
SkillManager:AddSkillPalette( deathShroud )



-- ALL the skills which do not belong to a set
local necromancer = SkillManager:CreateSkillPalette('Necromancer')
necromancer.uid = "Necromancer_Necromancer"
necromancer.profession = GW2.CHARCLASS.Necromancer
necromancer.icon = "Necromancer"
necromancer.skills_luacode = {
-- HEALING
	[10547] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 1.5,
		icon = 'Summon Blood Fiend',
	},
	[10548] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 1.25,
		icon = 'Consume Conditions',
	},
	[10527] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 1,
		icon = 'Well of Blood',
	},
	[21762] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 1.25,
		icon = 'Signet of Vampirism',
	},
	[30488] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 0.75,
		icon = '"Your Soul Is Mine!"',
	},
	[12440] = {
		slot = GW2.SKILLBARSLOT.Slot_6,
		activationtime = 1,
		icon = 'Healing Seed',
	},

-- END HEALING.

-- F-Keys.
	
	

-- END F-Keys.

-- ELITE.
	[29414] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0,
		icon = '"You Are All Weaklings!"',
	},
	[30670] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0,
		icon = '"Suffer!"',
	},
	[12453] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Grasping Vines',
	},
	[12456] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.75,
		icon = 'Seed Turret',
	},
	[10689] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.5,
		icon = 'Corrosive Poison Cloud',
	},
	[10606] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 1,
		icon = 'Epidemic',
	},
	[10602] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.5,
		icon = 'Corrupt Boon',
	},
	[10544] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.75,
		icon = 'Blood Is Power',
	},
	[10583] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0,
		icon = 'Spectral Armor',
	},
	[10620] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.5,
		icon = 'Spectral Grasp',
	},
	[10608] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Spectral Wall',
	},
	[10685] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0,
		icon = 'Spectral Walk',
	},
	[10622] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.75,
		icon = 'Signet of Spite',
	},
	[10612] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.75,
		icon = 'Signet of the Locust',
	},
	[10562] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0,
		icon = 'Plague Signet',
	},
	[10611] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 3,
		icon = 'Signet of Undeath',
	},
	[10541] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 1.5,
		icon = 'Summon Bone Minions',
	},
	[10533] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 1.5,
		icon = 'Summon Bone Fiend',
	},
	[10589] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 1.5,
		icon = 'Summon Shadow Fiend',
	},
	[10543] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 1.5,
		icon = 'Summon Flesh Wurm',
	},
	[10546] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Well of Suffering',
	},
	[10545] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Well of Corruption',
	},
	[10609] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Well of Power',
	},
	[10607] = {
		slot = GW2.SKILLBARSLOT.Slot_7,
		activationtime = 0.25,
		icon = 'Well of Darkness',
	},

-- END ELITE.
}
function necromancer:IsActive(context)
	return context.player.transformid == 0
end
function necromancer:CanActivate(context)
	return false
end
function necromancer:Activate(context)
end
function necromancer:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( necromancer )