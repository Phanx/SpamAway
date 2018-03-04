--[[--------------------------------------------------------------------
	NoNonsense
	Hides useless NPC chat, system messages, ability announcements, and more.
	Copyright 2012-2018 Phanx <addons@phanx.net>
	All rights reserved. See LICENSE.txt for details.
	https://github.com/Phanx/NoNonsense
----------------------------------------------------------------------]]

local _, private = ...
local knownLanguages = private.knownLanguages

NoNonsenseDB = {
	npcblacklist = {
		["Adarrah"] = true,
		["Arcanist Braedan"] = true, ["Arkanist Braedin"] = true,
		["Budd"] = true,
		["Captured Nectarbreeze Farmer"] = true, ["Gefesselter Bauer von Nektarhauch"] = true,
		["Chief Officer Coppernut"] = true, ["Erste Offizierin Kupfernuss"] = true,
		["Chief Officer Ograh"] = true, ["Leitender Offizier Ograh"] = true,
		["Despondent Warden of Zhu"] = true, ["Bedrückter Wächter von Zhu"] = true,
		["Dook Ookem"] = true, ["Djuuk Uukem"] = true,
		["Dumass"] = true, ["Kagbuhn"] = true,
		["Expelled Hozen"] = true, ["Ausgeworfener Ho-Zen"] = true,
		["Force Commander Danath Trollbane"] = true,
		["Frezza"] = true,
		["Gormali Slaver"] = true, ["Gormalisklavenhändler"] = true,
		["Greeb Ramrocket"] = true, ["Grieb Rammrakete"] = true,
		["Greenstone Miner"] = true, ["Grünsteinbergarbeiter"] = true,
		["Grookin Pounder"] = true, ["Stampfer vom Flotschhügel"] = true,
		["Hellscream's Vanguard"] = true, ["Höllschreis Vorhut"] = true,
		["Hin Denburg"] = true,
		["Hozen Beastrunner"] = true, ["Ho-zen-Tierhetzer"] = true,
		["Hozen Groundpounder"] = true, ["Ho-zen-Wutschäumer"] = true,
		["Hozen Gutripper"] = true, ["Ho-zen-Magenfetzer"] = true,
		["Hozen Mudflinger"] = true, ["Ho-zen-Schlicksleuderer"] = true,
		["Inkgill Dissenter"] = true, ["Dissident der Tintenkiemen"] = true,
		["Kingslayer Orkus"] = true, ["Orkus der Königsmörder"] = true,
		["Legionnaire Nazgrim"] = true, ["Legionär Nazgrim"] = true,
		["Liu Flameheart"] = true, ["Liu Flammenherz"] = true,
		["Meefi Farthrottle"] = true, ["Meefi Weltdrossel"] = true,
		["Ordo Marauder"] = true, ["Marodeur von Ordo"] = true,
		["Ordo Warbringer"] = true, ["Kriegshetzer von Ordo"] = true,
		["Ordo Warrior"] = true, ["Krieger von Ordo"] = true,
		["Overlord Krom'gar"] = true, ["Oberanführer Krom'gar"] = true,
		["Pandaren Prisoner"] = true, ["Pandarengefangener"] = true,
		["Sha of Anger"] = true, ["Sha des Zorns"] = true,
		['Sky-Captain "Dusty" Blastnut'] = true, ['Himmelskatpitän "Staubwolke" Sprengteufel'] = true,
		["Sky-Captain Cloudkicker"] = true, ["Himmelskapitän Wolkenwirbler"] = true,
		["Snurk Bucksquick"] = true, ["Snurk Zasterwill"] = true,
		["Springtail Digger"] = true, ["Buddler der Sprungschwelfe"] = true,
		["Springtail Gnasher"] = true, ["Knirshcer der Sprungschwelfe"] = true,
		["Springtail Leaper"] = true, ["Hüpfer der Sprungschwelfe"] = true,
		["Springtail Ogler"] = true, ["Gaffer der Sprungschwelfe"] = true,
		["Tian Pupil"] = true, ["Schüler von Tian"] = true,
		["Tina Wang"] = true,
		["Turgore"] = true,
		["Watcher Tolwe"] = true, ["Behüter Tolwe"] = true,
		["Wavespeaker Valoren"] = true, ["Wellensprechering Valoren"] = true,
		["Wayward Ancestor"] = true, ["Verirrter Urahne"] = true,
		["Zapetta"] = true,
		["Zelli Hotnozzle"] = true, ["Zelli Heißdüse"] = true,
	},
	npcwhitelist = {
		["High Ravenspeaker Krikka"] = true,
		["Orb of Ascension"] = true, ["Kugel des Aufstiegs"] = true,
		["\"Tipsy\" McManus"] = true, ["\"Schluckspecht\" McManus"] = true,
	}
}

local notfunny = {
	["Zhao-Jin the Bloodletter"] = "Let the men have their way with them.",
	["Boldrich Stonerender"] = "Deathwing will have his way with your Stonemother",
}

local seen = {}

local function filter(frame, event, message, sender, language, ...)
	if NoNonsenseDB.npcwhitelist[sender] then
		-- Always show
		return false
	end

	if NoNonsenseDB.npcblacklist[sender] then
		-- Never show
		return true
	end
--[[
	if not knownLanguages[language or ""] then
		-- Can't read, don't care.
		print("Blocked unknown language:", language, sender, message)
		return true
	end
]]
	-- Rape isn't funny, Blizzard.
	if notfunny[sender] then
		message = strtrim(gsub(message, notfunny[sender], ""))
		if strlen(message) < 5 then
			return true
		end
	end

	if not seen[frame] then
		seen[frame] = {}
	end
	if not seen[frame][sender] then
		seen[frame][sender] = {}
	end
	if not seen[frame][sender][message] then
		-- never seen, show
		seen[frame][sender][message] = GetTime()
	elseif GetTime() - seen[frame][sender][message] > 300 then
		-- last seen more than 5 minutes ago, show
		seen[frame][sender][message] = GetTime()
	else
		-- last seen less than 5 minutes ago, hide
		return true
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", filter)

SLASH_SPAMAWAYNPC1 = "/ignorenpc"
SlashCmdList.SPAMAWAYNPC = function(msg)
	if strlen(msg) > 0 then
		if NoNonsenseDB.npcblacklist[msg] then
			NoNonsenseDB.npcblacklist[msg] = nil
			return print("No longer ignoring", msg)
		else
			NoNonsenseDB.npcblacklist[msg] = true
			return print("Now ignoring", msg)
		end
	end
	local tmplist = {}
	for npc in pairs(NoNonsenseDB.npcblacklist) do
		tinsert(tmplist, npc)
	end
	local listn = #tmplist
	if listn > 0 then
		sort(tmplist)
		print("Currently ignoring", listn, "NPCs:")
		for i = 1, listn do
			print("  -", tmplist[i])
		end
	else
		print("You are not ignoring any NPCs.")
	end
end
