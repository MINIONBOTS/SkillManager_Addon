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
pistol_mh.weapontype = GW2.WEAPONTYPE.Pistol
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
	Player:SwapWeaponSet() -- should be only "get out of kit"
end
function pistol_mh:Deactivate(context)
	-- not needed here
end
SkillManager:AddSkillPalette( pistol_mh )



local pistol_oh = class('pistol_oh',sm_skillpalette)
pistol_oh.uid = "Pistol_OffHand"
pistol_oh.profession = GW2.CHARCLASS.Engineer
pistol_oh.icon = "Pistol.jpg"
pistol_oh.weapontype = GW2.WEAPONTYPE.Pistol
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
	Player:SwapWeaponSet()-- should be only "get out of kit"
end
function pistol_oh:Deactivate(context)
	
end
SkillManager:AddSkillPalette( pistol_oh )



local rifle = class('rifle',sm_skillpalette)
rifle.uid = "Rifle"
rifle.profession = GW2.CHARCLASS.Engineer
rifle.icon = "Rifle.jpg"
rifle.weapontype = GW2.WEAPONTYPE.Rifle
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
	Player:SwapWeaponSet()-- should be only "get out of kit"
end
function rifle:Deactivate(context)
	
end
SkillManager:AddSkillPalette( rifle )



local shield = class('Shield',sm_skillpalette)
shield.uid = "Shield"
shield.profession = GW2.CHARCLASS.Engineer
shield.icon = "Shield.jpg"
shield.weapontype = GW2.WEAPONTYPE.Shield
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
	Player:SwapWeaponSet()-- should be only "get out of kit"
end
function shield:Deactivate(context)
	
end
SkillManager:AddSkillPalette( shield )



local shield = class('Harpoongun',sm_skillpalette)
shield.uid = "Harpoongun"
shield.profession = GW2.CHARCLASS.Engineer
shield.icon = "Harpoongun.jpg"
shield.weapontype = GW2.WEAPONTYPE.HarpoonGun
shield.skills_luacode = {
	[6148] = { 
		slot = GW2.SKILLBARSLOT.Slot_1,
		activationtime = 1,
		icon = "Homing Torpedo",		
	},
	[5941] = { 
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
	[5879] = { 
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
	Player:SwapWeaponSet()-- should be only "get out of kit"
end
function shield:Deactivate(context)
	
end
SkillManager:AddSkillPalette( shield )
