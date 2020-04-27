//================================================================================
// zp_Settings.
//================================================================================
class zp_Settings expands Actor
	config(Zeroping);

var config bool zp_Disabled;
var bool sDisabled;
var int PlayerID;

replication
{
	reliable if ( Role < 4 )
		rSetDisabled;
	reliable if ( Role == 4 )
		SetDisabled;
	unreliable if ( Role == 4 )
		PlayerID;
}

simulated function SetDisabled (bool bDisable)
{
	if ( Role == 4 )
	{
		return;
	}
	zp_Disabled=bDisable;
	Default.zp_Disabled=bDisable;
	SaveConfig();
}

function rSetDisabled (bool bDisable)
{
	local zp_Manager M;

	foreach AllActors(Class'zp_Manager',M)
	{
		if (M != None) break;
	}
	if ( M != None )
	{
		M.SetDisabledById(PlayerID,bDisable);
	}
}

defaultproperties
{
    PlayerID=255
    bHidden=True
}
