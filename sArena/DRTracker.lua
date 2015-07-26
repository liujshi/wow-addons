-- liujshi -- liujunshisysu@gmail.com
sArena.DRTracker = CreateFrame("Frame", nil, sArena)

sArena.Defaults.DRTracker = {
	enabled = true,
	scale = 2,
}

function sArena.DRTracker:Initialize()
	if ( not sArenaDB.DRTracker ) then
		sArenaDB.DRTracker = CopyTable(sArena.Defaults.DRTracker)
	end
	self.frame={}
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		self.frame["arena"..i]=CreateFrame("Frame", "sArenaDRTrackerframearena"..i, ArenaFrame)
		self.frame["arena"..i]:SetPoint("LEFT",sArena.Trinkets["arena"..i],"RIGHT")
		self.frame["arena"..i].tracker = { }
	end
end

local DRData = LibStub("DRData-1.0")

hooksecurefunc(sArena, "Initialize", function() sArena.DRTracker:Initialize() end)


function sArena.DRTracker:DRFaded(unit, spellID)
	local drCat = DRData:GetSpellCategory(spellID)
--	print(spellID,drCat)
	local drTexts = {
		[1] = {"\194\189", 0, 1, 0},
		[0.5] = {"\194\188", 1, 0.65, 0},
		[0.25] = {"%", 1, 0, 0},
		[0] = {"%", 1, 0, 0},
	}
	if not self.frame[unit].tracker[drCat] then
		self.frame[unit].tracker[drCat] = self:CreateIcon(unit,drCat)
	end		


	local tracked = self.frame[unit].tracker[drCat]
	tracked.active = true
	if tracked and tracked.reset <= GetTime() then
		tracked.diminished = 1
	else
		tracked.diminished = DRData:NextDR(tracked.diminished)
	end
	if self.test and tracked.diminished == 0 then
		tracked.diminished = 1
	end
	tracked.timeLeft = DRData:GetResetTime()
	tracked.reset = tracked.timeLeft + GetTime()
	local text, r, g, b = unpack(drTexts[tracked.diminished])
	tracked.text:SetText(text)
	tracked.text:SetTextColor(r,g,b)
	tracked.Texture:SetTexture(GetSpellTexture(spellID))
	tracked:SetCooldown(GetTime(),18)\

	--the following code will bring some unknown bugs
	-- tracked:SetScript("OnUpdate", function(f, elapsed)
	-- 	f.timeLeft = f.timeLeft - elapsed
	-- 	if f.timeLeft <= 0 then
	-- 		f.active = false
	-- 		-- position icons
	-- 		self:SortIcons(unit)
	-- 		-- reset script
	-- 		tracked:SetScript("OnUpdate", nil)
	-- 	end
	-- end)
	tracked:SetAlpha(1)
	self:SortIcons(unit)

end

function sArena.DRTracker:SortIcons(unit)
	local lastFrame = self.frame[unit]
	for cat, frame in pairs(self.frame[unit].tracker) do
		frame:ClearAllPoints()
		frame:SetAlpha(0)
		if frame.active then
			frame:SetPoint("RIGHT", lastFrame == self.frame[unit] and sArena.Trinkets[unit] or lastFrame, "LEFT",lastFrame == self.frame[unit] and -1 or -0, lastFrame == self.frame[unit] and -1 or -0)
			lastFrame = frame
			frame:SetAlpha(1)
		end
	end
end

sArena.DRTracker:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function sArena.DRTracker:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	-- Enemy had a debuff refreshed before it faded, so fade + gain it quickly
	local unit

	for i = 1, MAX_ARENA_ENEMIES do
		if UnitGUID("arena"..i) == destGUID then
			unit = "arena"..i
		end
	end
	if not unit then
		return
	end

	if event == "SPELL_AURA_REFRESH" then
		if auraType == "DEBUFF" and DRData:GetSpellCategory(spellID) then
			self:DRFaded(unit, spellID)
		end
	-- Buff or debuff faded from an enemy
	elseif event == "SPELL_AURA_REMOVED" then
		if auraType == "DEBUFF" and DRData:GetSpellCategory(spellID) then
			self:DRFaded(unit, spellID)
		end
	end
end

--sArena.DRTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function sArena.DRTracker:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	if ( sArenaDB.DRTracker.enabled and instanceType == "arena" ) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		if ( self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") ) then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end
sArena.DRTracker:RegisterEvent("PLAYER_ENTERING_WORLD")


function sArena.DRTracker:CreateIcon(unit,drCat)
	local frame= self.frame[unit]
	local tracked = CreateFrame("Cooldown", nil, frame)--, "CooldownFrameTemplate")
	tracked:SetFrameLevel(frame:GetFrameLevel() + 3)
	tracked:ClearAllPoints()
	tracked:SetReverse(true)
	tracked:SetSize(18, 18)
	tracked:SetScale(1.5)
	tracked.reset=0
	
	-- Find Blizzard's built-in cooldown count and make it smaller. Credits to Zork/Rothar for this.
	for _, region in next, {tracked:GetRegions()} do
		if region:GetObjectType() == "FontString" then
			tracked.Text = region
		end
	end
	local font = tracked.Text:GetFont()
	tracked.Text:SetFont(font, 7, "OUTLINE")
	tracked.Text:SetPoint("TOP", tracked, 0, 0)

	tracked.text = tracked:CreateFontString(nil, "OVERLAY")
	tracked.text:SetDrawLayer("OVERLAY")
	tracked.text:SetJustifyH("RIGHT")
	tracked.text:SetPoint("BOTTOM", tracked, 0, 0)
	tracked.text:SetFont("Fonts\\FRIZQT__.TTF",10, "OUTLINE")

	tracked.Texture = tracked:CreateTexture("FT", "BORDER")
	tracked.Texture:SetAllPoints()

	tracked.cate = drCat

	if ( not sArenaDB.DRTracker.enabled ) then tracked:Hide() end


	local function OnShow(self)
		self.active = true
		sArena.DRTracker:SortIcons(unit)
	end
	tracked:HookScript("OnShow", OnShow)

	local function OnHide(self)
		self.active = false
		sArena.DRTracker:SortIcons(unit)
	end
	tracked:HookScript("OnHide", OnHide)
				
	return tracked
end

function sArena.DRTracker:Test(numOpps)
	if ( sArena:CombatLockdown() or not sArenaDB.DRTracker.enabled ) then return end
	for i = numOpps, 1, -1 do
		self:DRFaded("arena"..i, 33786)
		self:DRFaded("arena"..i, 8122)
		self:DRFaded("arena"..i, 118)
		self:DRFaded("arena"..i, 132169)
		self:DRFaded("arena"..i, 47476)
		self:DRFaded("arena"..i, 122)
	end
end
hooksecurefunc(sArena, "Test", function(obj, arg1) sArena.DRTracker:Test(arg1) end)

function sArena.DRTracker:Scale(scale)
	for i = 1, MAX_ARENA_ENEMIES do
		trackers = self.frame["unit"..i]
		for drt,tracked in pairs(trackers)
			do
				tracked:SetScale(scale)
		end
	end
end