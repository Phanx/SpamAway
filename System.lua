------------------------------------------------------------------------
--	NoNonsense
--	Hides useless NPC chat, system messages, ability announcements, and more.
--	Copyright (c) 2012-2016 Phanx <addons@phanx.net>. All rights reserved.
--	https://github.com/Phanx/NoNonsense
-----------------------------------------------------------------------

local ADDON, private = ...

local function topattern(str)
	if not str then return "" end
	str = gsub(str, "%%%d?$?c", ".+")
	str = gsub(str, "%%%d?$?d", "%%d+")
	str = gsub(str, "%%%d?$?s", ".+")
	str = gsub(str, "([%(%)])", "%%%1")
	return str
end

private.topattern = topattern

local gsub     = string.gsub
local strfind  = string.find
local strlower = string.lower
local strmatch = string.match
local strupper = string.upper

------------------------------------------------------------------------
--	Hide boss warnings from the middle of the screen
------------------------------------------------------------------------

RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_WHISPER")

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
--	Hide spammy system messages
------------------------------------------------------------------------

do
	local patterns = {
		-- Auction expired
		topattern(ERR_AUCTION_EXPIRED_S),
		-- Complaint Registered.
		COMPLAINT_ADDED,
		-- Duel info
		topattern(DUEL_WINNER_KNOCKOUT),
		topattern(DUEL_WINNER_RETREAT),
		-- Other people are drunk
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
		--topattern(ERR_QUEST_REWARD_ITEM_S),
		--topattern(ERR_QUEST_REWARD_ITEM_MULT_IS),
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
