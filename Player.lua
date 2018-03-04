--[[--------------------------------------------------------------------
	NoNonsense
	Hides useless NPC chat, system messages, ability announcements, and more.
	Copyright 2012-2018 Phanx <addons@phanx.net>
	All rights reserved. See LICENSE.txt for details.
	https://github.com/Phanx/NoNonsense
----------------------------------------------------------------------]]

local _, private = ...
local knownLanguages = private.knownLanguages

local gsub     = string.gsub
local strfind  = string.find
local strlower = string.lower
local strmatch = string.match
local strupper = string.upper

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
--	Hide some unfriendly emotes
------------------------------------------------------------------------

local emotesToHide = {
	" spits on ",
	" rude gesture",
	" makes some strange gestures",
}
local function FilterEmotes(frame, event, message, sender)
	for i = 1, #emotesToHide do
		if strmatch(message, emotesToHide[i]) then
			return true
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", FilterEmotes)
ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FilterEmotes)

------------------------------------------------------------------------
--	Hide "grats" and "reported" type spam
--	Hide ability announcement spam in dungeons
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
	
	local dungeonTypes = {
		party = true,
		raid = true,
		scenario = true,
	}
	local dungeonSpam = {
		-- Keywords
		"activated",
		"interrupted",
		--[[ Abilities
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
		"wind shear",]]
	}
	
	local function filter(_, event, message, sender, language, ...)
		local mlower = strlower(message)

		if spam[mlower] or not knownLanguages[language or ""] then
			print("Blocked junk:", message)
			return true
		end

		if event == "CHAT_MSG_CHANNEL" or not UnitAffectingCombat("player") then
			return
		end

		local _, instanceType = IsInInstance()
		if not dungeonTypes[instanceType] then
			return
		end

		for i = 1, #dungeonSpam do
			if strfind(mlower, dungeonSpam[i]) then
				print("Removed announcement spam:", message)
				return true
			end
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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
end

------------------------------------------------------------------------
--	Hide public messages containing Cyrillic or CJK characters
--	Based on BlockChinese, by Ketho
--	https://www.curseforge.com/wow/addons/blockchinese
--	https://www.wowinterface.com/downloads/info20488-BlockChinese.html
--	208       : Cyrillic
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
--	https://www.wowinterface.com/downloads/info14574.html
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
