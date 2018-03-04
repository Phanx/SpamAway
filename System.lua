--[[--------------------------------------------------------------------
	NoNonsense
	Hides useless NPC chat, system messages, ability announcements, and more.
	Copyright 2012-2018 Phanx <addons@phanx.net>
	All rights reserved. See LICENSE.txt for details.
	https://github.com/Phanx/NoNonsense
----------------------------------------------------------------------]]

local ADDON, private = ...
local topattern = private.topattern
local IsFriend = private.IsFriend

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
	local spam = topattern(LFG_LEADER_CHANGED_WARNING)

	local OnEvent = RaidWarningFrame:GetScript("OnEvent")
	RaidWarningFrame:SetScript("OnEvent", function(self, event, message, ...)
		if not strmatch(message, spam) then
			OnEvent(self, event, message, ...)
		end
	end)
end

------------------------------------------------------------------------
--	Hide crafting spam from non-friend/guild
------------------------------------------------------------------------

do
	local spam = topattern(TRADESKILL_LOG_THIRDPERSON)

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
	local spam = topattern(ACHIEVEMENT_BROADCAST)

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
		-- Complaint registered
		topattern(COMPLAINT_ADDED),
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
		topattern(ERR_QUEST_REWARD_MONEY_S),
		-- Other
		topattern(ERR_LEARN_TRANSMOG_S),
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
