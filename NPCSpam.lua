------------------------------------------------------------------------
--	SpamAway
-- Hides useless NPC chat, system messages, ability announcements, and more.
-- Copyright (c) 2012-2014 Phanx <addons@phanx.net>
-- https://github.com/Phanx/SpamAway
------------------------------------------------------------------------

SpamAwayDB = {
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
		["Orb of Ascension"] = true, ["Kugel des Aufstiegs"] = true,
		['"Tipsy" McManus'] = true, ['"Schluckspecht" McManus'] = true,
	}
}

local known = setmetatable({}, { __index = function(t, k)
	for i = 1, GetNumLanguages() do
		local name, id = GetLanguageByIndex(i)
		t[id] = true
		t[name] = true
		t[strupper(name)] = true
	end
	setmetatable(t, nil)
	return t[k]
end })

local seen = {}

local function filter(frame, event, message, sender, language, ...)
	if SpamAwayDB.npcwhitelist[sender] then
		-- Always show
		return false
	end

	if SpamAwayDB.npcblacklist[sender] then
		-- Never show
		return true
	end

	if language and language ~= "" and not known[strupper(language)] then
		-- Can't read, don't care.
		return true
	end

	-- Rape isn't funny, Blizzard.
	if sender == "Zhao-Jin the Bloodletter" then
		return false, strtrim(gsub(message, "Let the men have their way with them.")), sender, language, ...
	elseif sender == "Boldrich Stonerender" and message == "Deathwing will have his way with your Stonemother." then
		return true
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
		if SpamAwayDB.npcblacklist[msg] then
			SpamAwayDB.npcblacklist[msg] = nil
			return print("No longer ignoring", msg)
		else
			SpamAwayDB.npcblacklist[msg] = true
			return print("Now ignoring", msg)
		end
	end
	local tmplist = {}
	for npc in pairs(SpamAwayDB.npcblacklist) do
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