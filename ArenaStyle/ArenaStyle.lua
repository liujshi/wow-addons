-- Arena Style for compact raid frame more buffs and debuffs, and show debuffs outside of the unit frame


-- Initialized database defaults
local defaults = {enable = true, buffnum = 6, debuffnum = 10, max = 5, cc = true, dir = "right"}

ArenaStyleDB = ArenaStyleDB or defaults
ArenaStyle = CreateFrame("Frame")
ArenaStyle.cache = {}

-- default buff number
local DEFAULT_BUFF = 3

-- default debuff number
local DEFAULT_DEBUFF = 3

local function log(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffCD32CDArenaStyle:|r " .. msg) end

-- function ArenaStyle:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
-- 	self[event](self, ...) -- route event parameters to LoseControl:event methods
-- end
ArenaStyle:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
function ArenaStyle:ADDON_LOADED()
	-- Initialize the db
	if not self.db then
		--print("ADDON_LOADED")
		self.db = ArenaStyleDB
		for k,v in pairs(defaults) do 
			if self.db[k] == nil then self.db[k] = defaults[k] end
		end
		-- Initialize command table
		SlashCmdList["ArenaStyle"] = function(msg) self:Command(msg, tbl) end
		SLASH_ArenaStyle1 = "/as"
		SLASH_ArenaStyle2 = "/ArenaStyle"
		log("type /as to config ArenaStyle.")
		-- Register event
		--self:RegisterEvent("RAID_ROSTER_UPDATE")
		--self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		--self:RegisterEvent("UNIT_PET")
		--CompactRaidFrameContainer:HookScript("OnEvent", ArenaStyle.OnRosterUpdate)
		CompactRaidFrameContainer:HookScript("OnHide", ArenaStyle.ResetStyle)
		--CompactRaidFrameContainer:HookScript("OnShow", ArenaStyle.OnRosterUpdate)
	end
end

-- Command table
function ArenaStyle:Command(msg , tbl)
	local cmdtbl = tbl or 
	{
		["buff"] = function(arg)
			if tonumber(arg) and tonumber(arg) >= DEFAULT_BUFF then 
				self.db.buffnum = tonumber(arg) 
				log("buff number set to be "..self.db.buffnum) 
				self:ResetStyle() 
				self:OnRosterUpdate()
			else 
				log("invalid input(must be numbers and over 3)") 
			end
		end,
		["debuff"] = function(arg) 
			if tonumber(arg) and tonumber(arg) >= DEFAULT_DEBUFF then 
				self.db.debuffnum = tonumber(arg) 
				log("debuff number set to be "..self.db.debuffnum)
				self:ResetStyle() 
				self:OnRosterUpdate()
			else
				log("invalid input(must be numbers and over 3)") 
			end
		end,
		["max"] = function(arg) 
			if tonumber(arg) and tonumber(arg) >= 0 then 
				self.db.max = tonumber(arg) 
				log("the maximum number to apply arena style set to be "..self.db.max) 
				self:OnRosterUpdate() 
			else 
				log("invalid input(must be numbers and non-negative)") 
			end 
		end,
		["off"] = function() 
			self.db.enable = false
			log("set to be disabled") 
			self:ResetStyle()
		end,
		["on"] = function() 
			self.db.enable = true
			log("set to be enabled") 
			self:OnRosterUpdate()
		end,
		["cc"] = function()
			self.db.cc = not self.db.cc
			if self.db.cc then
				log("display cc first")
			else
				log("doesn't display cc first")
			end
		end,
		["left"] = function()
			self.db.left = not self.db.left
			if self.db.left then
				log("display debuffs on left")
			else
				log("display debuffs on right")
			end
			self:ResetStyle() 
			self:OnRosterUpdate()
		end,
		--["apply"] = function() self:ApplyStyle() log("arena style applied") end,
		["status"] = function() log ("addon[".. (self.db.enable and "on]" or "off]").."  buff["..self.db.buffnum.."]".."  debuff["..self.db.debuffnum.."]".."  cc["..(self.db.enable and "on]" or "off]").."  max["..self.db.max.."]".."  position["..(self.db.left and "left" or "right").."]") end,
		--["reset"] = function() self:ResetStyle() log("reset to default style") end,
		--["reset"] = function() ArenaStyleDB = {}; log("reset ArenaStyle's database") end,
 		["help"] = function() log("\n'/as debuff [number]' to set debuff number\n'/as buff [number]' to set buff number\n'/as cc' to display cc first\n'/as max [number]' to set the maximum number of party or raid members to auto apply arena style\n'/as [on/off]' to enable or disable the addon\n'/as left' to display debuffs on left or right") end,
		-- \n'/as status' to see the status\n'/as reset' to reset database(works after reloading)
	}
	local cmd, arg = string.split(" ", msg, 2)
	local entry = cmdtbl[cmd:lower()]
	local which = type(entry)
	if which == "function" then
		entry(arg)
	elseif which == "table" then
		self:Command(arg or "" , entry)
	else
		self:Command("help")
	end
end
--[[function CompactRaidFrameContainer_OnEvent(self, event, ...)
    if ( event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" ) then
        CompactRaidFrameContainer_UpdateDisplayedUnits(self);
        CompactRaidFrameContainer_TryUpdate(self);
    elseif ( event == "UNIT_PET" ) then
        if ( self.displayPets ) then
            local unit = ...;
            if ( unit == "player" or strsub(unit, 1, 4) == "raid" or strsub(unit, 1, 5) == "party" ) then
                CompactRaidFrameContainer_TryUpdate(self);
            end
        end
    end
end]]
-- When roster updated, auto apply arena style or reset style
function ArenaStyle:PLAYER_ENTERING_WORLD()
	local _,areaType = IsInInstance()
	--self.cache={}
	--print(areaType.."140")
	if areaType == "party" then ArenaStyle:ResetStyle() return end
	if not ArenaStyle.db.enable then return end
	--if not CompactRaidFrameContainer:IsVisible() then return end
	--local n = GetNumGroupMembers()
end

-- Apply arena style to the compact raid frame
function ArenaStyle:ApplyStyle(f)
	if CompactRaidFrameManager.container.groupMode == "flush" then
		--print(CompactRaidFrameManager.container.groupMode.."wwwww",f.unit)
		if f  and f.inUse and not self.cache[f] and f.maxBuffs ~= 0  and f.unit and not strfind(f.unit,"pet") and not strfind(f.unit,"target") then
			--print("ApplyFrame")
			self:ApplyFrame(f)
			self:UNIT_AURA(f.unit)
			self:AdjustPosition()
		end
		if f and not f.inUse and self.cache[f] then
			--print("ResetFrame")
				self:ResetFrame(f)
		end
	elseif CompactRaidFrameManager.container.groupMode == "discrete" then
		if f and not self.cache[f] and f.maxBuffs ~= 0 and #f.buffFrames == DEFAULT_BUFF and f.unit and not strfind(f.unit,"pet") and not strfind(f.unit,"target") then
			self:ApplyFrame(f)
			self:UNIT_AURA(f.unit)
		end
		if f and not f.unit and self.cache[f] then
			self:ResetFrame(f)
		end	
	end
end

function ArenaStyle:AdjustPosition()
	for f,v in pairs(self.cache) do
		for j = 1, self.db.buffnum do
			--print("buffnum"..j)
			if j == 1 then
				v.buffFrames[j]:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,-1)
			end
		end

		for j = 1,self.db.debuffnum do
			if j == 1 then
				v.debuffFrames[j]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",2,10) 	
			end
		end	
	end
end

-- data from LoseControl
local spellIds = {
	-- Death Knight
	[108194] = "CC",		-- Asphyxiate
	[115001] = "CC",		-- Remorseless Winter
	[47476]  = "Silence",		-- Strangulate
	[96294]  = "Root",		-- Chains of Ice (Chilblains)
	--[45524]  = "Snare",		-- Chains of Ice
	--[50435]  = "Snare",		-- Chilblains
	--[43265]  = "Snare",		-- Death and Decay (Glyph of Death and Decay) - no way to distinguish between glyphed spell and normal. :(
	--[115000] = "Snare",		-- Remorseless Winter
	--[115018] = "Immune",		-- Desecrated Ground
	--[48707]  = "ImmuneSpell",	-- Anti-Magic Shell
	--[48792]  = "Other",		-- Icebound Fortitude
	--[49039]  = "Other",		-- Lichborne
	--[51271] = "Other",		-- Pillar of Frost
	-- Death Knight Ghoul
	[91800]  = "CC",		-- Gnaw
	[91797]  = "CC",		-- Monstrous Blow (Dark Transformation)
	[91807]  = "Root",		-- Shambling Rush (Dark Transformation)
	-- Druid
	[113801] = "CC",		-- Bash (Force of Nature - Feral Treants)
	--[102795] = "CC",		-- Bear Hug
	[33786]  = "CC",		-- Cyclone
	[99]     = "CC",		-- Disorienting Roar
	--[2637]   = "CC",		-- Hibernate
	[22570]  = "CC",		-- Maim
	[5211]   = "CC",		-- Mighty Bash
	--[9005]   = "CC",		-- Pounce
	--[102546] = "CC",		-- Pounce (Incarnation)
	[114238] = "Silence",		-- Fae Silence (Glyph of Fae Silence)
	[81261]  = "Silence",		-- Solar Beam
	[339]    = "Root",		-- Entangling Roots
	[113770] = "Root",		-- Entangling Roots (Force of Nature - Balance Treants)
	--[19975]  = "Root",		-- Entangling Roots (Nature's Grasp)
	[45334]  = "Root",		-- Immobilized (Wild Charge - Bear)
	[102359] = "Root",		-- Mass Entanglement
	--[50259]  = "Snare",		-- Dazed (Wild Charge - Cat)
	--[58180]  = "Snare",		-- Infected Wounds
	--[61391]  = "Snare",		-- Typhoon
	--[127797] = "Snare",		-- Ursol's Vortex
	--[???] = "Snare",		-- Wild Mushroom: Detonate
	-- Druid Symbiosis
	--[110698] = "CC",		-- Hammer of Justice (Paladin)
	--[113004] = "CC",		-- Intimidating Roar [Fleeing in fear] (Warrior)
	--[113056] = "CC",		-- Intimidating Roar [Cowering in fear] (Warrior)
	--[126458] = "Disarm",		-- Grapple Weapon (Monk)
	--[110693] = "Root",		-- Frost Nova (Mage)
	--[110610] = "Snare",		-- Ice Trap (Hunter)
	--[110617] = "Immune",		-- Deterrence (Hunter)
	--[110715] = "Immune",		-- Dispersion (Priest)
	--[110700] = "Immune",		-- Divine Shield (Paladin)
	--[110696] = "Immune",		-- Ice Block (Mage)
	--[110570] = "ImmuneSpell",	-- Anti-Magic Shell (Death Knight)
	--[110788] = "ImmuneSpell",	-- Cloak of Shadows (Rogue)
	--[113002] = "ImmuneSpell",	-- Spell Reflection (Warrior)
	--[110791] = "Other",		-- Evasion (Rogue)
	--[110575] = "Other",		-- Icebound Fortitude (Death Knight)
	--[122291] = "Other",		-- Unending Resolve (Warlock)
	-- Hunter
	[117526] = "CC",		-- Binding Shot
	[3355]   = "CC",		-- Freezing Trap
	--[1513]   = "CC",		-- Scare Beast
	--[19503]  = "CC",		-- Scatter Shot
	[19386]  = "CC",		-- Wyvern Sting
	--[34490]  = "Silence",		-- Silencing Shot
	--[19185]  = "Root",		-- Entrapment
	[64803]  = "Root",		-- Entrapment
	[128405] = "Root",		-- Narrow Escape
	--[35101]  = "Snare",		-- Concussive Barrage
	--[5116]   = "Snare",		-- Concussive Shot
	--[61394]  = "Snare",		-- Frozen Wake (Glyph of Freezing Trap)
	--[13810]  = "Snare",		-- Ice Trap
	--[19263]  = "Immune",		-- Deterrence
	-- Hunter Pets
	--[90337]  = "CC",		-- Bad Manner (Monkey)
	[24394]  = "CC",		-- Intimidation
	--[126246] = "CC",		-- Lullaby (Crane)
	--[126355] = "CC",		-- Paralyzing Quill (Porcupine)
	--[126423] = "CC",		-- Petrifying Gaze (Basilisk)
	[50519]  = "CC",		-- Sonic Blast (Bat)
	--[56626]  = "CC",		-- Sting (Wasp)
	--[96201]  = "CC",		-- Web Wrap (Shale Spider)
	--[50541]  = "Disarm",		-- Clench (Scorpid)
	--[91644]  = "Disarm",		-- Snatch (Bird of Prey)
	--[90327]  = "Root",		-- Lock Jaw (Dog)
	--[50245]  = "Root",		-- Pin (Crab)
	--[54706]  = "Root",		-- Venom Web Spray (Silithid)
	--[4167]   = "Root",		-- Web (Spider)
	--[50433]  = "Snare",		-- Ankle Crack (Crocolisk)
	--[54644]  = "Snare",		-- Frost Breath (Chimaera)
	--[54216]  = "Other",		-- Master's Call (root and snare immune only)
	-- Mage
	--[118271] = "CC",		-- Combustion Impact
	[44572]  = "CC",		-- Deep Freeze
	[31661]  = "CC",		-- Dragon's Breath
	[118]    = "CC",		-- Polymorph
	[61305]  = "CC",		-- Polymorph: Black Cat
	[28272]  = "CC",		-- Polymorph: Pig
	[61721]  = "CC",		-- Polymorph: Rabbit
	[61780]  = "CC",		-- Polymorph: Turkey
	[28271]  = "CC",		-- Polymorph: Turtle
	[82691]  = "CC",		-- Ring of Frost
	[102051] = "Silence",		-- Frostjaw (also a root)
	--[55021]  = "Silence",		-- Silenced - Improved Counterspell
	[122]    = "Root",		-- Frost Nova
	[111340] = "Root",		-- Ice Ward
	--[121288] = "Snare",		-- Chilled (Frost Armor)
	--[120]    = "Snare",		-- Cone of Cold
	--[116]    = "Snare",		-- Frostbolt
	--[44614]  = "Snare",		-- Frostfire Bolt
	--[113092] = "Snare",		-- Frost Bomb
	--[31589]  = "Snare",		-- Slow
	--[45438]  = "Immune",		-- Ice Block
	--[115760] = "ImmuneSpell",	-- Glyph of Ice Block
	-- Mage Water Elemental
	[33395]  = "Root",		-- Freeze
	-- Monk
	[123393] = "CC",		-- Breath of Fire (Glyph of Breath of Fire)
	--[126451] = "CC",		-- Clash
	--[122242] = "CC",		-- Clash (not sure which one is right)
	[119392] = "CC",		-- Charging Ox Wave
	[120086] = "CC",		-- Fists of Fury
	[119381] = "CC",		-- Leg Sweep
	[115078] = "CC",		-- Paralysis
	--[117368] = "Disarm",		-- Grapple Weapon
	[140023] = "Disarm",		-- Ring of Peace
	--[137461] = "Disarm",		-- Disarmed (Ring of Peace)
	[137460] = "Silence",		-- Silenced (Ring of Peace)
	--[116709] = "Silence",		-- Spear Hand Strike
	[116706] = "Root",		-- Disable
	--[113275] = "Root",		-- Entangling Roots (Symbiosis)
	--[123407] = "Root",		-- Spinning Fire Blossom
	--[116095] = "Snare",		-- Disable
	--[118585] = "Snare",		-- Leer of the Ox
	--[123727] = "Snare",		-- Dizzying Haze
	--[123586] = "Snare",		-- Flying Serpent Kick
	--[131523] = "ImmuneSpell",	-- Zen Meditation
	-- Paladin
	[105421] = "CC",		-- Blinding Light
	--[115752] = "CC",		-- Blinding Light (Glyph of Blinding Light)
	[105593] = "CC",		-- Fist of Justice
	[853]    = "CC",		-- Hammer of Justice
	[119072] = "CC",		-- Holy Wrath
	[20066]  = "CC",		-- Repentance
	[10326]  = "CC",		-- Turn Evil
	[145067] = "CC",		-- Turn Evil (Evil is a Point of View)
	[31935]  = "Silence",		-- Avenger's Shield
	--[110300] = "Snare",		-- Burden of Guilt
	--[63529]  = "Snare",		-- Dazed - Avenger's Shield
	--[20170]  = "Snare",		-- Seal of Justice
	--[642]    = "Immune",		-- Divine Shield
	--[31821]  = "Other",		-- Aura Mastery
	--[1022]   = "Other",		-- Hand of Protection
	-- Priest
	--[113506] = "CC",		-- Cyclone (Symbiosis)
	[605]    = "CC",		-- Dominate Mind
	[88625]  = "CC",		-- Holy Word: Chastise
	[64044]  = "CC",		-- Psychic Horror
	[8122]   = "CC",		-- Psychic Scream
	--[113792] = "CC",		-- Psychic Terror (Psyfiend)
	[9484]   = "CC",		-- Shackle Undead
	[87204]  = "CC",		-- Sin and Punishment
	[15487]  = "Silence",		-- Silence
	--[64058]  = "Disarm",		-- Psychic Horror
	--[113275] = "Root",		-- Entangling Roots (Symbiosis)
	[87194]  = "Root",		-- Glyph of Mind Blast
	[114404] = "Root",		-- Void Tendril's Grasp
	--[15407]  = "Snare",		-- Mind Flay
	--[47585]  = "Immune",		-- Dispersion
	--[114239] = "ImmuneSpell",	-- Phantasm
	-- Rogue
	[2094]   = "CC",		-- Blind
	[1833]   = "CC",		-- Cheap Shot
	[1776]   = "CC",		-- Gouge
	[408]    = "CC",		-- Kidney Shot
	--[113953] = "CC",		-- Paralysis (Paralytic Poison)
	[6770]   = "CC",		-- Sap
	[1330]   = "Silence",		-- Garrote - Silence
	--[51722]  = "Disarm",		-- Dismantle
	--[115197] = "Root",		-- Partial Paralysis
	--[3409]   = "Snare",		-- Crippling Poison
	--[26679]  = "Snare",		-- Deadly Throw
	--[119696] = "Snare",		-- Debilitation
	--[31224]  = "ImmuneSpell",	-- Cloak of Shadows
	--[45182]  = "Other",		-- Cheating Death
	--[5277]   = "Other",		-- Evasion
	--[76577]  = "Other",		-- Smoke Bomb
	--[88611]  = "Other",		-- Smoke Bomb
	-- Shaman
	--[76780]  = "CC",		-- Bind Elemental
	[77505]  = "CC",		-- Earthquake
	[51514]  = "CC",		-- Hex
	[118905] = "CC",		-- Static Charge (Capacitor Totem)
	--[113287] = "Silence",		-- Solar Beam (Symbiosis)
	[64695]  = "Root",		-- Earthgrab (Earthgrab Totem)
	[63685]  = "Root",		-- Freeze (Frozen Power)
	--[3600]   = "Snare",		-- Earthbind (Earthbind Totem)
	--[77478]  = "Snare",		-- Earthquake (Glyph of Unstable Earth)
	--[8034]   = "Snare",		-- Frostbrand Attack
	--[8056]   = "Snare",		-- Frost Shock
	--[51490]  = "Snare",		-- Thunderstorm
	--[8178]   = "ImmuneSpell",	-- Grounding Totem Effect (Grounding Totem)
	-- Shaman Primal Earth Elemental
	[118345] = "CC",		-- Pulverize
	-- Warlock
	[710]    = "CC",		-- Banish
	[137143] = "CC",		-- Blood Horror
	--[54786]  = "CC",		-- Demonic Leap (Metamorphosis)
	[5782]   = "CC",		-- Fear
	[118699] = "CC",		-- Fear
	[130616] = "CC",		-- Fear (Glyph of Fear)
	[5484]   = "CC",		-- Howl of Terror
	[22703]  = "CC",		-- Infernal Awakening
	[6789]   = "CC",		-- Mortal Coil
	--[132412] = "CC",		-- Seduction (Grimoire of Sacrifice)
	[30283]  = "CC",		-- Shadowfury
	--[104045] = "CC",		-- Sleep (Metamorphosis)
	[132409] = "Silence",		-- Spell Lock (Grimoire of Sacrifice)
	[31117]  = "Silence",		-- Unstable Affliction
	--[18223]  = "Snare",		-- Curse of Exhaustion
	--[47960]  = "Snare",		-- Shadowflame
	--[110913] = "Other",		-- Dark Bargain
	--[104773] = "Other",		-- Unending Resolve
	-- Warlock Pets
	[89766]  = "CC",		-- Axe Toss (Felguard/Wrathguard)
	[115268] = "CC",		-- Mesmerize (Shivarra)
	[6358]   = "CC",		-- Seduction (Succubus)
	--[115782] = "Silence",		-- Optical Blast (Observer)
	--[24259]  = "Silence",		-- Spell Lock (Felhunter)
	--[118093] = "Disarm",		-- Disarm (Voidwalker/Voidlord)
	-- Warrior
	[7922]   = "CC",		-- Charge Stun
	[118895] = "CC",		-- Dragon Roar
	[5246]   = "CC",		-- Intimidating Shout (aoe)
	--[20511]  = "CC",		-- Intimidating Shout (targeted)
	[132168] = "CC",		-- Shockwave
	[107570] = "CC",		-- Storm Bolt
	[132169] = "CC",		-- Storm Bolt
	[105771] = "Root",		-- Warbringer
	[18498]  = "Silence",		-- Silenced - Gag Order (PvE only)
	--[676]    = "Disarm",		-- Disarm
	[107566] = "Root",		-- Staggering Shout
	--[1715]   = "Snare",		-- Hamstring
	--[12323]  = "Snare",		-- Piercing Howl
	--[129923] = "Snare",		-- Sluggish (Glyph of Hindering Strikes)
	--[137637] = "Snare",		-- Warbringer
	--[46924]  = "Immune",		-- Bladestorm
	--[23920]  = "ImmuneSpell",	-- Spell Reflection
	--[114028] = "ImmuneSpell",	-- Mass Spell Reflection
	--[18499]  = "Other",		-- Berserker Rage
	-- Other
	[30217]  = "CC",		-- Adamantite Grenade
	[67769]  = "CC",		-- Cobalt Frag Bomb
	[30216]  = "CC",		-- Fel Iron Bomb
	[107079] = "CC",		-- Quaking Palm
	[13327]  = "CC",		-- Reckless Charge
	[20549]  = "CC",		-- War Stomp
	[25046]  = "Silence",		-- Arcane Torrent (Energy)
	[28730]  = "Silence",		-- Arcane Torrent (Mana)
	[50613]  = "Silence",		-- Arcane Torrent (Runic Power)
	[69179]  = "Silence",		-- Arcane Torrent (Rage)
	[80483]  = "Silence",		-- Arcane Torrent (Focus)
	[129597] = "Silence",		-- Arcane Torrent (Chi)
	[39965]  = "Root",		-- Frost Grenade
	[55536]  = "Root",		-- Frostweave Net
	[13099]  = "Root",		-- Net-o-Matic
	--[1604]   = "Snare",		-- Dazed
	-- PvE
	--[123456] = "PvE",		-- This is just an example, not a real spell
}

for k, v in pairs(spellIds) do
	local name = GetSpellInfo(k)
	if not name then
		log(" unknown spellId: " .. k)
		spellIds[k] = nil
	end
end

local function isPriorityDebuff(unit, index, filter)
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff = UnitDebuff(unit, index, filter);
    if ( spellIds[spellId] or spellId == 30108 or spellId == 34914 or isBossDebuff) then  
		return true
	else
		return false
	end
end

--users can add your spellIDs 
local UserSpellIds = {
	[19740] = 1,
	[20217] = 1,
}

local function IsUserDefinedSpell( id )
	return UserSpellIds[id]
end
-- Update aura for each unit
function ArenaStyle:UNIT_AURA(uid)
	--print(uid)
	for f,v in pairs(self.cache) do
		--print(f.unit ,uid)
		if f.unit == uid then
			local filter = nil
			local buffNum = 1
			local index = 1
			while buffNum <= self.db.buffnum do
				local buffName,_,_,_,_,_, time, _,_,_, id = UnitBuff(uid, index, filter);
				if ( buffName ) then
					if ( CompactUnitFrame_UtilShouldDisplayBuff(uid, index, filter) ) or IsUserDefinedSpell(id) then
						--if buffNum > DEFAULT_BUFF then
							local buffFrame = v.buffFrames[buffNum]
							CompactUnitFrame_UtilSetBuff(buffFrame, uid, index, filter)
						--end
						buffNum = buffNum + 1
					end
				else
					break
				end
				index = index + 1
			end
			for i=buffNum, self.db.buffnum do
				local buffFrame = v.buffFrames[i]
				if buffFrame then
					buffFrame:Hide()
				end
			end
			local debuffNum = 1
			index = 1
			if ( f.optionTable.displayOnlyDispellableDebuffs ) then
				filter = "RAID"
			end
			if true then
				while debuffNum <= self.db.debuffnum do
					local debuffName = UnitDebuff(uid, index, nil)
					if ( debuffName ) then
						if ( CompactUnitFrame_UtilShouldDisplayDebuff(uid, index, nil) and isPriorityDebuff(uid, index, nil)) then
							local debuffFrame = v.debuffFrames[debuffNum]
							CompactUnitFrame_UtilSetDebuff(debuffFrame, uid, index, nil)
							debuffFrame:SetSize(f.buffFrames[3]:GetSize()*1.5,f.buffFrames[3]:GetSize()*1.5)
							debuffNum = debuffNum + 1
						end
					else
						break
					end
					index = index + 1
				end
				index = 1
				while debuffNum <= self.db.debuffnum do
					local debuffName = UnitDebuff(uid, index, filter)
					if ( debuffName ) then
						if ( CompactUnitFrame_UtilShouldDisplayDebuff(uid, index, filter) and not isPriorityDebuff(uid, index, filter)) then
							local debuffFrame = v.debuffFrames[debuffNum]
							CompactUnitFrame_UtilSetDebuff(debuffFrame, uid, index, filter)
							debuffFrame:SetSize(f.buffFrames[3]:GetSize())
							debuffNum = debuffNum + 1
						end
					else
						break
					end
					index = index + 1
				end
			else
				while debuffNum <= self.db.debuffnum do
					local debuffName = UnitDebuff(uid, index, filter)
					if ( debuffName ) then
						if ( CompactUnitFrame_UtilShouldDisplayDebuff(uid, index, filter) ) then
							local debuffFrame = v.debuffFrames[debuffNum]
							CompactUnitFrame_UtilSetDebuff(debuffFrame, uid, index, filter)
							debuffFrame:SetSize(f.buffFrames[3]:GetSize())
							debuffNum = debuffNum + 1
						end
					else
						break
					end
					index = index + 1
				end
			end
			for i=debuffNum, self.db.debuffnum do
				local debuffFrame = v.debuffFrames[i];
				if debuffFrame then
					debuffFrame:Hide()
				end
			end
			break
		end
	end
end
-- Apply style for each frame
function ArenaStyle:ApplyFrame(f)
	self.cache[f] = {}
	--print("Apply577")
	local scf = self.cache[f]
	scf.displayedUnit = f.unit
	f:SetScript("OnSizeChanged",function() ArenaStyle:ResetFrame(f) ArenaStyle:ApplyFrame(f) end) 
	if not scf.buffFrames then scf.buffFrames = {} end
	if not scf.debuffFrames then scf.debuffFrames = {} end
	for j = 1, self.db.buffnum do
		--print("buffnum"..j)
		if not scf.buffFrames[j] then
			scf.buffFrames[j] = CreateFrame("Button","SCF"..f:GetName().."buffFrames"..j,f,"CompactBuffTemplate")
			scf.buffFrames[j].baseSize = f.buffFrames[3]:GetSize()
			scf.buffFrames[j]:EnableMouse(false)
			scf.buffFrames[j]:ClearAllPoints()
			if j == 1 then
				scf.buffFrames[j]:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,-1)
			else
				scf.buffFrames[j]:SetPoint("TOPRIGHT",scf.buffFrames[j-1],"TOPLEFT")
			end
			scf.buffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
		end
	end
	for j = 1,self.db.debuffnum do
		--print("debuffnum"..j)
		if not scf.debuffFrames[j] then
			scf.debuffFrames[j] = CreateFrame("Button","SCF"..f:GetName().."debuffFrames"..j,f,"CompactDebuffTemplate")
			scf.debuffFrames[j].baseSize = f.buffFrames[3]:GetSize()
			scf.debuffFrames[j]:EnableMouse(false)
			if j == 1 then
				scf.debuffFrames[j]:ClearAllPoints()
				scf.debuffFrames[j]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",2,10) 
	
			else
				scf.debuffFrames[j]:SetPoint("BOTTOMLEFT",scf.debuffFrames[j-1],"BOTTOMRIGHT")			
			end
			--f.debuffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
			scf.debuffFrames[j]:SetSize(f.buffFrames[3]:GetSize())
			scf.debuffFrames[j]:Hide()
		end
	end
	for j = 1,3 do--#f.debuffFrames do
		f.debuffFrames[j]:Hide()
		f.debuffFrames[j]:SetScript("OnShow",f.debuffFrames[j].Hide)
		f.buffFrames[j]:Hide()
		f.buffFrames[j]:SetScript("OnShow",f.buffFrames[j].Hide)
	end
end
-- Reset to the original style
function ArenaStyle:ResetStyle()
	for f,_ in pairs(ArenaStyle.cache) do
		ArenaStyle:ResetFrame(f)
	end
end
-- Reset style to each cached frame
function ArenaStyle:ResetFrame(f)
	for k,v in pairs(self.cache[f].buffFrames) do
		if v then
			v:Hide()
		end
	end
	for k,v in pairs(self.cache[f].debuffFrames) do
		if v then
			v:Hide()
		end
	end
	f:SetScript("OnSizeChanged",nil)
	for j = 1,#f.debuffFrames do
		f.debuffFrames[j]:SetScript("OnShow",nil) 
	end
	self.cache[f] = nil
end
function ArenaStyle:OnCombat()
	-- todo
end
function ArenaStyle:LeaveCombat()
	-- todo
end

-- Event handling
ArenaStyle:RegisterEvent("ADDON_LOADED")
ArenaStyle:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaStyle:RegisterEvent("UNIT_AURA")
_G.ArenaStyle = ArenaStyle

hooksecurefunc("CompactUnitFrame_UpdateAll", function (frame) 
	if frame.unit then 
		ArenaStyle:ApplyStyle(frame) 
		--print(frame:GetName(),frame.unit)
	end
end)