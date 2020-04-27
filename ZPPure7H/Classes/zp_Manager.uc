//================================================================================
// zp_Manager.
//================================================================================
class zp_Manager expands Actor;

var int zp_Disabled;
var zp_Settings SettingsList[32];

function SetDisabled (PlayerPawn P, bool disabled)
{
	local int Id;

	if ( (P == None) || (P.PlayerReplicationInfo == None) )
	{
		return;
	}
	Id=P.PlayerReplicationInfo.PlayerID;
	SetDisabledById(Id,disabled);
}

function SetDisabledById (int Id, bool disabled)
{
	local int bit;

	bit=1 << Id;
	if ( disabled == True )
	{
		zp_Disabled=zp_Disabled | bit;
	}
	else
	{
		zp_Disabled=zp_Disabled &  ~bit;
	}
	if ( SettingsList[Id] == None )
	{
		return;
	}
	SettingsList[Id].SetDisabled(disabled);
}

simulated function bool HasZPDisabled (PlayerPawn P)
{
	local int bit;

	bit=1 << P.PlayerReplicationInfo.PlayerID;
	if ( (zp_Disabled & bit) != 0 )
	{
		return True;
	}
	return False;
}

defaultproperties
{
    bHidden=True
}
