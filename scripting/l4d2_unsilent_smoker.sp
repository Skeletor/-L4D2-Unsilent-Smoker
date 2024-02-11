/*
*	================================ Description =============================================
*	
*	Whenever you encounter the AI smoker and it's preparing to attack, it emits the
*	distnguishable 'warning' sound.
*
*	However you may have seen situations where one performs the attack without
*	making the noise at all (or it gets almost insta interrupted/silenced).
*
*	It happens when the smoker isn't facing you directly before performing the attack, and 
*	his 'warning' sound gets interrupted by the 'spot prey' sound.
*	
*	This plugin simply blocks the 'spot prey' sound if the previous smoker's sound was
*	the 'warning' one.
*/



#include <sourcemod>
#include <sdktools_sound>


#define DEBUG			 		0

#define ERROR_VALUE				-1
#define TEAM_INFECTED			3
#define ZOMBIE_CLASS_SMOKER		1


bool isLastSoundWarning[MAXPLAYERS + 1];
int  smokers[MAXPLAYERS + 1];


public Plugin myinfo =
{
	name = "L4D2 Unsilent Smoker",
	author = "Skeletor",
	description = "Makes the AI smoker always emit the warning sound without interrupting it by other sounds.",
	version = "1.0",
	url = ""
}

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_disconnect", Event_PlayerDeath);
	
	AddNormalSoundHook(NormalSHook:SoundHook);
	
	InitArrays();
}

public OnMapStart()
{
	InitArrays();
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsSmokerAndAI(client))
	{
		return;
	}
	
	AddSmoker(client);
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsSmokerAndAI(client))
	{
		return;
	}
	
	RemoveSmoker(client);
}

Action SoundHook(Clients[64], &NumClients, String:StrSample[PLATFORM_MAX_PATH], &Entity)
{
	if (!IsSmokerVoice(StrSample))
	{
		return Plugin_Continue;
	}
	
	if (!IsSmokerAndAI(Entity))
	{
		return Plugin_Continue;
	}
	
	#if DEBUG
	PrintToChatAll("[%N] made sound: %s", Entity, StrSample);
	#endif
	
	int smokerIndex = FindSmokerIndex(Entity);
	
	if (smokerIndex == ERROR_VALUE)
	{
		return Plugin_Continue;
	}
	
	if (IsWarningSound(StrSample))
	{
		isLastSoundWarning[smokerIndex] = true;
		return Plugin_Continue;
	}
	
	if (IsSpotPreySound(StrSample) && IsLastSoundWarningForSmoker(smokerIndex))
	{
		isLastSoundWarning[smokerIndex] = false;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

bool IsSmokerVoice(String:StrSample[PLATFORM_MAX_PATH])
{
	return StrContains(StrSample, "/smoker/voice/", false) != -1;
}

bool IsWarningSound(String:StrSample[PLATFORM_MAX_PATH])
{
	return StrContains(StrSample, "/warn/Smoker_Warn", false) != -1;
}

bool IsSpotPreySound(String:StrSample[PLATFORM_MAX_PATH])
{
	return StrContains(StrSample, "/idle/Smoker_SpotPrey", false) != -1;
}

bool IsLastSoundWarningForSmoker(int index)
{
	return isLastSoundWarning[index];
}

void AddSmoker(int client)
{
	for (int i = 0; i < MAXPLAYERS; ++i)
	{
		if (smokers[i] == ERROR_VALUE)
		{
			smokers[i] = client;
			return;
		}
	}
}

void RemoveSmoker(int client)
{
	for (int i = 0; i < MAXPLAYERS; ++i)
	{
		if (smokers[i] == client)
		{
			smokers[i] = ERROR_VALUE;
			isLastSoundWarning[i] = false;
			return;
		}
	}
}

int FindSmokerIndex(int smoker)
{
	int index = ERROR_VALUE;
	
	for (int i = 0; i < MAXPLAYERS; ++i)
	{		
		if (smokers[i] != smoker)
		{
			continue;
		}
		
		index = i;
		break;
	}
	
	return index;
}

void InitArrays()
{
	for (int i = 0; i < MAXPLAYERS; ++i)
	{
		smokers[i] = ERROR_VALUE;
		isLastSoundWarning[i] = false;
	}
}

bool IsSmokerAndAI(int client)
{
	return client > 0
		   && IsClientInGame(client)
		   && GetClientTeam(client) == TEAM_INFECTED
		   && IsFakeClient(client)
		   && GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIE_CLASS_SMOKER;
}