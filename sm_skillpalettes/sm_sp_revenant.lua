
local set = SkillManager:CreateSkillPalette('Hammer')
set.uid = "Revenant_Hammer"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Hammer"
set.skills_luacode = {
[28549] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 1.0, 
	 icon = 'Hammer Bolt',  
 },
 [28253] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 0.75, 
	 icon = 'Coalescence of Ruin',  
 },
 [27976] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 1.25, 
	 icon = 'Phase Smash',  
 },
 [27665] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.75, 
	 icon = 'Field of the Mists',  
 },
 [28110] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 1.75, 
	 icon = 'Drop the Hammer',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 28253)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Hammer or context.player.mainhand_alt == GW2.WEAPONTYPE.Hammer) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Staff')
set.uid = "Revenant_Staff"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Staff"
set.skills_luacode = {
[29180] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Rapid Swipe',  
 },
 [29331] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Forceful Bash',
	 parent = 29180,
 },
 [29002] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime =1.0,
	 icon = 'Rejuvenating Assault',
	 parent = 29331,
 },
 [29145] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 0.75, 
	 icon = 'Punishing Sweep',  
 },
 [29288] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 1.5, 
	 icon = 'Warding Rift',  
 },
 [29321] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 1.0, 
	 icon = 'Renewing Wave',  
 },
 [28978] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 1.0, 
	 icon = 'Surge of the Mists',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_3]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_3].id == 29288)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Staff or context.player.mainhand_alt == GW2.WEAPONTYPE.Staff) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )




local set = SkillManager:CreateSkillPalette('Sword')
set.uid = "Revenant_Sword_Mainhand"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Sword"
set.skills_luacode = {
 [29057] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Preparation Thrust',  
 },
 [29256] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.75, 
	 icon = 'Brutal Blade',
	 parent = 29057,
 },
 [28964] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Rift Slash',
	 parent = 29256,
 },
 [29233] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 0.5, 
	 icon = 'Precision Strike',  
 },
 [26699] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.75, 
	 icon = 'Unrelenting Assault',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_2].id == 29233)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Sword or context.player.mainhand_alt == GW2.WEAPONTYPE.Sword) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Sword')
set.uid = "Revenant_Sword_Offhand"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Sword"
set.skills_luacode = {
 [28571] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 2.25, 
	 icon = 'Duelists Preparation',  
 },
  [28472] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.5, 
	 icon = 'Shackling Wave',
	 parent = 28571,
 },
 [27074] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 0.5, 
	 icon = 'Grasping Shadow',  
 },
}
function set:IsActive(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_5]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 27074
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Sword or context.player.offhand_alt == GW2.WEAPONTYPE.Sword) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Mace')
set.uid = "Revenant_Mace_Mainhand"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Mace"
set.skills_luacode = {
[27066] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Misery Swipe',  
 },
 [26730] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Anguish Swipe',
	 parent = 27066,
 },
 [26666] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Manifest Toxin',
	 parent = 26730,
 },
 [28357] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 0.5, 
	 icon = 'Searing Fissure',  
 },
 [27964] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.5, 
	 icon = 'Echoing Eruption',  
 },

}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_3]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_3].id == 27964)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Mace or context.player.mainhand_alt == GW2.WEAPONTYPE.Mace) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )



local set = SkillManager:CreateSkillPalette('Axe')
set.uid = "Revenant_Axe_Offhand"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Axe"
set.skills_luacode = {
 [28029] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.5, 
	 icon = 'Frigid Blitz',  
 },
 [28409] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 0.5, 
	 icon = 'Temporal Rift',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 28029)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Axe or context.player.offhand_alt == GW2.WEAPONTYPE.Axe) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )



local set = SkillManager:CreateSkillPalette('Shield')
set.uid = "Revenant_Shield"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Shield"
set.skills_luacode = {
 [29386] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.75, 
	 icon = 'Envoy of Exuberance',  
 },
 [28262] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 3.0, 
	 icon = 'Crystal Hibernation',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_4].id == 29386)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.offhand == GW2.WEAPONTYPE.Shield or context.player.offhand_alt == GW2.WEAPONTYPE.Shield) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Shortbow')
set.uid = "Revenant_Shortbow"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Shortbow"
set.skills_luacode = {
[40497] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Shattershot',  
 },
 [40175] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 1.0, 
	 icon = 'Bloodbane Path',  
 },
 [41829] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.75, 
	 icon = 'Sevenshot',  
 },
 [43993] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.75, 
	 icon = 'Spiritcrush',  
 },
 [41820] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 0.75, 
	 icon = 'Scorchrazor',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 40497)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.NotInWater and (context.player.mainhand == GW2.WEAPONTYPE.Shortbow or context.player.mainhand_alt == GW2.WEAPONTYPE.Shortbow) and (context.player.weaponset == 4 or context.player.weaponset == 5) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )



local set = SkillManager:CreateSkillPalette('Spear')
set.uid = "Revenant_Spear"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Spear"
set.skills_luacode = {
[28714] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.5, 
	 icon = 'Spear of Anguish',  
 },
 [28915] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 1.25, 
	 icon = 'Rapid Assault',  
 },
 [28827] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.75, 
	 icon = 'Venomous Sphere',  
 },
  [28797] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.5, 
	 icon = 'Frigid Discharge',
	 instantcast = true,
	 parent = 28827,	 
 },
 [28692] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.5, 
	 icon = 'Igniting Brand',  
 },
  [28815] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 0.5, 
	 icon = 'Devour Brand',
	 parent = 28692,
 },
 [28930] = { 
	 slot = GW2.SKILLBARSLOT.Slot_5, 
	 activationtime = 0.5, 
	 icon = 'Rift Containment',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 28714)	
end
function set:CanActivate(context)
	return context.player.canswapweaponset and context.player.swimming == GW2.SWIMSTATE.Diving and (context.player.aquatic == GW2.WEAPONTYPE.Spear or context.player.aquatic_alt == GW2.WEAPONTYPE.Spear) and (context.player.weaponset == 0 or context.player.weaponset == 1) and (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:Activate(context)
	Player:SwapWeaponSet()
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )


local downed = SkillManager:CreateSkillPalette('Downed')
downed.uid = "Revenant_Downed"
downed.profession = GW2.CHARCLASS.Revenant
downed.icon = "Bandage"
downed.skills_luacode = {
[28180] = { 
	 slot = GW2.SKILLBARSLOT.Slot_1, 
	 activationtime = 0.25, 
	 icon = 'Essence Sap',  
 },
 [27063] = { 
	 slot = GW2.SKILLBARSLOT.Slot_2, 
	 activationtime = 0.75, 
	 icon = 'Forceful Displacement',  
 },
 [27792] = { 
	 slot = GW2.SKILLBARSLOT.Slot_3, 
	 activationtime = 0.5, 
	 icon = 'Vengeful Blast',  
 },
 [1175] = { 
	 slot = GW2.SKILLBARSLOT.Slot_4, 
	 activationtime = 1.5, 
	 icon = 'Bandage',  
 },
}
function downed:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_1]~=nil and context.skillbar[GW2.SKILLBARSLOT.Slot_1].id == 28180)	
end
function downed:CanActivate(context)
	return false
end
function downed:Activate(context)
end
function downed:Deactivate(context)	
	return false
end
SkillManager:AddSkillPalette( downed )



local set = SkillManager:CreateSkillPalette('Dwarf Stance')
set.uid = "Dwarf Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Dwarf Stance"
set.id = 26650
set.skills_luacode = {
[27372] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 1.0, 
	 icon = 'Soothing Stone',  
 },
 [28516] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.25, 
	 icon = 'Inspiring Reinforcement',  
 },
 [26679] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.5, 
	 icon = 'Forced Engagement',  
 },
 [26557] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.5, 
	 icon = 'Vengeful Hammers',
	 instantcast = true,
 },
  [26956] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.0, 
	 icon = 'Release Hammers',
	 instantcast = true,
	 parent = 26557,	 
 },
 [27975] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 1.25, 
	 icon = 'Rite of the Great Dwarf',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 26650)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 26650 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 26650) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )



local set = SkillManager:CreateSkillPalette('Centaur Stance')
set.uid = "Centaur Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Centaur Stance"
set.id = 28141
set.skills_luacode = {
[28427] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.5, 
	 icon = 'Ventaris Will',  
	 instantcast = true,
 },
 [26821] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Protective Solace',
	 instantcast = true,
 },
  [27628] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Diminish Solace',
	 parent = 26821,
	 instantcast = true,
 },
 [27025] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.5, 
	 icon = 'Natural Harmony',  
	 instantcast = true,
 },
 [27715] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.5, 
	 icon = 'Purifying Essence',  
	 instantcast = true,
 },
 [27356] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.5, 
	 icon = 'Energy Expulsion',  
	 instantcast = true,
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 28141)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28141 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28141) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Demon Stance')
set.uid = "Demon Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Demon Stance"
set.id = 28376
set.skills_luacode = {
[28219] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.75, 
	 icon = 'Empowering Misery',  
 },
 [27322] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Pain Absorption',  
 },
 [27505] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.5, 
	 icon = 'Banish Enchantment',  
 },
 [27917] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.75, 
	 icon = 'Unyielding Anguish',  
 },
 [28287] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.75, 
	 icon = 'Embrace the Darkness',  
 },
  [26693] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.5, 
	 icon = 'Resist the Darkness',
	 instantcast = true,
	 parent = 28287,
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 28376)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28376 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28376) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Assassin Stance')
set.uid = "Assassin Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Assassin Stance"
set.id = 27659
set.skills_luacode = {
[26937] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.5, 
	 icon = 'Enchanted Daggers',  
 },
 [29209] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Riposting Shadows', 
	 instantcast = true,
 },
 [28231] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.5, 
	 icon = 'Phase Traversal',  
 },
 [27107] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.5, 
	 icon = 'Impossible Odds',
	 instantcast = true,
 },
  [28382] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.5, 
	 icon = 'Relinquish Power', 
	 instantcast = true,
	 parent = 27107,
 },
 [28406] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 1.0, 
	 icon = 'Jade Winds',  
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 27659)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 27659 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 27659) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Dragon Stance')
set.uid = "Dragon Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Dragon Stance"
set.id = 28085
set.skills_luacode = {
[27220] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.5, 
	 icon = 'Facet of Light', 
	 nounderwater = true,
 },
  [27228] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.5, 
	 icon = 'Infuse Light', 
	 parent = 27220,
	 instantcast = true,
 },
 [28379] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Facet of Darkness',  
	 nounderwater = true,
	 instantcast = true,
 },
  [27080] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.5, 
	 icon = 'Gaze of Darkness',  
	 parent = 28379,
	 instantcast = true,
 },
 [27014] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.5, 
	 icon = 'Facet of Elements',  
	 nounderwater = true,
	 instantcast = true,
 },
  [27162] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.25, 
	 icon = 'Elemental Blast',  
	 parent = 27014,
 },
 [26644] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.5, 
	 icon = 'Facet of Strength',  
	 nounderwater = true,
	 instantcast = true,
 },
  [28113] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 1.0, 
	 icon = 'Burst of Strength',  
	 parent = 26644,
 },
 [27760] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.5, 
	 icon = 'Facet of Chaos',  
	 nounderwater = true,
	 instantcast = true,
 },
  [28075] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 1.25, 
	 icon = 'Chaotic Release',
	 parent = 27760
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 28085)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28085 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 28085) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )


local set = SkillManager:CreateSkillPalette('Renegade Stance')
set.uid = "Renegade Stance"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Legendary Renegade Stance"
set.id = 46409
set.skills_luacode = {
[45686] = { 
	 slot = GW2.SKILLBARSLOT.Slot_6, 
	 activationtime = 0.75, 
	 icon = 'Breakrazors Bastion', 
	 nounderwater = true,
 },
 [42949] = { 
	 slot = GW2.SKILLBARSLOT.Slot_7, 
	 activationtime = 0.75, 
	 icon = 'Razorclaws Rage', 
	 nounderwater = true,	 
 },
 [40485] = { 
	 slot = GW2.SKILLBARSLOT.Slot_8, 
	 activationtime = 0.75, 
	 icon = 'Icerazors Ire',  
	 nounderwater = true,
 },
 [41220] = { 
	 slot = GW2.SKILLBARSLOT.Slot_9, 
	 activationtime = 0.75, 
	 icon = 'Darkrazors Daring',  
	 nounderwater = true,
 },
 [45773] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.75, 
	 icon = 'Soulcleaves Summit',  
	 nounderwater = true,
 },
  [42752] = { 
	 slot = GW2.SKILLBARSLOT.Slot_10, 
	 activationtime = 0.5, 
	 icon = 'Dismiss Lieutenant Soulcleave',  
	 instantcast = true,
 },
}
function set:IsActive(context)
	return (context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_17].id == 46409)
end
function set:CanActivate(context)
	return context.skillbar~=nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil  and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 46409 and context.skillbar[GW2.SKILLBARSLOT.Slot_13].cancast and (not context.stoopidrevenant or ml_global_information.Now - context.stoopidrevenant > 10000)
end
function set:Activate(context)
	if ( context.skillbar~=nil ) then
		if (context.skillbar[GW2.SKILLBARSLOT.Slot_13] ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_13].id == 46409) then 
			if ( Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) ) then
				context.stoopidrevenant  = ml_global_information.Now
			end
		end
	end
end
function set:Deactivate(context)
end
SkillManager:AddSkillPalette( set )


-- ALL the skills which do not belong to a set
local set = SkillManager:CreateSkillPalette('Revenant')
set.uid = "Revenant"
set.profession = GW2.CHARCLASS.Revenant
set.icon = "Revenant"
set.skills_luacode = {
 [29393] = { 
	 slot = GW2.SKILLBARSLOT.Slot_14, 
	 activationtime = 0.5, 
	 icon = 'One with Nature',  
 },
 [29371] = { 
	 slot = GW2.SKILLBARSLOT.Slot_14, 
	 activationtime = 0.5, 
	 icon = 'Facet of Nature',
	 instantcast = true
 },
 [44076] = { 
	 slot = GW2.SKILLBARSLOT.Slot_14, 
	 activationtime = 0.75, 
	 icon = 'Heroic Command',  
 },
 [42836] = { 
	 slot = GW2.SKILLBARSLOT.Slot_15, 
	 activationtime = 0.75, 
	 icon = 'Citadel Bombardment',  
 },
 [45537] = { 
	 slot = GW2.SKILLBARSLOT.Slot_16, 
	 activationtime = 0.5, 
	 icon = 'Orders from Above',
	 instantcast = true,
 },
}
function set:IsActive(context)
	return (context.player.transformid >= 13 or context.player.transformid <= 18)
end
function set:CanActivate(context)
	return false
end
function set:Activate(context)
end
function set:Deactivate(context)
	return false
end
SkillManager:AddSkillPalette( set )
