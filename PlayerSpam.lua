

local gsub     = string.gsub
local strfind  = string.find
local strlower = string.lower
local strmatch = string.match
local strupper = string.upper

local knownLanguages = setmetatable({}, { __index = function(t, k)
	for i = 1, GetNumLanguages() do
		local language = GetLanguageByIndex(i)
		t[language] = true
		t[strlower(language)] = true
		t[strupper(language)] = true
	end
	setmetatable(t, nil)
	return t[k]
end })

local function IsFriend(name)
	if not name then
		return
	end
	if UnitIsInMyGuild(name) or UnitInRaid(name) or UnitInParty(name) then
		return true
	end
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then
			return true
		end
	end
	local _, numBNFriends = BNGetNumFriends()
	for i = 1, numBNFriends do
		for j = 1, BNGetNumFriendToons(i) do
			local _, toonName = BNGetFriendToonInfo(i, j)
			if toonName == name then
				return true
			end
		end
	end
end

------------------------------------------------------------------------
--	Hide boss warnings from the middle of the screen
------------------------------------------------------------------------

RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_WHISPER")

------------------------------------------------------------------------
-- Remove raid target icons and consecutive symbols in public chat
------------------------------------------------------------------------

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(frame, event, message, ...)
	message = gsub(message, "{.-}", "")
	message = gsub(message, "!!+", "!")
	message = gsub(message, "??+", "?")
	message = gsub(message, "[!?][!?]+", "?!")
	message = gsub(message, "<<+", "<")
	message = gsub(message, ">>+", ">")
	message = gsub(message, "~~+", "")
	message = gsub(message, "//+", "")
	message = gsub(message, "%-%-+", "")
	return false, message, ...
end)


------------------------------------------------------------------------
--	Hide useless "leader changed" raid warning messages in LFG
------------------------------------------------------------------------

do
	local spam = gsub(LFG_LEADER_CHANGED_WARNING, "%%%d?$?s", "")
	local oev = RaidWarningFrame_OnEvent
	function RaidWarningFrame_OnEvent(self, event, message, ...)
		if not strmatch(message, spam) then
			oev(self, event, message, ...)
		end
	end
end

------------------------------------------------------------------------
--	Hide crafting spam from non-friend/guild
------------------------------------------------------------------------

do
	local spam = gsub(TRADESKILL_LOG_THIRDPERSON, "%%%d?$?s", "(.+)")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", function(_, _, message)
		local who, what = strmatch(message, spam)
		if who and what and not IsFriend(who) then
			return true
		end
	end)
end

------------------------------------------------------------------------
--	Hide achievements from non-friend/guild
------------------------------------------------------------------------

do
	local spam = gsub(ACHIEVEMENT_BROADCAST, "%%s", "(.+)")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", function(_, _, message)
		local who, what = strmatch(message, spam)
		if who and what and not IsFriend(strmatch(who, "%[(.-)%]")) then
			return true
		end
	end)
end

------------------------------------------------------------------------
--	Hide "grats" and "reported" type spam
--	Hide player messages in languages you don't understand
------------------------------------------------------------------------

do
	local spam = {
		["ding"] = true,
		["gg"] = true,
		["grats"] = true,
		["gratz"] = true,
		["reported"] = true,
	}

	local function filter(_, _, message, sender, language, ...)
		if spam[strlower(message)] or (language and language ~= "" and not knownLanguages[language]) then
			print("Blocked junk:", message)
			return true
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
end

------------------------------------------------------------------------
--	Hide ability announcement spam
------------------------------------------------------------------------

do
	local dungeonSpam = {
		-- Keywords
		"activated",
		"interrupted",
		-- Abilities
		"avenger",
		"bash",
		"counterspell",
		"dispel",
		"divine protection",
		"gag order",
		"mind freeze",
		"pummel",
		"purge",
		"rallying cry",
		"rebuke",
		"salvation",
		"shield wall",
		"silence",
		"spell lock",
		"strangulate",
		"taunt",
		"wind shear",
	}

	local function filter(_, _, message)
		if IsInInstance() and UnitAffectingCombat("player") then
			local mlower = strlower(message)
			for i = 1, #dungeonSpam do
				if strfind(mlower, dungeonSpam[i]) then
					print("Removed announcement spam:", message)
					return true
				end
			end
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
end

------------------------------------------------------------------------
--	Hide spammy system messages
------------------------------------------------------------------------

local function topattern(str)
	str = gsub(str, "%%%d?$?c", ".+")
	str = gsub(str, "%%%d?$?d", "%%d+")
	str = gsub(str, "%%%d?$?s", ".+")
	str = gsub(str, "([%(%)])", "%%%1")
	return str
end
_G.topattern = topattern -- DEBUG

do
	local patterns = {
		-- Auction expired
		topattern(ERR_AUCTION_EXPIRED_S),
		-- Complaint Registered.
		COMPLAINT_ADDED,
		-- Duel info
		topattern(DUEL_WINNER_KNOCKOUT),
		topattern(DUEL_WINNER_RETREAT),
		-- Drunk status
		topattern(DRUNK_MESSAGE_ITEM_OTHER1),
		topattern(DRUNK_MESSAGE_ITEM_OTHER2),
		topattern(DRUNK_MESSAGE_ITEM_OTHER3),
		topattern(DRUNK_MESSAGE_ITEM_OTHER4),
		topattern(DRUNK_MESSAGE_OTHER1),
		topattern(DRUNK_MESSAGE_OTHER2),
		topattern(DRUNK_MESSAGE_OTHER3),
		topattern(DRUNK_MESSAGE_OTHER4),
		-- Quest verbosity
		topattern(ERR_QUEST_REWARD_EXP_I),
		topattern(ERR_QUEST_REWARD_ITEM_S),
		topattern(ERR_QUEST_REWARD_ITEM_MULT_IS),
		topattern(ERR_QUEST_REWARD_MONEY_S),
		-- Other
		topattern(ERR_ZONE_EXPLORED),
		topattern(ERR_ZONE_EXPLORED_XP),
	}

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message, ...)
		for i = 1, #patterns do
			if strmatch(message, patterns[i]) then
				return true
			end
		end
		message = gsub(message, "([^,:|%[%]%s%.]+)%-[^,:|%[%]%s%.]+", "%1") -- remove realm names
		return false, message, ...
	end)
end

------------------------------------------------------------------------
--	Hide public messages containing East Asian characters
--	Based on BlockChinese, by Ketho
--	http://www.curse.com/addons/wow/blockchinese
--	http://www.wowinterface.com/downloads/info20488-BlockChinese.html
--	227       : Japanese katakana / hiragana
--	228 - 233 : Chinese characters and Japanese kanji
--	234 - 237 : Korean characters
------------------------------------------------------------------------

do
	local function filter(frame, event, message)
		if strfind(message, "[\227-\237]") then
			return true
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
end

------------------------------------------------------------------------
--	Hide repeated AFK and DND auto-responses.
--	Based on FilterAFK by Tsigo, and DontBugMe by Moonsorrow and Gnarfoz
--	http://www.wowinterface.com/downloads/info14574.html
------------------------------------------------------------------------
do
	local seen = {}
	local when = {}

	local function filter(_, _, message, sender, ...)
		if seen[frame] and seen[frame][sender] and seen[frame][sender] == message and GetTime() - when[sender] < 60 then
			when[sender] = GetTime()
			return true
		end

		if seen[frame] then
			seen[frame][sender] = message
		else
			seen[frame] = { [sender] = message }
		end

		when[sender] = GetTime()
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", filter)
end