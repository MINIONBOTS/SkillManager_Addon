-- Hardcoded Skill Palettes for the Engineer Profession.
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

local pistol_mh = class('pistol_mh',sm_skillpalette)
pistol_mh.uid = "Pistol_Mainhand"
pistol_mh.profession = GW2.CHARCLASS.Engineer
pistol_mh.icon = "Pistol.jpg"
pistol_mh.skills_luacode = {
	[5827] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = "Fragmentation Shot",		
	},
	[5828] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 1.75,
		icon = "Poison Dart Volley",		
	},
	[5829] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0,
		icon = "Static Shot",		
	},
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
function pistol_mh:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 5827)	
end
function pistol_mh:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.NotInWater and context.player.mainhand == GW2.WEAPONTYPE.Pistol and context.player.weaponset == 2 and context.player.transformid == 0 -- we have a pistol and a kit currently equipped
end
function pistol_mh:Activate(context)
end
function pistol_mh:Deactivate(context)
end
SkillManager:AddSkillPalette( pistol_mh )



local pistol_oh = class('pistol_oh',sm_skillpalette)
pistol_oh.uid = "Pistol_OffHand"
pistol_oh.profession = GW2.CHARCLASS.Engineer
pistol_oh.icon = "Pistol.jpg"
pistol_oh.skills_luacode = {
	[5831] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = "Blowtorch",		
	},
	[5830] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.5,
		icon = "Glue Shot",		
	},
}
function pistol_oh:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 5831)	
end
function pistol_oh:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.NotInWater and context.player.offhand == GW2.WEAPONTYPE.Pistol and context.player.weaponset == 2 and context.player.transformid == 0 -- we have a pistol and a kit currently equipped
end
function pistol_oh:Activate(context)
end
function pistol_oh:Deactivate(context)
	
end
SkillManager:AddSkillPalette( pistol_oh )



local rifle = class('rifle',sm_skillpalette)
rifle.uid = "Rifle"
rifle.profession = GW2.CHARCLASS.Engineer
rifle.icon = "Rifle.jpg"
rifle.skills_luacode = {
	[6003] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.75,
		icon = "Hip Shot",		
	},
	[6004] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.5,
		icon = "Net Shot",		
	},
	[6153] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.5,
		icon = "Blunderbuss",		
	},
	[6154] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 1.0,
		icon = "Overcharged Shot",		
	},
	[6005] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 1.0,
		icon = "Jump Shot",		
	},
}
function rifle:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 6003)	
end
function rifle:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.NotInWater and context.player.mainhand == GW2.WEAPONTYPE.Rifle and context.player.weaponset == 2 and context.player.transformid == 0 -- we have a pistol and a kit currently equipped
end
function rifle:Activate(context)
end
function rifle:Deactivate(context)
	
end
SkillManager:AddSkillPalette( rifle )



local shield = class('Shield',sm_skillpalette)
shield.uid = "Shield"
shield.profession = GW2.CHARCLASS.Engineer
shield.icon = "Shield.jpg"
shield.skills_luacode = {
	[6053] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 3.0,
		icon = "Magnetic Shield",		
	},
	[6126] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = "Magnetic Inversion",		
	},
	[6054] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 2.0,
		icon = "Static Shield",		
	},
	[6057] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.75,
		icon = "Throw Shield",		
	},
}
function shield:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil and (context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 6053 or context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 6126))	
end
function shield:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.NotInWater and context.player.offhand == GW2.WEAPONTYPE.Shield and context.player.weaponset == 2 and context.player.transformid == 0 -- we have a pistol and a kit currently equipped
end
function shield:Activate(context)
end
function shield:Deactivate(context)
	
end
SkillManager:AddSkillPalette( shield )



local shield = class('Harpoongun',sm_skillpalette)
shield.uid = "Harpoongun"
shield.profession = GW2.CHARCLASS.Engineer
shield.icon = "Harpoongun.jpg"
shield.skills_luacode = {
	[6148] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 1,
		icon = "Homing Torpedo",		
	},
	[6147] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.25,
		icon = "Scatter Mines",		
	},
	[6073] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0,
		icon = "Detonate Mines",		
	},
	[6146] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.5,
		icon = "Retreating Grapple",		
	},
	[6149] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.25,
		icon = "Timed Charge",		
	},
	[6145] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.25,
		icon = "Net Wall",		
	},
	[6074] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0,
		icon = "Deploy Net Wall",		
	},
}
function shield:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 6148)	
end
function shield:CanActivate(context)
	return context.player.swimming == GW2.SWIMSTATE.Diving and context.player.aquatic == GW2.WEAPONTYPE.HarpoonGun and context.player.weaponset == 2 and context.player.transformid == 0 -- we have a pistol and a kit currently equipped
end
function shield:Activate(context)
end
function shield:Deactivate(context)	
end
SkillManager:AddSkillPalette( shield )


local downed = class('Downed',sm_skillpalette)
downed.uid = "Downed"
downed.profession = GW2.CHARCLASS.Engineer
downed.icon = "Bandage.jpg"
downed.skills_luacode = {
	[5820] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0,
		icon = "Throw Junk",		
	},
	[5962] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0,
		icon = "Grappling Line",		
	},
	[5963] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0,
		icon = "Booby Trap",		
	},
	[1175] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0,
		icon = "Bandage",		
	},
}
function downed:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 5820)	
end
function downed:CanActivate(context)
	return false
end
function downed:Activate(context)
end
function downed:Deactivate(context)	
end
SkillManager:AddSkillPalette( downed )


local drowning = class('Drowning',sm_skillpalette)
drowning.uid = "Drowning"
drowning.profession = GW2.CHARCLASS.Engineer
drowning.icon = "Anchor.jpg"
drowning.skills_luacode = {
	[5916] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0,
		icon = "Floating Mine",		
	},
	[5917] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0,
		icon = "Anchor",		
	},
	[5918] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 3.0,
		icon = "Buoy",		
	},
	[1175] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0,
		icon = "Bandage",		
	},
}
function drowning:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 5916)	
end
function drowning:CanActivate(context)
	return false
end
function drowning:Activate(context)
end
function drowning:Deactivate(context)	
end
SkillManager:AddSkillPalette( drowning )


local bombkit = class('BombKit',sm_skillpalette)
bombkit.uid = "BombKit"
bombkit.profession = GW2.CHARCLASS.Engineer
bombkit.icon = "Bomb Kit.jpg"
bombkit.id = 5812
bombkit.skills_luacode = {
	[5084] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 0.5,
		icon = "Bomb",		
	},
	[5823] = { 
		slot = GW2.SKILLBARSLOT.Slot_2,
		activationtime = 0.5,
		icon = "Fire Bomb",		
	},
	[5822] = { 
		slot = GW2.SKILLBARSLOT.Slot_3,
		activationtime = 0.5,
		icon = "Concussion Bomb",		
	},
	[5824] = { 
		slot = GW2.SKILLBARSLOT.Slot_4,
		activationtime = 0.5,
		icon = "Smoke Bomb",		
	},
	[5939] = { 
		slot = GW2.SKILLBARSLOT.Slot_5,
		activationtime = 0.5,
		icon = "Glue Bomb",		
	},
}
function bombkit:IsActive(context)
	return context.skillbar~=nil  and (
	(context.skillbar[GW2.SKILLBARSLOT.Slot_7]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_7].id == 5084) ||
	(context.skillbar[GW2.SKILLBARSLOT.Slot_8]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_8].id == 5084) ||
	(context.skillbar[GW2.SKILLBARSLOT.Slot_9]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_9].id == 5084))
end
function bombkit:CanActivate(context)
	return context.player.transformid == and context.skillbar~=nil  and (
	(context.skillbar[GW2.SKILLBARSLOT.Slot_7]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_7].id == 5812) ||
	(context.skillbar[GW2.SKILLBARSLOT.Slot_8]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_8].id == 5812) ||
	(context.skillbar[GW2.SKILLBARSLOT.Slot_9]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_9].id == 5812))
end
function bombkit:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_7]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_7].id == 5812) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_7) end
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_8]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_8].id == 5812) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_8) end
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_9]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_9].id == 5812) then Player:CastSpell(GW2.SKILLBARSLOT.Slot_9) end
	end
end
function bombkit:Deactivate(context)
	Player:SwapWeaponSet()
end
SkillManager:AddSkillPalette( bombkit )
