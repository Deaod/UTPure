// ============================================================
// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class bbCHSpectator expands CHSpectator;

// TNSe
// RC5p:
// Added: Ignore Speech & ShowInventory, to avoid server CPU Spike
// Added: ViewRotation.Roll = 0 to avoid problems with headshot when viewing in-eyes.
// RC5T:
// Added: Antispam for ViewClass/ViewPlayer/ViewPlayerNum
// Added: ShowPath to the ignores list in CheatFlying
// Fixed: exec function Jump accessed None
// Added: GotoState('CheatFlying') in PlayerWalking & PlayerSwimming
// RC5v:
// Added: Profile() to the ignoring.
// Added: New DoViewPlayerNum/DoViewClass to avoid server crashes.
// RC5y:
// Fixed: Teleport code to use ProcessMove instead of PlayerTick.
// RC54:
// Added: Anti-adminlogin bruteforce.
// RC55:
// Added: Spec leaves server notifies. (Destroyed())
// Added: Pause bug fix (Scoreboard/Time/HUD)
// RC7A:
// Changed: Removed the Destroyed() part, seems to crash clients on mapswitch (?)
// Added: Specfix into pure. (PlayerCalcView) - IN PROGRESS
// Fixed: 'FindFlag' should now work with some ascii names on linux too.

// Spectator Teleportation
var Teleporter zzLastTP;

// AntiSpam
var float zzLastView1,zzLastView2;
var int zzAdminLoginTries;

// Nice to have
var UTPure UTPure;

// Stats
var PureStats Stat;		// For player stats
var Class<PureStats> cStat;	// The class to use

// HitSounds
var globalconfig int HitSounds;

replication
{
	// Server -> Client
	reliable if (bNetOwner && ROLE == ROLE_Authority)
		Stat;
	// Client -> Server
	reliable if (ROLE < ROLE_Authority)
		ShowStats;
}


event PostBeginPlay()
{
	ForEach AllActors(Class'UTPure', UTPure)
		break;

	if (cStat != None)
		Stat = Spawn(cStat, Self);
	
	Super.PostBeginPlay();
}

event PostRender( canvas Canvas )
{
	local GameReplicationInfo GRI;
	
	if (Level.Pauser != "")				// Pause Fix/Hack.
		ForEach AllActors(Class'GameReplicationInfo',GRI)
		{
			if (GRI != None)
			{
				GRI.SecondCount = Level.TimeSeconds;
			}
		}

	if ( myHud != None )	
		myHUD.PostRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
	{
//		HUDType.Default.bAlwaysTick = True;
		myHUD = spawn(HUDType, self);
	}

	if (Stat != None && Stat.bShowStats)
	{
		Stat.PostRender( Canvas );
		return;
	}
}

// Fix the "roll" (upside/sideway view) bug.
event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( ViewTarget != None )
	{
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		PTarget = Pawn(ViewTarget);
		if ( PTarget != None )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer )
					PTarget.ViewRotation = TargetViewRotation;
				PTarget.EyeHeight = TargetEyeHeight;
				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
			}
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;
			if ( !bBehindView )
				CameraLocation.Z += PTarget.EyeHeight;
		}
		CameraRotation.Roll = 0;

		if ( bBehindView )
			CalcBehindView(CameraLocation, CameraRotation, 180);
		return;
	}

	ViewActor = Self;
	CameraLocation = Location;

	if( bBehindView ) //up and behind
		CalcBehindView(CameraLocation, CameraRotation, 150);
	else
	{
		// First-person view.
		CameraRotation = ViewRotation;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
	}
}

exec function Jump( optional float F )
{
	if (zzLastView2 != Level.TimeSeconds)
	{
		ViewClass(class'SpectatorCam', true);
		While ( (ViewTarget != None) && ViewTarget.IsA('SpectatorCam') && SpectatorCam(ViewTarget).bSkipView )
			ViewClass(class'SpectatorCam', true);
		if ( ViewTarget != None && ViewTarget.IsA('SpectatorCam') )
			bBehindView = false;
		zzLastView2 = Level.TimeSeconds;
	}
}

auto state CheatFlying
{
	ignores Speech,ShowInventory,ShowPath,Profile,ServerTaunt;

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)  
	{
		local Teleporter zzTP,zzDestTP;
		
		Super.ProcessMove(DeltaTime,NewAccel,DodgeMove,DeltaRot);

		ForEach RadiusActors(class 'Teleporter',zzDestTP,CollisionRadius,Location)
		{
			zzTP = zzDestTP;  // Using DEST as a temp var since it will NONE out.
		}

		if (zzTP != None)
		{
			if (zzLastTP != zzTP)
			{
				// Ok this isn't the last TP we touched...
				ForEach AllActors(class 'Teleporter',zzDestTP)
				{
					if (string(zzDestTP.Tag) ~= zzTP.URL)
					{
						zzLastTP = zzDestTP;
						zzTP.Touch(Self);
						return;
					}
				}
			}
		}
		else
		{
			zzLastTP = None;
		}
	}
}

state PlayerWalking
{
	function BeginState()
	{
		GotoState('CheatFlying');
	}
}

state PlayerSwimming
{
	function BeginState()
	{
		GotoState('CheatFlying');
	}
}

exec function ViewPlayerNum(optional int num)
{
	if (zzLastView1 != Level.TimeSeconds)
	{
		DoViewPlayerNum(num);
		zzLastView1 = Level.TimeSeconds;
	}
}

function DoViewPlayerNum(int num)
{
	local Pawn P;

	if ( num >= 0 )
	{
		P = Pawn(ViewTarget);
		if ( (P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.PlayerID == num) )
		{
			ViewTarget = None;
			bBehindView = false;
			return;
		}
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( (P.PlayerReplicationInfo != None) 
				&& !P.PlayerReplicationInfo.bIsSpectator
				&& (P.PlayerReplicationInfo.PlayerID == num) )
			{
				if ( P != self )
				{
					ViewTarget = P;
					bBehindView = true;
				}
				return;
			}
		return;
	}
	if ( Role == ROLE_Authority )
	{
		DoViewClass(class'Pawn', true);
		While ( (ViewTarget != None) 
				&& (!Pawn(ViewTarget).bIsPlayer || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator) )
			DoViewClass(class'Pawn', true);

		if ( ViewTarget != None )
			ClientMessage(ViewingFrom@Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
}

exec function ViewPlayer( string S )
{
	if (zzLastView1 != Level.TimeSeconds)
	{
		Super.ViewPlayer(S);
		zzLastView1 = Level.TimeSeconds;
	}
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	if (zzLastView2 != Level.TimeSeconds)
	{
		DoViewClass(aClass,bQuiet);
		zzLastView2 = Level.TimeSeconds;
	}
}

function DoViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, first;
	local bool bFound;

	if ( (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self)
			 && ( (bAdmin && Level.Game==None) || Level.Game.CanSpectate(self, other) ) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( first.IsA('Pawn') && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
				ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
			else
				ClientMessage(ViewingFrom@first, 'Event', true);
		}
		ViewTarget = first;
	}
	else
	{
		if ( !bQuiet )
		{
			if ( bFound )
				ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
			else
				ClientMessage(FailedView, 'Event', true);
		}
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

// Admin stuff
exec function Admin( string CommandLine )
{
	local string Result;
	if( bAdmin )
		Result = ConsoleCommand( CommandLine );
	else
		Result = "You are not administrator!";

	if( Result!="" )
		ClientMessage( Result );
}


exec function AdminLogin( string Password )
{
	zzAdminLoginTries++;
	Level.Game.AdminLogin( Self, Password );
	if (bAdmin)
	{
		zzAdminLoginTries = 0;
		Log("Admin is"@PlayerReplicationInfo.PlayerName, 'UTPure');
	}
	else if (zzAdminLoginTries == 5)
	{
		ClientMessage("Adminlogin failed, you have been removed from server!");
		Log(PlayerReplicationInfo.PlayerName@"failed to adminlogin 5 times, kicked!", 'UTPureCheat');
		Destroy();
	}
}

exec function AdminLogout()
{
	Level.Game.AdminLogout( Self );
	Log("Admin was"@PlayerReplicationInfo.PlayerName);
}

/* Causes client crashes on mapswitch?
simulated event Destroyed()
{
	Super.Destroyed();

	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastMessage( PlayerReplicationInfo.PlayerName$Class'GameInfo'.Default.LeftMessage, false );
}
*/

simulated function PlayHitSound()
{	
	local Actor SoundPlayer;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = Self;

	SoundPlayer.PlaySound(Sound'UnrealShare.StingerFire', SLOT_None, 16.0, True);
}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	// Handle hitsounds properly here before huds get it. Remove damage except if demoplayback :P
	if (Message == class'PureHitSound')
	{
		if (HitSounds == 0 || RelatedPRI_1 == None)
			return;			// Ignore
		if (HitSounds == 1)
			Sw = 0;			// don't display damage
	}
	Super.ReceiveLocalizedMessage(Message, Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

exec function HitSound(optional int hs)
{
	HitSounds = hs;
	if (hs == 0)
		ClientMessage("HitSounds Off!");
	else if (hs == 1)
		ClientMessage("HitSounds On!");
	else
		ClientMessage("HitSounds MAX!!!");
	SaveConfig();
}

exec function FindFlag()
{
	local PlayerReplicationInfo zzPRI,zzLastFC,zzFC;
	local PlayerPawn zzPP;
	
	zzPP = PlayerPawn(ViewTarget);

	if (zzPP != None && CTFFlag(zzPP.PlayerReplicationInfo.HasFlag) != None)
		zzLastFC = zzPP.PlayerReplicationInfo;

	ForEach AllActors(Class'PlayerReplicationInfo',zzPRI)
	{
		if (CTFFlag(zzPRI.HasFlag) != None)
		{
			zzFC = zzPRI;
			if (zzFC != zzLastFC) break;
		}
	}

	if (zzFC == None)
		ViewClass(Class'CTFFlag');
	else
		ViewPlayerNum(zzFC.PlayerID);
}

exec function ShowStats()
{
	if (Stat != None)
		Stat.SetState(0);
}

defaultproperties {
	HitSounds=1
}
