//================================================================================
// zp_Interface.
//================================================================================
class zp_Interface expands Actor
	abstract;

var TournamentWeapon zzW;
var name OriginalName;

function Actor xxFire (float Value);

function bool xxClientFire (float Value);

function SetSwitchPriority (Pawn Other);

function bool xxCanHitVictim (out Vector P, Actor Victim);

function Rotator xxFindMiss ();

function xxServerFire (int Id, float Time, out Vector HitLocation, out Actor Victim);

function xxAimAtActor (out Actor Other, out Vector HitLocation);

function bool OwnerIsLocal ()
{
	if ( zzW.Owner == None )
	{
		return True;
	}
	if ( zzW.Owner.RemoteRole <= 2 )
	{
		return True;
	}
	if ( zzW.Owner.Role == 3 )
	{
		return True;
	}
	return False;
}

function Vector xxStartLocation ()
{
	local Vector zzHitLocation;
	local Vector zzHitNormal;
	local Vector zzStartTrace;
	local Vector X,Y,Z;
	local Pawn zzPawnOwner;

	zzPawnOwner=Pawn(zzW.Owner);
	zzW.GetAxes(zzPawnOwner.ViewRotation,X,Y,Z);
	zzStartTrace=zzPawnOwner.Location + zzW.CalcDrawOffset() + zzW.FireOffset.X * X + zzW.FireOffset.Y * Y + zzW.FireOffset.Z * Z;
	if ( zzW.IsA('SniperRifle') )
	{
		zzStartTrace=zzPawnOwner.Location;
		zzStartTrace.Z += zzPawnOwner.EyeHeight;
	}
	return zzStartTrace;
}

function bool HasZPDisabled ()
{
	local zp_Manager zzM;
	local bool zzsDis;
	local bool zzcDis;
	local zp_Settings zzS;

	if ( zzW.Role < 4 )
	{
		zzcDis=Class'zp_Settings'.Default.zp_Disabled;
		zzsDis=Class'zp_Settings'.Default.sDisabled;
		if ( zzcDis != zzsDis )
		{
			foreach AllActors(Class'zp_Settings',zzS)
			{
				if (zzS != None) break;
			}
			if ( zzS != None )
			{
				zzS.rSetDisabled(zzcDis);
				zzsDis=zzcDis;
			}
		}
		return zzcDis;
	}
	if ( OwnerIsLocal() )
	{
		return True;
	}
	foreach AllActors(Class'zp_Manager',zzM)
	{
		if (zzM != None) break;
	}
	if ( zzM == None )
	{
		return False;
	}
	return zzM.HasZPDisabled(PlayerPawn(zzW.Owner));
}

function int xxzpHash (Pawn zzPlaya)
{
	local int zzret;
	local int zztemp;

	if ( (zzPlaya == None) || (zzPlaya.PlayerReplicationInfo == None) )
	{
		return 0;
	}
	if ( (zzPlaya.Level != zzW.Owner.Level) || zzPlaya.IsA('Spectator') )
	{
		return 0;
	}
	zzret=(zzPlaya.PlayerReplicationInfo.PlayerID + 3) * 5616893 % 62213;
	zzret=zzret << 16;
	zztemp=Pawn(zzW.Owner).PlayerReplicationInfo.Deaths * 7 + 145;
	zztemp=zztemp ^ zzPlaya.PlayerReplicationInfo.Deaths + 13;
	zztemp=zztemp * 5824571 % 59149;
	zzret=zzret ^ zztemp;
	zztemp=zztemp << 16;
	zzret=zzret ^ zztemp;
	return zzret;
}

function AdjustKeyBindings (PlayerPawn P)
{
	local int i;
	local string KeyName;
	local string KeyAlias;

	if ( P == None )
	{
		return;
	}
	i=0;
JL0014:
	if ( i < 255 )
	{
		KeyName=P.ConsoleCommand("KEYNAME " $ string(i));
		KeyAlias=P.ConsoleCommand("KEYBINDING " $ KeyName);
		if ( KeyAlias ~= "getweapon sniperrifle" )
		{
			P.ConsoleCommand("SET Input" @ KeyName @ KeyAlias @ "| mutate getweapon zp_sn");
		}
		if ( KeyAlias ~= "getweapon enforcer" )
		{
			P.ConsoleCommand("SET Input" @ KeyName @ KeyAlias @ "| mutate getweapon zp_e");
		}
		if ( KeyAlias ~= "getweapon shockrifle" )
		{
			P.ConsoleCommand("SET Input" @ KeyName @ KeyAlias @ "| mutate getweapon zp_sh");
		}
		i++;
		goto JL0014;
	}
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
}
