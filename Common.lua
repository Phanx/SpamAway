--[[--------------------------------------------------------------------
	NoNonsense
	Hides useless NPC chat, system messages, ability announcements, and more.
	Copyright 2012-2018 Phanx <addons@phanx.net>
	All rights reserved. See LICENSE.txt for details.
	https://github.com/Phanx/NoNonsense
----------------------------------------------------------------------]]

local _, private = ...

private.topattern = function(str)
	if not str then return "" end
	str = gsub(str, "%%%d?$?c", ".+")
	str = gsub(str, "%%%d?$?d", "%%d+")
	str = gsub(str, "%%%d?$?s", ".+")
	str = gsub(str, "([%(%)])", "%%%1")
	return str
end

private.knownLanguages = setmetatable({
	[""] = true,
}, {
	__index = function(t, k)
		local numLanguages = GetNumLanguages()
		if numLanguages < 1 then
			return true
		end
		for i = 1, numLanguages do
			local name, id = GetLanguageByIndex(i)
			t[id] = true
			t[name] = true
			t[strlower(name)] = true
			t[strupper(name)] = true
		end
		setmetatable(t, nil)
		return t[k]
	end
})

function private.IsFriend(name)
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
