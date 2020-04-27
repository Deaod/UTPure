//================================================================================
// zp_ShockBeam.
//================================================================================
class zp_ShockBeam expands ShockBeam;

simulated function Timer ()
{
	if ( (Owner == None) || (Owner.Role != 3) )
	{
		Super.Timer();
	}
}

defaultproperties
{
    bOwnerNoSee=True
}
