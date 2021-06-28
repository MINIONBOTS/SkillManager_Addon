local set = SkillManager:CreateSkillPalette('Ranger Pet Skills')
set.uid = "Ranger Pet Skills"
set.profession = GW2.CHARCLASS.Ranger
set.icon = "Ranger"
set.skills_luacode = {
	[31367] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Spike Barrage',
		activationtime = 2
	},				
			
	[12729] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Paralyzing Venom',
		activationtime = 0
	},				
			
	[12713] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Protecting Screech',
		activationtime = 1
	},				
			
	[16426] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Sonic Shriek',
		activationtime = 1.5
	},				
			
	[12723] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Blinding Slash',
		activationtime = 0.5
	},				
			
	[12712] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Furious Screech',
		activationtime = 1
	},				
			
	[12722] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Lacerating Slash',
		activationtime = 0.5
	},				
			
	[12711] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Icy Screech',
		activationtime = 1
	},				
			
	[42180] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Blinding Roar',
		activationtime = 1.5
	},				
			
	[12721] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Chilling Slash',
		activationtime = 0.5
	},				
			
	[12709] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Dazing Screech',
		activationtime = 1
	},				
			
	[12718] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Howl of the Pack',
		activationtime = 1.5
	},				
			
	[12708] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Dazing Screech',
		activationtime = 1
	},				
			
	[12717] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Regenerate',
		activationtime = 1.5
	},				
			
	[31568] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Smoke Cloud',
		activationtime = 0.75
	},				
			
	[12716] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Chilling Howl',
		activationtime = 1.5
	},				
			
	[12703] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Regenerate',
		activationtime = 0
	},				
			
	[12702] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poison Cloud',
		activationtime = 0
	},				
			
	[31451] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Furious Pounce',
		activationtime = 1.5
	},				
			
	[12701] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Insect Swarm',
		activationtime = 1.5
	},				
			
	[12700] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poison Cloud',
		activationtime = 0
	},				
			
	[12699] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Electrocute',
		activationtime = 0
	},				
			
	[44980] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Jacarandas Embrace',
		activationtime = 1
	},				
			
	[12689] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Icy Maul',
		activationtime = 0
	},				
			
	[42963] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Savannah Strike',
		activationtime = 0.75
	},				
			
	[12698] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Lightning Breath',
		activationtime = 1.5
	},				
			
	[12688] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Enfeebling Maul',
		activationtime = 1.5
	},				
			
	[31459] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Consuming Flame',
		activationtime = 2.5
	},				
			
	[12697] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Frost Nova',
		activationtime = 0
	},				
			
	[12687] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poison Cloud',
		activationtime = 1.25
	},				
			
	[12696] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Frost Breath',
		activationtime = 1.5
	},				
			
	[12681] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Stalk',
		activationtime = 0
	},				
			
	[12695] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Boil',
		activationtime = 0
	},				
			
	[12680] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Rending Pounce',
		activationtime = 1.5
	},				
			
	[16427] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Sonic Barrier',
		activationtime = 0
	},				
			
	[12693] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Icy Pounce',
		activationtime = 1.5
	},				
			
	[12679] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Rending Barbs',
		activationtime = 4
	},				
			
	[12691] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Purge Conditions',
		activationtime = 0
	},				
			
	[12675] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poisonous Cloud',
		activationtime = 1
	},				
			
	[41156] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Fang Grapple',
		activationtime = 1
	},				
			
	[12690] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poisonous Maul',
		activationtime = 1.5
	},				
			
	[12674] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Poison Barbs',
		activationtime = 2.5
	},				
			
	[12670] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Fire Breath',
		activationtime = 1.5
	},				
			
	[12667] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Icy Roar',
		activationtime = 1.25
	},				
			
	[31639] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Lightning Assault',
		activationtime = 0
	},				
			
	[12757] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Feeding Frenzy',
		activationtime = 0
	},				
			
	[12664] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Rending Maul',
		activationtime = 1.75
	},				
			
	[20975] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Lacerating Slash',
		activationtime = 0.5
	},				
			
	[12756] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Forage',
		activationtime = 1
	},				
			
	[12658] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Mighty Roar',
		activationtime = 3
	},				
			
	[12755] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Forage',
		activationtime = 1
	},				
			
	[12656] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Icy Bite',
		activationtime = 0.25
	},				
			
	[12754] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Forage',
		activationtime = 1
	},				
			
	[43636] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Head Toss',
		activationtime = 0.75
	},				
			
	[12749] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Immobilizing Whirl',
		activationtime = 2.75
	},				
			
	[12748] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Chilling Whirl',
		activationtime = 2.75
	},				
			
	[12685] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Enfeebling Roar',
		activationtime = 1.25
	},				
			
	[12744] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Stunning Rush',
		activationtime = 2.75
	},				
			
	[12732] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Forage',
		activationtime = 1
	},				
			
	[12731] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Deadly Venom',
		activationtime = 0
	},				
			
	[12715] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Intimidating Howl',
		activationtime = 1.5
	},				
			
	[12730] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Weakening Venom',
		activationtime = 0
	},				
			
	[12704] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Lashtail Venom',
		activationtime = 0
	},				
			
	[12666] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Shake It Off',
		activationtime = 0.5
	},				
			
	[12714] = { 
		slot = GW2.SKILLBARSLOT.Slot_12, 
		icon = 'Terrifying Howl',
		activationtime = 1.5
	},
}
function set:IsActive(context)

	if(context.skillbar ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_12] ~= nil) then
		local skillslot = context.skillbar[GW2.SKILLBARSLOT.Slot_12]
		
		if(skillslot.id and self.skills_luacode[skillslot.id] ~= nil) then
			return true
		end
	end
	
	return false
end

function set:CanCast(context,skillid)
	if(context.skillbar ~= nil and context.skillbar[GW2.SKILLBARSLOT.Slot_12] ~= nil) then
		local skillslot = context.skillbar[GW2.SKILLBARSLOT.Slot_12]
		if(skillslot.id == skillid) then
			return true
		end
	end
	
	return false
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

local set = SkillManager:CreateSkillPalette('Ranger Pet Skills Misc')
set.uid = "Ranger Pet Skills Misc"
set.profession = GW2.CHARCLASS.Ranger
set.icon = "Ranger"
--set.iconurl = ""
-- set.id = 
set.skills_luacode = {
	 [30] = {
		 slot = 555, 
		 activationtime = 250, 
		 icon = 'Swap Pet',
		 name = 'Swap Pet'
	 },
}
function set:IsActive(context)
	return context.player.pet and Player:CanSwitchPet()
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