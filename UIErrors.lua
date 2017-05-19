------------------------------------------------------------------------
--	NoNonsense
--	Hides useless NPC chat, system messages, ability announcements, and more.
--	Copyright (c) 2012-2017 Phanx <addons@phanx.net>. All rights reserved.
--	https://github.com/Phanx/NoNonsense
------------------------------------------------------------------------

local ADDON, private = ...
local strfind = string.find
local topattern = private.topattern

local strings = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_FLEEING] = true,
	[ERR_GENERIC_NO_TARGET] = true,
	[ERR_INVALID_ATTACK_TARGET] = true,
	[ERR_NO_ATTACK_TARGET] = true,
	[ERR_NOEMOTEWHILERUNNING] = true,
--	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[NAMEPLATES_MESSAGE_ALL_OFF] = true,
	[NAMEPLATES_MESSAGE_ALL_ON] = true,
	[NAMEPLATES_MESSAGE_ALL_ON_AUTO] = true,
	[NAMEPLATES_MESSAGE_ENEMY_OFF] = true,
	[NAMEPLATES_MESSAGE_ENEMY_ON] = true,
	[NAMEPLATES_MESSAGE_ENEMY_ON_AUTO] = true,
	[NAMEPLATES_MESSAGE_FRIENDLY_OFF] = true,
	[NAMEPLATES_MESSAGE_FRIENDLY_ON] = true,
	[NAMEPLATES_MESSAGE_FRIENDLY_ON_AUTO] = true,
	[OUT_OF_ENERGY] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = select(2, UnitClass("player")) == "HUNTER", -- "You can't do that yet"
	[SPELL_FAILED_CASTER_DEAD] = true,
	[SPELL_FAILED_CASTER_DEAD_FEMALE] = true,
--	[SPELL_FAILED_MOVING] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_NO_ENDURANCE] = true,
	[SPELL_FAILED_NOT_IN_CONTROL] = true,
--	[SPELL_FAILED_NOT_INFRONT] = true,
	[SPELL_FAILED_NOT_MOUNTED] = true,
	[SPELL_FAILED_NOT_ON_TAXI] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGETS_DEAD] = true,
}
local patterns = {
}

local AddMessage = UIErrorsFrame.AddMessage
function UIErrorsFrame:AddMessage(message, ...)
	if strings[message] then
		return
	end
	for i = 1, #patterns do
		if strfind(message, patterns[i]) then
			return
		end
	end
	AddMessage(self, message, ...)
end
