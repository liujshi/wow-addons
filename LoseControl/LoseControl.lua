--[[ Code Credits - to the people whose code I borrowed and learned from:
Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

local addonName, L = ...
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local UnitAura = UnitAura
local GetTime = GetTime
local SetPortraitToTexture = SetPortraitToTexture
local print = print
local debug = false -- type "/lc debug on" if you want to see UnitAura info logged to the console

-------------------------------------------------------------------------------
-- Thanks to all the people on the Curse.com and WoWInterface forums who help keep this list up to date :)
local spellCat = {
	[2]="Immune",
	[3]="ImmuneSpell",
	[6]="Stun",
	[11]="Distorient",
	[12]="Incapacitate",
	[13]="ImmuneBlock",
	[14]="Silence",
	[15]="Root",
	[20]="Defense",
	[26]="Attack"
}
local spellIds = {
	--免疫类--1-5（包括昏迷、控制、沉默、法术及物理伤害，觉得非必需，可移至防御类）

	[46924]=spellCat[2],--剑刃风暴 
	[33786]=spellCat[2],--旋风
	[115018]=spellCat[2],--邪恶之地 
	[642]=spellCat[2],--圣盾术
	[19263]=spellCat[2],--威慑
	[47585]=spellCat[2],--消散 
	[45438]=spellCat[2],--寒冰屏障  
	[115760]=spellCat[2],--寒冰屏障雕文

	--法术免疫--
	[8178]=spellCat[3],--根基图腾
	[48707]=spellCat[3],--反魔法护罩
	[31224]=spellCat[3],--暗影斗篷
	[23920]=spellCat[3],--法术反射 
	[114028]=spellCat[3],--群体反射

	--昏迷类6-10---------------
	[132168]=spellCat[6],--震荡波
	[132169]=spellCat[6],--风暴之锤  
	[118895]=spellCat[6],--巨龙怒吼
	[108194]=spellCat[6],--窒息  
	[115001]=spellCat[6],--冷酷严冬 
	[91800]=spellCat[6],--撕扯
	[91797]=spellCat[6],--蛮兽打击
	[853]=spellCat[6],--制裁之锤   
	[105593]=spellCat[6],--制裁之拳 
	[117526]=spellCat[6],--束缚射击
	[24394]=spellCat[6],--胁迫 
	[118905]=spellCat[6],--电能图腾 
	[118345]=spellCat[6],--粉碎 
	[77505]=spellCat[6],--地震术
	[1833]=spellCat[6],--偷袭 
	[408]=spellCat[6],--肾击 
	[5211]=spellCat[6],--蛮力猛击（天赋）
	[22570]=spellCat[6],--割碎
	[163505]=spellCat[6],--斜掠
	[120086]=spellCat[6],--怒雷破
	[119381]=spellCat[6],--扫堂腿
	[119392]=spellCat[6],--蛮牛冲 
	[44572]=spellCat[6],--深度冻结
	[30283]=spellCat[6],--暗影之怒
	[98766]=spellCat[6],--巨斧投掷（恶魔卫士技能）
	[20549]=spellCat[6],--战争践踏

	--迷惑类-------------------------------
	[5246]=spellCat[11],--破胆怒吼
	[115750]=spellCat[11],--盲目之光 
	[10326]=spellCat[11],--超度邪恶 
	[2094]=spellCat[11],--致盲 
	[118699]=spellCat[11],--恐惧   
	[130616]=spellCat[11],--恐惧(雕文定身)
	[5484]=spellCat[11],--恐惧嚎叫 
	[6358]=spellCat[11],--诱惑（魅魔）
	[115268]=spellCat[11],--迷魅
	[8122]=spellCat[11],--心灵尖啸 

	--瘫痪类-------------------------------
	[77606]=spellCat[12],--黑暗模拟
	[20066]=spellCat[12],--忏悔	
	[1499]=spellCat[12],--冰冻陷阱 
	[3355]=spellCat[12],
	[19386]=spellCat[12],--翼龙钉刺
	[51514]=spellCat[12],--妖术
	[6770]=spellCat[12],--闷棍
	[1776]=spellCat[12],--凿击  
	[99]=spellCat[12],--惊魂咆哮	
	[115078]=spellCat[12],--分筋错骨 
	[123393]=spellCat[12],--火焰之息雕文（酿酒武僧）
	[82691]=spellCat[12],--冰霜之环
	[118]=spellCat[12],--变形术   
	[28271]=spellCat[12],--变形术  
	[28272]=spellCat[12],--变形术
	[61305]=spellCat[12],--变形术  
	[61721]=spellCat[12],--变形术  
	[61780]=spellCat[12],--变形术  
	[31661]=spellCat[12],--龙息术  
	[137143]=spellCat[12],--猩红恐惧
	[6789]=spellCat[12],--死亡缠绕 
	[9484]=spellCat[12],--束缚亡灵 
	[605]=spellCat[12],--统御意志
	[64044]=spellCat[12],--心灵惊骇
	[88625]=spellCat[12],--圣言术：罚
	[107079]=spellCat[12],--震山掌

	--免疫打断--

	[31821]=spellCat[13],--虔诚光环
	[124488]=spellCat[13],--禅意聚神 
	[104773]=spellCat[13],--不灭决心
	[159652]=spellCat[13],--灵魂行者的神盾 
	[159630]=spellCat[13],--心灵专注
	[159436]=spellCat[13],--树皮术雕文

	--沉默打断类--	
	[47476]=spellCat[14],--绞袭 
	[1330]=spellCat[14],--锁喉
	[81261]=spellCat[14],--日光术
	[102051]=spellCat[14],--冰霜之颔
	[31117]=spellCat[14],--痛苦无常沉默
	[15487]=spellCat[14],--沉默（戒律、暗影）
	[25046]=spellCat[14],--奥数洪流
	[28730]=spellCat[14],--奥数洪流
	[50613]=spellCat[14],--奥数洪流
	[69179]=spellCat[14],--奥数洪流
	[80483]=spellCat[14],--奥数洪流
	[129597]=spellCat[14],--奥数洪流
	[155145]=spellCat[14],--奥数洪流

	--定身类-------------------------------------------
	[105771]=spellCat[15],--冲锋定身(不与其他定身递减)  
	[96294]=spellCat[15],--寒冰锁链（冻疮）
	[135373]=spellCat[15],--诱捕
	[64803]=spellCat[15],--诱捕
	[136634]=spellCat[15],--险境求生
	[63685]=spellCat[15],--冰霜之力 
	[64695]=spellCat[15],--陷地
	[102359]=spellCat[15],--群体缠绕 
	[339]=spellCat[15],--纠缠根须 
	[113770]=spellCat[15],--纠缠根须(自然之力天赋)
	[116706]=spellCat[15],--金刚震
	[157997]=spellCat[15],--寒冰新星	
	[122]=spellCat[15],--冰霜新星
	[111340]=spellCat[15],--寒冰结界 
	[33395]=spellCat[15],--冰冻术 
	[108920]=spellCat[15],--虚空触须 
	[87194]=spellCat[15],--心灵震爆


	--防御类20-25-----------------------------------------
	[118038]=spellCat[20],--剑在人在 
	[871]=spellCat[20],--盾墙（防战专属）
	[97463]=spellCat[20],--集结呐喊  
	[12975]=spellCat[20],--破釜沉舟 
	[18499]=spellCat[20],--狂暴之怒 
	[55694]=spellCat[20],--狂暴回复 
	[114029]=spellCat[20],--捍卫 
	[114030]=spellCat[20],--警戒
	[48792]=spellCat[20],-- 冰封之韧  
	[51271]=spellCat[20],--冰霜之柱
	[49039]=spellCat[20],--巫妖之躯   
	[55233]=spellCat[20],--吸血鬼之血
	[48743]=spellCat[20],--天灾契约 
	[498]=spellCat[20],--圣佑术 
	[1022]=spellCat[20],--保护之手 
	[6940]=spellCat[20],--牺牲之手
	[1044]=spellCat[20],--自由之手 
	[114039]=spellCat[20],--纯净之手  
	[53480]=spellCat[20],--牺牲咆哮	
	[54216]=spellCat[20],--主人的召唤 
	[5384]=spellCat[20],--假死   
	[108271]=spellCat[20],--星界转移 
	[30823]=spellCat[20],--萨满之怒 
	[108281]=spellCat[20],--先祖指引 
	[30884]=spellCat[20],--自然守护者 
	[118347]=spellCat[20],--强固 
	[5277]=spellCat[20],--闪避
	[74001]=spellCat[20],--备战就绪
	[1966]=spellCat[20],--佯攻（飘忽不定天赋） 
	[76577]=spellCat[20],--烟幕弹
	[61336]=spellCat[20],--生存本能 
	[22812]=spellCat[20],--树皮术  
	[102342]=spellCat[20],--铁木树皮  
	[116849]=spellCat[20],--作茧缚命 
	[122470]=spellCat[20],--业报之触 
	[137562]=spellCat[20],--逍遥酒
	[115203]=spellCat[20],--壮胆酒
	[122278]=spellCat[20],--躯不坏  
	[108978]=spellCat[20],--操控时间
	[110913]=spellCat[20],--黑暗交易
	[108416]=spellCat[20],--牺牲契约 
	[118359]=spellCat[20],--黑暗再生 
	[47788]=spellCat[20],--守护之魂
	[33206]=spellCat[20],--痛苦压制 
	[62618]=spellCat[20],--真言术：障
	[6346]=spellCat[20],--防护恐惧结界
	[15286]=spellCat[20],--吸血鬼的拥抱
	[114239]=spellCat[20],--幻隐
	[119032]=spellCat[20],--幽灵伪装
	[180767]=spellCat[20],--奶骑四件套
	--进攻类26-30------------------------------------------
	[1719]=spellCat[26],--鲁莽    
	[107574]=spellCat[26],--天神下凡 
	[12292]=spellCat[26],--浴血奋战
	[49206]=spellCat[26],--召唤石像鬼
	[115989]=spellCat[26],--邪恶虫群  
	[152279]=spellCat[26],--辛达苟萨之息
	[130736]=spellCat[26],--灵魂收割 114866 130735
	[31842]=spellCat[26],--复仇之怒 31884(惩戒)
	[105809]=spellCat[26],--神圣复仇者 
	[114916]=spellCat[26],--处决宣判（敌对）
	[3045]=spellCat[26],--急速射击
	[19574]=spellCat[26],--狂野怒火
	[165341]=spellCat[26],--升腾 
	[16166]=spellCat[26],--元素掌握
	[51713]=spellCat[26],--暗影之舞（敏锐） 
	[13750]=spellCat[26],--冲动（战斗）
	[19140]=spellCat[26],--宿敌（刺杀）
	[84746]=spellCat[26],--中等洞悉(黄灯)
	[84747]=spellCat[26],--深度洞悉(红灯)
	[108293]=spellCat[26],--野性之心
	[106951]=spellCat[25],--狂暴
	[112071]=spellCat[26],--超凡之盟  
	[102560]=spellCat[26],--化身艾路恩之眷   102543丛林之王  102558乌索克之子 33891生命之树
	[124974]=spellCat[26],--自然的守护   
	[174544]=spellCat[26],--野蛮咆哮
	[12472]=spellCat[26],--冰冷血脉  
	[12042]=spellCat[26],--奥数强化  
	[113861]=spellCat[26],--黑暗灵魂学识  
	[113860]=spellCat[26],--黑暗灵魂哀难 
	[113858]=spellCat[26],--黑暗灵魂易爆
	[10060]=spellCat[26],--能量灌注 
	[158831]=spellCat[26],--噬灵疫病
}


if debug then
	for k in pairs(spellIds) do
		local name, _, icon = GetSpellInfo(k)
		if not name then print(addonName, ": No spell name", k) end
		if not icon then print(addonName, ": No spell icon", k) end
	end
end

-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {}, -- empty but necessary
	Blizzard = {
		player = "PlayerPortrait",
		pet    = "PetPortrait",
		target = "TargetFramePortrait",
		focus  = "FocusFramePortrait",
		party1 = "PartyMemberFrame1Portrait",
		party2 = "PartyMemberFrame2Portrait",
		party3 = "PartyMemberFrame3Portrait",
		party4 = "PartyMemberFrame4Portrait",
		--party1pet = "PartyMemberFrame1PetFramePortrait",
		--party2pet = "PartyMemberFrame2PetFramePortrait",
		--party3pet = "PartyMemberFrame3PetFramePortrait",
		--party4pet = "PartyMemberFrame4PetFramePortrait",
		arena1 = "ArenaEnemyFrame1ClassPortrait",
		arena2 = "ArenaEnemyFrame2ClassPortrait",
		arena3 = "ArenaEnemyFrame3ClassPortrait",
		arena4 = "ArenaEnemyFrame4ClassPortrait",
		arena5 = "ArenaEnemyFrame5ClassPortrait",
	},
	Perl = {
		player = "Perl_Player_Portrait",
		pet    = "Perl_Player_Pet_Portrait",
		target = "Perl_Target_Portrait",
		focus  = "Perl_Focus_Portrait",
		party1 = "Perl_Party_MemberFrame1_Portrait",
		party2 = "Perl_Party_MemberFrame2_Portrait",
		party3 = "Perl_Party_MemberFrame3_Portrait",
		party4 = "Perl_Party_MemberFrame4_Portrait",
	},
	XPerl = {
		player = "XPerl_PlayerportraitFrameportrait",
		pet    = "XPerl_Player_PetportraitFrameportrait",
		target = "XPerl_TargetportraitFrameportrait",
		focus  = "XPerl_FocusportraitFrameportrait",
		party1 = "XPerl_party1portraitFrameportrait",
		party2 = "XPerl_party2portraitFrameportrait",
		party3 = "XPerl_party3portraitFrameportrait",
		party4 = "XPerl_party4portraitFrameportrait",
	},
	LUI = {
		player = "oUF_LUI_player",
		pet    = "oUF_LUI_pet",
		target = "oUF_LUI_target",
		focus  = "oUF_LUI_focus",
		party1 = "oUF_LUI_partyUnitButton1",
		party2 = "oUF_LUI_partyUnitButton2",
		party3 = "oUF_LUI_partyUnitButton3",
		party4 = "oUF_LUI_partyUnitButton4",
	},
	SyncFrames = {
		arena1 = "SyncFrame1Class",
		arena2 = "SyncFrame2Class",
		arena3 = "SyncFrame3Class",
		arena4 = "SyncFrame4Class",
		arena5 = "SyncFrame5Class",
	},
	--SUF = {
	--	player = SUFUnitplayer.portraitModel.portrait,
	--	pet    = SUFUnitpet.portraitModel.portrait,
	--	target = SUFUnittarget.portraitModel.portrait,
	--	focus  = SUFUnitfocus.portraitModel.portrait,
	--	party1 = SUFUnitparty1.portraitModel.portrait, -- SUFHeaderpartyUnitButton1 ?
	--	party2 = SUFUnitparty2.portraitModel.portrait,
	--	party3 = SUFUnitparty3.portraitModel.portrait,
	--	party4 = SUFUnitparty4.portraitModel.portrait,
	--},
	-- more to come here?
}

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	version = 6.1, -- This is the settings version, not necessarily the same as the LoseControl version
	noCooldownCount = false,
	disablePartyInBG = false,
	disableArenaInBG = true,
	priority = {		-- higher numbers have more priority; 0 = disabled
		Immune				= 90,
		ImmuneSpell			= 80,
		Stun				= 70,
		Distorient			= 60,
		Incapacitate		= 50,
		ImmuneBlock			= 40,
		Silence				= 30,
		Root				= 20,
		Defense				= 10,
		Attack				= 5
	},
	frames = {
		player = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "None",
		},
		pet = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		target = {
			enabled = true,
			size = 56,
			alpha = 1,
			anchor = "Blizzard",
		},
		focus = {
			enabled = true,
			size = 56,
			alpha = 1,
			anchor = "Blizzard",
		},
		party1 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party2 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party3 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party4 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires

-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent) -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Utility function to handle registering for unit events
function LoseControl:RegisterUnitEvents(enabled)
	local unitId = self.unitId
	if debug then print("RegisterUnitEvents", unitId, enabled) end
	if enabled then
		self:RegisterUnitEvent("UNIT_AURA", unitId)
		if unitId == "target" then
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "focus" then
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "pet" then
			self:RegisterUnitEvent("UNIT_PET", "player")
		end
	else
		self:UnregisterEvent("UNIT_AURA")
		if unitId == "target" then
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "focus" then
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "pet" then
			self:UnregisterEvent("UNIT_PET")
		end
	end
end

-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == addonName then
		if _G.LoseControlDB and _G.LoseControlDB.version then
			if _G.LoseControlDB.version < DBdefaults.version then
				if _G.LoseControlDB.version == 5.1 then -- upgrade gracefully
					_G.LoseControlDB.disableArenaInBG = DBdefaults.disableArenaInBG
				else
					_G.LoseControlDB = CopyTable(DBdefaults)
					print(L["LoseControl reset."])
				end
			end
		else -- never installed before
			_G.LoseControlDB = CopyTable(DBdefaults)
			print(L["LoseControl reset."])
		end
		LoseControlDB = _G.LoseControlDB
		self.noCooldownCount = LoseControlDB.noCooldownCount
	end
end
LoseControl:RegisterEvent("ADDON_LOADED")

-- Initialize a frame's position and register for events
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	local unitId = self.unitId
	self.frame = LoseControlDB.frames[unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	local inInstance, instanceType = IsInInstance()
	self:RegisterUnitEvents(
		frame.enabled and not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and string.find(unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and string.find(unitId, "arena") )
			)
		)
	)
	--print(unitID)
	self.anchor = _G[anchors[frame.anchor][unitId]] or UIParent
	self:SetParent(self.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	--self:SetFrameStrata(frame.strata or "LOW")
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
	self:Hide()
end

-- This is the main event. Check for (de)buffs and update the frame icon and cooldown.
function LoseControl:UNIT_AURA(unitId) -- fired when a (de)buff is gained/lost
	if not self.anchor:IsVisible() then return end

	local priority = LoseControlDB.priority
	local maxPriority = 1
	local maxExpirationTime = 0
	local Icon, Duration

	-- Check debuffs
	for i = 1, 40 do
		local name, _, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i, "HARMFUL")
		if not spellId then break end -- no more debuffs, terminate the loop
		if debug then print(unitId, "debuff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end

		-- exceptions
		if spellId == 88611 and unitId ~= "player" then -- Smoke Bomb
			expirationTime = GetTime() + 1 -- normal expirationTime = 0
		elseif spellId == 81261  -- Solar Beam
		    or spellId == 127797 -- Ursol's Vortex
		then
			expirationTime = GetTime() + 1 -- normal expirationTime = 0
		end

		local Priority = priority[spellIds[spellId]]
		if Priority then
			if Priority == maxPriority and expirationTime > maxExpirationTime then
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
			elseif Priority > maxPriority then
				maxPriority = Priority
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
			end
		end
	end

	-- Check buffs
	if true and (priority.Immune > 0 or priority.ImmuneSpell > 0 or priority.Defense > 0 or priority.ImmuneBlock > 0 or priority.Attack > 0) then
		for i = 1, 40 do
			local name, _, icon, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i) -- defaults to "HELPFUL" filter
			if not spellId then break end
			if debug then print(unitId, "buff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end

			-- exceptions
			if spellId == 8178 or spellId == 115018 then -- Grounding Totem Effect
				expirationTime = GetTime() + 15 -- hack, normal expirationTime = 0
				duration=15
			end

			local Priority = priority[spellIds[spellId]]
			if Priority then
				if Priority == maxPriority and expirationTime > maxExpirationTime then
					maxExpirationTime = expirationTime
					Duration = duration
					Icon = icon
				elseif Priority > maxPriority then
					maxPriority = Priority
					maxExpirationTime = expirationTime
					Duration = duration
					Icon = icon
				end
			end
		end
	end

	if maxExpirationTime == 0 then -- no (de)buffs found
		self.maxExpirationTime = 0
		if self.anchor ~= UIParent and self.drawlayer then
			self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer
		end
		self:Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime then -- this is a different (de)buff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		if self.anchor ~= UIParent then
			self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()) -- must be dynamic, frame level changes all the time
			if not self.drawlayer and self.anchor.GetDrawLayer then
				self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
			end
			if self.drawlayer and self.anchor.SetDrawLayer then
				self.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
			end
		end
		if self.frame.anchor == "Blizzard" then
			SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits. TO DO: mask the cooldown frame somehow so the corners don't stick out of the portrait frame. Maybe apply a circular alpha mask in the OVERLAY draw layer.
		else
			self.texture:SetTexture(Icon)
		end
		self:Show()
		if Duration > 0 then
			self:SetCooldown( maxExpirationTime - Duration, Duration )
		end
		--UIFrameFadeOut(self, Duration, self.frame.alpha, 0)
		self:SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
	end
end

function LoseControl:PLAYER_FOCUS_CHANGED()
	--if (debug) then print("PLAYER_FOCUS_CHANGED") end
	self:UNIT_AURA("focus")
end

function LoseControl:PLAYER_TARGET_CHANGED()
	--if (debug) then print("PLAYER_TARGET_CHANGED") end
	self:UNIT_AURA("target")
end

function LoseControl:UNIT_PET(unitId)
	--if (debug) then print("UNIT_PET", unitId) end
	self:UNIT_AURA("pet")
end

-- Handle mouse dragging
function LoseControl:StopMoving()
	local frame = LoseControlDB.frames[self.unitId]
	frame.point, frame.anchor, frame.relativePoint, frame.x, frame.y = self:GetPoint()
	if not frame.anchor then
		frame.anchor = "None"
	end
	self.anchor = _G[anchors[frame.anchor][self.unitId]] or UIParent
	self:StopMovingOrSizing()
end



-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown", addonName .. unitId) --, UIParent)
	setmetatable(o, self)
	self.__index = self

	-- Init class members
	o.unitId = unitId -- ties the object to a unit
	o.texture = o:CreateTexture(nil, "BORDER") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	o.text = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	o.text:SetText(L[unitId])
	o.text:SetPoint("BOTTOM", o, "BOTTOM")
	o.text:Hide()

	-- Rufio's code to make the frame border pretty. Maybe use this somehow to mask cooldown corners in Blizzard frames.
	--o.overlay = o:CreateTexture(nil, "OVERLAY") -- displays the alpha mask for making rounded corners
	--o.overlay:SetTexture("\\MINIMAP\UI-Minimap-Background")
	--o.overlay:SetTexture("Interface\\AddOns\\LoseControl\\gloss")
	--SetPortraitToTexture(o.overlay, "Textures\\MinimapMask")
	--o.overlay:SetBlendMode("BLEND") -- maybe ALPHAKEY or ADD?
	--o.overlay:SetAllPoints(o) -- anchor the texture to the frame
	--o.overlay:SetPoint("TOPLEFT", -1, 1)
	--o.overlay:SetPoint("BOTTOMRIGHT", 1, -1)
	--o.overlay:SetVertexColor(0.25, 0.25, 0.25)
	o:Hide()

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function

	o:RegisterEvent("PLAYER_ENTERING_WORLD")

	return o
end

-- Create new object instance for each frame
local LCframes = {}
for k in pairs(DBdefaults.frames) do
	LCframes[k] = LoseControl:new(k)
end

-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = addonName .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(addonName)

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(addonName, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(addonName, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(L["Unlock"])
function Unlock:OnClick()
	if self:GetChecked() then
		_G[O.."UnlockText"]:SetText(L["Unlock"] .. L[" (drag an icon to move)"])
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LCframes) do
			local frame = LoseControlDB.frames[k]
			if frame.enabled and (_G[anchors[frame.anchor][k]] or frame.anchor == "None") then -- only unlock frames whose anchor exists
				v:RegisterUnitEvents(false)
				v.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
				v:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
				--v:SetFrameStrata(frame.strata or "MEDIUM")
				if v.anchor:GetParent() then
					v:SetFrameLevel(v.anchor:GetParent():GetFrameLevel())
				end
				v.text:Show()
				v:Show()
				v:SetCooldown( GetTime(), 30 )
				v:SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
				v:SetMovable(true)
				v:RegisterForDrag("LeftButton")
				v:EnableMouse(true)
			end
		end
	else
		_G[O.."UnlockText"]:SetText(L["Unlock"])
		for _, v in pairs(LCframes) do
			v:EnableMouse(false)
			v:RegisterForDrag()
			v:SetMovable(false)
			v.text:Hide()
			v:PLAYER_ENTERING_WORLD()
		end
	end
end
Unlock:SetScript("OnClick", Unlock.OnClick)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(L["Disable OmniCC Support"])
DisableCooldownCount:SetScript("OnClick", function(self)
	LoseControlDB.noCooldownCount = self:GetChecked()
	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
end)

local Priority = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Priority:SetText(L["Priority"])

local PriorityDescription = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
PriorityDescription:SetText(L["PriorityDescription"])

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv
local function CreateSlider(text, parent, low, high, step)
	local name = parent:GetName() .. text
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetWidth(160)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText(low)
	_G[name .. "High"]:SetText(high)
	return slider
end

local PrioritySlider = {}
for k in pairs(DBdefaults.priority) do
	--print(k,L[k])
	PrioritySlider[k] = CreateSlider(L[k], OptionsPanel, 0, 100, 10)
	PrioritySlider[k]:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. value .. ")")
		LoseControlDB.priority[k] = value
	end)
end

-------------------------------------------------------------------------------
-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 16, -16)
subText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

Unlock:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -16)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, -2)

Priority:SetPoint("TOPLEFT", DisableCooldownCount, "BOTTOMLEFT", 0, -12)
PriorityDescription:SetPoint("TOPLEFT", Priority, "BOTTOMLEFT", 0, -8)
PrioritySlider.Immune:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", 0, -24)
PrioritySlider.ImmuneSpell:SetPoint("TOPLEFT", PrioritySlider.Immune, "BOTTOMLEFT", 0, -24)
PrioritySlider.Stun:SetPoint("TOPLEFT", PrioritySlider.ImmuneSpell, "BOTTOMLEFT", 0, -24)
PrioritySlider.Distorient:SetPoint("TOPLEFT", PrioritySlider.Stun, "BOTTOMLEFT", 0, -24)
PrioritySlider.Incapacitate:SetPoint("TOPLEFT", PrioritySlider.Distorient, "BOTTOMLEFT", 0, -24)
PrioritySlider.ImmuneBlock:SetPoint("TOPLEFT", PrioritySlider.Incapacitate, "BOTTOMLEFT", 0, -24)
PrioritySlider.Silence:SetPoint("TOPLEFT", PrioritySlider.ImmuneBlock, "BOTTOMLEFT", 0, -24)
PrioritySlider.Root:SetPoint("TOPLEFT", PrioritySlider.Silence, "BOTTOMLEFT", 0, -24)
PrioritySlider.Defense:SetPoint("TOPLEFT", PrioritySlider.Root, "BOTTOMLEFT", 0, -24)
PrioritySlider.Attack:SetPoint("TOPLEFT", PrioritySlider.Defense, "BOTTOMLEFT", 0, -24)

-------------------------------------------------------------------------------
OptionsPanel.default = function() -- This method will run when the player clicks "defaults".
	_G.LoseControlDB = nil
	LoseControl:ADDON_LOADED(addonName)
	for _, v in pairs(LCframes) do
		v:PLAYER_ENTERING_WORLD()
	end
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	local priority = LoseControlDB.priority
	for k in pairs(priority) do
		PrioritySlider[k]:SetValue(priority[k])
	end
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
-- DropDownMenu helper function
local function AddItem(owner, text, value)
	local info = UIDropDownMenu_CreateInfo()
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

-------------------------------------------------------------------------------
-- Create sub-option frames
for _, v in ipairs({ "player", "pet", "target", "focus", "party", "arena" }) do
	local OptionsPanelFrame = CreateFrame("Frame", O..v)
	OptionsPanelFrame.parent = addonName
	OptionsPanelFrame.name = L[v]

	local AnchorDropDownLabel = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDownLabel", "ARTWORK", "GameFontNormal")
	AnchorDropDownLabel:SetText(L["Anchor"])
	local AnchorDropDown = CreateFrame("Frame", O..v.."AnchorDropDown", OptionsPanelFrame, "UIDropDownMenuTemplate")
	function AnchorDropDown:OnClick()
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, self.value)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, unitId in ipairs(frames) do
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]

			frame.anchor = self.value
			if AnchorDropDown.value ~= "None" then -- reset the frame position so it centers on the anchor frame
				frame.point = nil
				frame.relativePoint = nil
				frame.x = nil
				frame.y = nil
			end

			icon.anchor = _G[anchors[frame.anchor][unitId]] or UIParent

			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				icon:SetParent(icon.anchor:GetParent())
			end

			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
		end
	end

	local SizeSlider = CreateSlider(L["Icon Size"], OptionsPanelFrame, 16, 512, 4)
	SizeSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Icon Size"] .. " (" .. value .. "px)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].size = value
			LCframes[frame]:SetWidth(value)
			LCframes[frame]:SetHeight(value)
		end
	end)

	local AlphaSlider = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 5) -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
	AlphaSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. value .. "%)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].alpha = value / 100 -- the real alpha value
			LCframes[frame]:SetAlpha(value / 100)
		end
	end)

	local DisableInBG
	if v == "party" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	elseif v == "arena" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disableArenaInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 5 do
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	end

	local Enabled = CreateFrame("CheckButton", O..v.."Enabled", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	_G[O..v.."EnabledText"]:SetText(L["Enabled"])
	Enabled:SetScript("OnClick", function(self)
		local enabled = self:GetChecked()
		if enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
		end
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].enabled = enabled
			LCframes[frame]:RegisterUnitEvents(enabled)
		end
	end)

	Enabled:SetPoint("TOPLEFT", 16, -32)
	if DisableInBG then DisableInBG:SetPoint("TOPLEFT", Enabled, 200, 0) end
	SizeSlider:SetPoint("TOPLEFT", Enabled, "BOTTOMLEFT", 0, -32)
	AlphaSlider:SetPoint("TOPLEFT", SizeSlider, "BOTTOMLEFT", 0, -32)
	AnchorDropDownLabel:SetPoint("TOPLEFT", AlphaSlider, "BOTTOMLEFT", 0, -12)
	AnchorDropDown:SetPoint("TOPLEFT", AnchorDropDownLabel, "BOTTOMLEFT", 0, -8)

	OptionsPanelFrame.default = OptionsPanel.default
	OptionsPanelFrame.refresh = function()
		local unitId = v
		if unitId == "party" then
			DisableInBG:SetChecked(LoseControlDB.disablePartyInBG)
			unitId = "party1"
		elseif unitId == "arena" then
			DisableInBG:SetChecked(LoseControlDB.disableArenaInBG)
			unitId = "arena1"
		end
		local frame = LoseControlDB.frames[unitId]
		Enabled:SetChecked(frame.enabled)
		if frame.enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
		end
		SizeSlider:SetValue(frame.size)
		AlphaSlider:SetValue(frame.alpha * 100)
		UIDropDownMenu_Initialize(AnchorDropDown, function() -- called on refresh and also every time the drop down menu is opened
			AddItem(AnchorDropDown, L["None"], "None")
			AddItem(AnchorDropDown, "Blizzard", "Blizzard")
			if _G[anchors["Perl"][unitId]] then AddItem(AnchorDropDown, "Perl", "Perl") end
			if _G[anchors["XPerl"][unitId]] then AddItem(AnchorDropDown, "XPerl", "XPerl") end
			if _G[anchors["LUI"][unitId]] then AddItem(AnchorDropDown, "LUI", "LUI") end
			if _G[anchors["SyncFrames"][unitId]] then AddItem(AnchorDropDown, "SyncFrames", "SyncFrames") end
		end)
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
	end

	InterfaceOptions_AddCategory(OptionsPanelFrame)
end

-------------------------------------------------------------------------------
SLASH_LoseControl1 = "/lc"
SLASH_LoseControl2 = "/losecontrol"

local SlashCmd = {}
function SlashCmd:help()
	print(addonName, "slash commands:")
	print("    reset [<unit>]")
	print("    lock")
	print("    unlock")
	print("    enable <unit>")
	print("    disable <unit>")
	print("<unit> can be: player, pet, target, focus, party1 ... party4, arena1 ... arena5")
end
function SlashCmd:debug(value)
	if value == "on" then
		debug = true
		print(addonName, "debugging enabled.")
	elseif value == "off" then
		debug = false
		print(addonName, "debugging disabled.")
	end
end
function SlashCmd:reset(unitId)
	if LoseControlDB.frames[unitId] then
		LoseControlDB.frames[unitId] = CopyTable(DBdefaults.frames[unitId])
		LCframes[unitId]:PLAYER_ENTERING_WORLD()
	else
		OptionsPanel.default()
	end
	Unlock:OnClick()
	OptionsPanel.refresh()
end
function SlashCmd:lock()
	Unlock:SetChecked(false)
	Unlock:OnClick()
	print(addonName, "locked.")
end
function SlashCmd:unlock()
	Unlock:SetChecked(true)
	Unlock:OnClick()
	print(addonName, "unlocked.")
end
function SlashCmd:enable(unitId)
	if LCframes[unitId] then
		LoseControlDB.frames[unitId].enabled = true
		LCframes[unitId]:RegisterUnitEvents(true)
		print(addonName, unitId, "frame enabled.")
	end
end
function SlashCmd:disable(unitId)
	if LCframes[unitId] then
		LoseControlDB.frames[unitId].enabled = false
		LCframes[unitId]:RegisterUnitEvents(false)
		print(addonName, unitId, "frame disabled.")
	end
end

SlashCmdList[addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print(addonName, ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end

hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
	if frame.unit then
		local tUnitName = UnitGUID(frame.unit)
		if tUnitName == UnitGUID("party1") then
			LCframes["party1"]:ClearAllPoints()
			LCframes["party1"]:SetPoint(
										"BOTTOMRIGHT",
										frame,
										"BOTTOMLEFT",
										0,
										0)
			LCframes["party1"]:Show()
			--local lcframe = LoseControlDB.frames["party1"]
			--lcframe.point, lcframe.anchor, lcframe.relativePoint, lcframe.x, lcframe.y = LCframes["party1"]:GetPoint()
		elseif tUnitName == UnitGUID("party2") then
			LCframes["party2"]:ClearAllPoints()
			LCframes["party2"]:SetPoint(
										"BOTTOMRIGHT",
										frame,
										"BOTTOMLEFT",
										0,
										0)
			LCframes["party2"]:Show()
			--lcframe = LoseControlDB.frames["party2"]
			--lcframe.point, lcframe.anchor, lcframe.relativePoint, lcframe.x, lcframe.y = LCframes["party2"]:GetPoint()
		elseif tUnitName == UnitGUID("party3") then
			LCframes["party3"]:ClearAllPoints()
			LCframes["party3"]:SetPoint(
										"BOTTOMRIGHT",
										frame,
										"BOTTOMLEFT",
										0,
										0)
			LCframes["party3"]:Show()
		elseif tUnitName == UnitGUID("party4") then
			LCframes["party4"]:ClearAllPoints()
			LCframes["party4"]:SetPoint(
										"BOTTOMRIGHT",
										frame,
										"BOTTOMLEFT",
										0,
										0)
			LCframes["party4"]:Show()
		elseif tUnitName == UnitGUID("player") then
			LCframes["player"]:ClearAllPoints()
			LCframes["player"]:SetPoint(
										"BOTTOMRIGHT",
										frame,
										"BOTTOMLEFT",
										0,
										0)
			LCframes["player"]:Show()	
		end
	end	
end)