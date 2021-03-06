local _CreateConVar = CreateConVar
local _CurTime = CurTime
local _hook_Add = hook.Add
local _player_GetAll = player.GetAll

if !gAC.config.NEKO_LUA_CHECKS then return end

local Neko_Value = gAC.Encoder.stringrandom(8, true)

_CreateConVar("neko_exit", Neko_Value, { FCVAR_CHEAT, FCVAR_PROTECTED, FCVAR_NOT_CONNECTED, FCVAR_USERINFO, FCVAR_UNREGISTERED, FCVAR_REPLICATED, FCVAR_UNLOGGED, FCVAR_DONTRECORD, FCVAR_SPONLY } )
_CreateConVar("neko_list", Neko_Value, { FCVAR_CHEAT, FCVAR_PROTECTED, FCVAR_NOT_CONNECTED, FCVAR_USERINFO, FCVAR_UNREGISTERED, FCVAR_REPLICATED, FCVAR_UNLOGGED, FCVAR_DONTRECORD, FCVAR_SPONLY } )

--Like if you managed to receive all gAC files then he should be able to receive the next messages.
_hook_Add("gAC.CLFilesLoaded", "g-ACAntiNekoPlayerAuthed", function(plr)
	plr.GAC_Neko = 0
	plr.GAC_Neko_Checks = _CurTime() + 5
	gAC.Network:Send("g-AC_antineko", Neko_Value, plr)
end)

gAC.Network:AddReceiver("g-AC_Neko",function(tabledata, ply)
	if ply.GAC_NEKOG then return end
	ply.GAC_NEKOG = true
	gAC.AddDetection( ply, "Global 'neko' function detected [Code 112]", gAC.config.NEKO_LUA_RETRIVAL_PUNISHMENT, gAC.config.NEKO_LUA_RETRIVAL_BANTIME )
end)

_hook_Add("Tick", "gAC-CheckNeko", function()
	local _IPAIRS_ = _player_GetAll()
	for k=1, #_IPAIRS_   do
		local ply =_IPAIRS_[k]
		if ply:IsBot() then continue end
		if !ply.GAC_Neko_Checks then continue end
		if ply.GAC_Neko_Checks > _CurTime() then continue end
		if ply:IsTimingOut() then continue end
		if ply:GetInfo( "neko_exit" ) != Neko_Value || ply:GetInfo("neko_list") != Neko_Value then
			if ply.GAC_Neko > 4 then
				gAC.AddDetection( ply, "Anti-neko cvar response not returned [Code 114]", gAC.config.NEKO_LUA_RETRIVAL_PUNISHMENT, gAC.config.NEKO_LUA_RETRIVAL_BANTIME )
				ply.GAC_Neko_Checks = nil
				continue
			end
			ply.GAC_Neko = ply.GAC_Neko + 1
			ply.GAC_Neko_Checks = _CurTime() + 15
			continue
		end
		if ply.GAC_Neko != 0 then
			ply.GAC_Neko = 0
		end
		ply.GAC_Neko_Checks = _CurTime() + 5
	end
end )