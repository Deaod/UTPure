//================================================================================
// Zeroping.
//================================================================================
class Zeroping expands Mutator;

var localized bool bAllowTranslocator;
var localized bool bLongDistance;

var string zp_Package;
var string zp_DefaultWeapon;
var string Decoration;
var zp_Manager Manager;
var bool Decorated;

function AddMutator (Mutator M)
{
	Log(Self@bAllowTranslocator);
	if ( M.IsA('Arena') )
	{
		Log(string(M) $ " not allowed.  Zeroping does not work with default arena mutators -- use a Zeroping arena mutator instead.");
		return;
	}
	Super.AddMutator(M);
}

function GiveWeapon (Pawn PlayerPawn, string aClassName, bool SwitchTo)
{
	local Class<Weapon> WeaponClass;
	local Weapon NewWeapon;

//	Log("GiveWeapon1"@PlayerPawn.PlayerReplicationInfo.PlayerName@aClassName);

	WeaponClass=Class<Weapon>(DynamicLoadObject(aClassName,Class'Class'));
	if ( PlayerPawn.FindInventoryType(WeaponClass) != None )
	{
		return;
	}
	NewWeapon=Spawn(WeaponClass,PlayerPawn,,PlayerPawn.Location);
//	Log("GiveWeapon2"@NewWeapon.ItemName@WeaponClass);
	if ( NewWeapon != None )
	{
		NewWeapon.RespawnTime=0.00;
		NewWeapon.GiveTo(PlayerPawn);
		NewWeapon.bHeldItem=True;
		NewWeapon.GiveAmmo(PlayerPawn);
		NewWeapon.SetSwitchPriority(PlayerPawn);
		NewWeapon.AmbientGlow=0;
		if ( PlayerPawn.IsA('PlayerPawn') )
		{
			NewWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		}
		else
		{
			NewWeapon.GotoState('Idle');
		}
		if ( PlayerPawn.Weapon != None )
		{
			PlayerPawn.Weapon.GotoState('DownWeapon');
		}
		PlayerPawn.PendingWeapon=None;
		if ( SwitchTo )
		{
			NewWeapon.WeaponSet(PlayerPawn);
			PlayerPawn.Weapon=NewWeapon;
		}
	}
}

function GiveZPDefaultWeapon (Pawn PlayerPawn)
{
	local Weapon W;

	GiveWeapon(PlayerPawn,zp_Package $ Class'UTPure'.Default.ThisVer $ zp_DefaultWeapon,True);
	W=Weapon(PlayerPawn.FindInventoryType(Class'ImpactHammer'));
	if ( W != None )
	{
		W.Destroy();
		GiveWeapon(PlayerPawn,"Botpack.ImpactHammer",False);
	}
	W=Weapon(PlayerPawn.FindInventoryType(Class'ChainSaw'));
	if ( W != None )
	{
		W.Destroy();
		GiveWeapon(PlayerPawn,"Botpack.Chainsaw",False);
	}
}

simulated function ModifyPlayer (Pawn Other)
{
	local int Id;

	Id=Other.PlayerReplicationInfo.PlayerID;
	if ( Manager.SettingsList[Id] != None )
	{
		Manager.SettingsList[Id].Destroy();
	}
	Manager.SettingsList[Id]=Spawn(Class'zp_Settings',Other);
	Manager.SettingsList[Id].PlayerID=Id;
	if ( Other.IsA('PlayerPawn') && (Other.PlayerReplicationInfo.Deaths < 1) )
	{
		Annoy(PlayerPawn(Other));
	}
	Super.ModifyPlayer(Other);
	if ( NextMutator != None )
	{
		NextMutator.ModifyPlayer(Other);
	}
	GiveZPDefaultWeapon(Other);
	if ( Other.IsA('PlayerPawn') )
	{
		AdjustKeyBindings(PlayerPawn(Other));
	}
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

event PreBeginPlay ()
{
	if ( Manager == None )
	{
		Manager=Spawn(Class'zp_Manager');
	}
	Class'zp_Server'.StaticSaveConfig();
	Super.PreBeginPlay();
	DecorateName();
}

function Annoy (PlayerPawn P)
{
	DecorateName();
	if ( (P != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Deaths == 0) )
	{
		P.ClientMessage("UTPure Zeroping -- version 1.00 -- http://forums.utpure.com");
		P.ClientMessage("Sniper rifle, shock rifle, enforcer and Instagib gun are lag-free.");
		P.ClientMessage("Type 'mutate zp_off' to disable Zeroping on your weapons");
	}
}

function DecorateName ()
{
	local string RealServerName;
	local int NameStart;

	if (  !Decorated && (Level != None) && (Level.Game != None) && (Level.Game.GameReplicationInfo != None) )
	{
		if ( Level.NetMode != 3 )
		{
			RealServerName=Level.Game.GameReplicationInfo.Default.ServerName;
			NameStart=InStr(RealServerName,Decoration);
JL009C:
			if ( NameStart != -1 )
			{
				RealServerName=Mid(RealServerName,NameStart + Len(Decoration));
				Level.Game.GameReplicationInfo.Default.ServerName=RealServerName;
				Level.Game.GameReplicationInfo.ServerName=RealServerName;
				Level.Game.GameReplicationInfo.SaveConfig();
				NameStart=InStr(RealServerName,Decoration);
				goto JL009C;
			}
			NameStart=InStr(RealServerName," ");
JL0155:
			if ( NameStart == 0 )
			{
				RealServerName=Mid(RealServerName,NameStart + 1);
				Level.Game.GameReplicationInfo.Default.ServerName=RealServerName;
				Level.Game.GameReplicationInfo.ServerName=RealServerName;
				Level.Game.GameReplicationInfo.SaveConfig();
				NameStart=InStr(RealServerName," ");
				goto JL0155;
			}
			Level.Game.GameReplicationInfo.ServerName=Decoration @ RealServerName;
		}
		Decorated=True;
	}
}

function bool CheckReplacement (Actor Other, out byte bSuperRelevant)
{
	local zp_Server NewServer;

	DecorateName();
	if ( Other.IsA('zp_Enforcer') )
	{
		zp_Enforcer(Other).zzbLongDistance = bLongDistance;
		if ( zp_Enforcer(Other).zzS == None )
		{
			NewServer=Spawn(Class'zp_Server');
			NewServer.GotoState('zp_Gun');
			NewServer.OriginalName='enforcer';
			NewServer.zzW=TournamentWeapon(Other);
			zp_Enforcer(Other).zzS=NewServer;
		}
	}
	if ( Other.IsA('zp_ShockRifle') )
	{
		if ( zp_ShockRifle(Other).zzS == None )
		{
			NewServer=Spawn(Class'zp_Server');
			NewServer.GotoState('zp_ShockRifle');
			NewServer.OriginalName='ShockRifle';
			NewServer.zzW=TournamentWeapon(Other);
			zp_ShockRifle(Other).zzS=NewServer;
		}
	}
	if ( Other.IsA('zp_SuperShockRifle') )
	{
		zp_SuperShockRifle(Other).zzbLongDistance = bLongDistance;
		if ( zp_SuperShockRifle(Other).zzS == None )
		{
			NewServer=Spawn(Class'zp_Server');
			NewServer.GotoState('zp_ShockRifle');
			NewServer.OriginalName='ShockRifle';
			NewServer.zzW=TournamentWeapon(Other);
			zp_SuperShockRifle(Other).zzS=NewServer;
		}
	}
	if ( Other.IsA('zp_SniperRifle') )
	{
		zp_SniperRifle(Other).zzbLongDistance = bLongDistance;
		if ( zp_SniperRifle(Other).zzS == None )
		{
			NewServer=Spawn(Class'zp_Server');
			NewServer.GotoState('zp_Gun');
			NewServer.OriginalName='SniperRifle';
			NewServer.zzW=TournamentWeapon(Other);
			zp_SniperRifle(Other).zzS=NewServer;
		}
	}
	if ( Other.IsA('SniperRifle') && !Other.IsA('zp_SniperRifle') )
	{
		ReplaceWith(Other,zp_Package $ Class'UTPure'.Default.ThisVer $ ".zp_SniperRifle");
		return False;
	}
	if ( Other.IsA('SuperShockRifle') && !Other.IsA('zp_SuperShockRifle') )
	{
		ReplaceWith(Other,zp_Package $ Class'UTPure'.Default.ThisVer $ ".zp_SuperShockRifle");
		return False;
	}
	if ( Other.IsA('ShockRifle') && !Other.IsA('zp_ShockRifle') && !Other.IsA('zp_SuperShockRifle') )
	{
		ReplaceWith(Other,zp_Package $ Class'UTPure'.Default.ThisVer $ ".zp_ShockRifle");
		return False;
	}
	if ( Other.IsA('enforcer') && !Other.IsA('zp_Enforcer') )
	{
		ReplaceWith(Other,zp_Package $ Class'UTPure'.Default.ThisVer $ ".zp_Enforcer");
		return False;
	}
	return True;
}

function Mutate (string MutateString, PlayerPawn Sender)
{
	if ( (MutateString ~= "getweapon zp_SniperRifle") || (MutateString ~= "getweapon zp_sn") )
	{
		Sender.ConsoleCommand("getweapon zp_SniperRifle");
	}
	if ( (MutateString ~= "getweapon zp_ShockRifle") || (MutateString ~= "getweapon zp_sh") )
	{
		Sender.ConsoleCommand("getweapon zp_ShockRifle");
	}
	if ( (MutateString ~= "getweapon zp_Enforcer") || (MutateString ~= "getweapon zp_e") )
	{
		Sender.ConsoleCommand("getweapon zp_Enforcer");
	}
	if ( MutateString ~= "zp_Off" )
	{
		Sender.ClientMessage("Zeroping disabled.");
		Sender.ClientMessage("Type 'mutate zp_on' to restore.");
		Sender.ClientMessage("This setting is saved in Zeroping.ini");
		Manager.SetDisabled(Sender,True);
	}
	if ( MutateString ~= "zp_On" )
	{
		Sender.ClientMessage("Zeroping enabled.");
		Sender.ClientMessage("Type 'mutate zp_off' to disable.");
		Sender.ClientMessage("This setting is saved in Zeroping.ini");
		Manager.SetDisabled(Sender,False);
	}
	if ( MutateString ~= "state" )
	{
		Sender.ClientMessage("Weapon State:" @ string(Sender.Weapon.GetStateName()));
	}
	if ( MutateString ~= "dec" )
	{
		DecorateName();
	}
	Super.Mutate(MutateString,Sender);
}

defaultproperties
{
    zp_Package="ZPPure"
    zp_DefaultWeapon=".zp_Enforcer"
    Decoration="zp|"
}
