// IMPURITY CODES
//
// BC - Bad Console, console has been replaced.
// BA - Bad Canvas, not Engine.Canvas
// SM - Server Move, too many server moves
// TF - True/False variables contain bad values (bytehacked?)
// IC - Illegal Console. Our console is not responding (bytehacked?)
// HR - HUD Illegally replaced too many times (>10)
// FM - Failed Mutator, Too many requests for bad mutators got sent to server (>50)
// RM - ReplicateMove called.
// AV - AVar cleaning haxx0red
// TB - xxStopTraceBot has been haxx0r3d.
// PT - Player Tick Counter was not 0 (Manual call to Player Tick)
// AL - Failed adminlogin 5 times.
// NC - More than 10 netspeed changes in a match.
// S1 - SpawnNotify was not last when rechecking
// S2 - SpawnNotify was not last during check.
// FF - FireFuck, someone messed with the xxCanFire() function
// ZD - Zone Defaults are modified.
// ZE - Other defaults are modified.
// TP - Teleport Aimbot
// HA - Canvas specific info changed after Console PostRender.
// BA - Bad Lighting!
// TD - Bad TimeDilation
// MS - View Shake changed at incorrect time
// MT - Mutator Custom Purestyle Kick
class bbPlayer extends TournamentPlayer
	config(User) abstract;

#exec Texture Import File=Textures\PUREShield.bmp Name=PUREShield Mips=Off
#exec Texture Import File=Textures\bootbit.bmp Name=PureBoots Mips=Off
#exec Texture Import File=Textures\hudbgplain.bmp Name=PureTimeBG Mips=Off


// Client Config
var globalconfig bool bNewNetCode;	// if Client wants new or old netcode. (default false)
var globalconfig bool bNoRevert;	// if Client does not want the Revert to Previous Weapon option on Translocator. (default false)
var globalconfig bool bForceModels;	// if Client wishes models forced to his own. (default false)
var globalconfig bool bHitSounds;	// if Client wishes hitsounds (default true, must be enabled on server)
var globalconfig bool bTeamInfo;	// if Client wants extra team info.
var globalconfig bool bDoEndShot;	// if Client wantsa Screenshot at end of match.
var globalconfig bool bDoDemo;		// if Client wants demo or not.
var globalconfig string DemoMask;	// The options for creating demo filename.
var globalconfig string DemoPath;	// The path for creating the demo.
var globalconfig string DemoChar;	// Character to use instead of illegal ones.

// Replicated settings Client -> Server
var bool	zzbConsoleInvalid;	// Should always be false on server.
var bool	zzbStoppingTraceBot;	// True while stopping Trace Bot
var int		zzNetspeed;		// The netspeed this client is using
var bool	zzbForcedTick;		// True on server if Tick was forced (Called more than once)
var bool	zzbBadCanvas;		// True on server if Canvas is NOT engine.canvas
var bool	zzbVRChanged;		// True on server if client changed viewrotation at wrong time.
var bool	zzbDemoRecording;	// True if client is recording demos.
var bool	zzbBadLighting;		// True if Lighting is not good on client (HAX!)
var float	zzClientTD;		// Client TimeDilation (Should always be same as server or HAX!)
var bool	zzbBadMaxShake;		// True on server if MaxShake mysteriously changed.

// Replicated settings Server -> Client
var Weapon	zzWeapon;		// Contains the current weapon.
var int		zzTrackFOV;		// Track FOV ?
var bool	zzCVDeny;		// Deny CenterView ?
var float	zzCVDelay;		// Delay for CenterView usage
var int		zzMinimumNetspeed;	// Default 1000, it's the minimum netspeed a client may have.
var float	zzWaitTime;		// Used for diverse waiting.
var bool	zzbWeaponTracer;	// True if current weapon is a tracer!
var int		zzForceSettingsLevel;	// The Anti-Default/Ini check force.
var byte	zzHitSounds;		// 0 = Totally disabled. 1 = Enabled. 2 = Teamhitsounds.
var byte	zzHUDInfo;		// 0 = Off, 1 = boots/timer, 2 = Team Info too.
var bool	zzbForceDemo;		// Set true by server to force client to do demo.
var bool	zzbGameStarted;		// Set to true when Pawn spawns first time (ModifyPlayer)
var PlayerReplicationInfo zzPlayerReplicationInfo;	// Contains the actual PlayerReplicationInfo
var GameReplicationInfo zzGameReplicationInfo;		// Contains actual GameReplicationInfo

// Control stuff
var byte	zzbFire;		// Retain last fire value
var byte	zzbAltFire;		// Retain last Alt Fire Value
var bool	zzbValidFire;		// Tells when Fire() is valid
var bool	zzShowClick;		// Show Click Status
var bool	zzbDonePreRender;	// True between PreRender & PostRender
var PureInfo	zzInfoThing;		// Registers diverse stuff.
var float	zzTick;			// The Length of Last Tick
var bool	zzbDemoPlayback;	// Is currently a demo playback (via xxServerMove detection)
var bool	zzbNoMultiWeapon;	// Server-Side only! tells if multiweapon bug can be used.
var float	zzRealMaxShake;		// The REAL MaxShake!

// Stuff
var rotator	zzViewRotation;		// Our special View Rotation
var rotator	zzLastVR;		// The rotation after previous input.
var float	zzDesiredFOV;		// Needed ?
var float	zzOrigFOV;		// Original FOV for TrackFOV = 1
var string	FakeClass;		// Class that the model replaces
var string	zzMyPacks;		// Defined only for defaults
var bool	zzbBadGuy;		// BadGuy! (Avoid kick spamming)
var float	MaxPosError;		// Maximum Positioning error.
var int		zzOldForceSettingsLevel;// Kept to see if things change.
var bool	bFWS;			// Enable FWS for all weapons.
var float	zzPingAdjust;		// Ping Adjustment.
var PlayerReplicationInfo zzStoredPRI[32];	// Original PRI's
var string	zzComputerName;		// Clients Computername.

// HUD stuff
var Mutator	zzHudMutes[50];		// Accepted Hud Mutators
var Mutator	zzWaitMutes[50];	// Hud Mutes waiting to be accepted
var float	zzWMCheck[50];		// Key value
var int		zzFailedMutes;		// How many denied Mutes have been tried to add
var int		zzHMCnt;		// Counts of HudMutes and WaitMutes
var HUD		zzmyHud;		// our own personal hud
var Class<HUD>	zzHUDType;		// The HUD Type
var Scoreboard	zzScoring;		// The scoreboard.
var Class<Scoreboard> zzSBType;		// The Scoreboard Type
var Class<ServerInfo> zzSIType;		// The ServerInfo Type
var int		zzHUDWarnings;		// Counts the # of times the HUD has been changed
var bool	zzbRenderHUD;		// Do not start rendering HUD until logo has been displayed for a while

// Logo Display
var bool	zzbLogoDone;		// Are we done with the logo ?
var float	zzLogoStart;		// Start of logo display

var Teleporter	zzTP;			// Temp Teleporter holder
var name	zzTPE;			// Teleporter previous Event
var int		zzSMCnt;		// ServerMove Count
var bool	bMenuFixed;		// Fixed Menu item
var float	zzCVTO;			// CenterView Time out.
var bool	zzbCanCSL;		// Console sets this to true if they are allowed to CSL

// Consoles & Canvas
var Console	zzOldConsole;
var PureSuperDuperUberConsole	zzMyConsole;
var bool	zzbBadConsole;
var Canvas zzCannibal;			// Old console
var font zzCanOldFont;			// Canvas messing checks
var byte zzCanOldStyle;			// And more

// Anti Timing Variables
var Inventory	zzAntiTimerList[32];
var int		zzAntiTimerListState;
var int		zzAntiTimerListCount;
var int		zzAntiTimerFlippedCount;

// duh:
var bool zzTrue,zzFalse;		// True & False
var int zzNull;				// == 0

// Avoiding spam:
var string zzDelayedName;
var int zzNameChanges;			// How many times has name been changed
var Class<ChallengeVoicePack> zzDelayedVoice;
var float zzDelayedStartTime;
var float zzLastSpeech;
var float zzLastTaunt;
var float zzLastView,zzLastView2;
var int zzKickReady;
var int zzAdminLoginTries;
var int zzOldNetspeed,zzNetspeedChanges;

// MD5 Things
var bool zzbDidMD5;			// True when MD5 checks are completed.
var bool zzbMD5RequestSent;		// Server side, to decide if requests for MD5 has been sent.

// Fixing demo visual stuff
var int zzRepVRYaw, zzRepVRPitch;
var float zzRepVREye;
var bool zzbRepVRData;

// ConsoleCommand/INT Reader/Key+Alias Handling
var string zzRemResult;		// Temporary Variable to store ConsoleCommands
var string zzRemCmd;		// The command the server sent.
var bool bRemValid;		// True when valid.

var UTPure zzUTPure;		// The UTPure mutator.

var bool zzbDoScreenshot;	// True when we are about to do screenshot
var bool zzbReportScreenshot;	// True when reporting the screenshot.
var string zzMagicCode;		// The magic code to display.

var string zzPrevClientMessage;	// To log client messages...

var float LastTeleport;		// Last Time you went into a teleport.
var Teleporter zzLastTP;

var PureStats zzStat;		// For player stats
var PureStatMutator zzStatMut;	// The mutator that receives special calls

var PureLevelBase PureLevel;	// And Level.
var PurePlayer PurePlayer;	// And player.

replication
{
	//	Client->Demo
	unreliable if( bClientDemoRecording )
		xxReplicateVRToDemo, xxClientDemoMessage, xxClientLogToDemo;

	// Server->Client
	unreliable if( bNetOwner && ROLE == ROLE_Authority)
		zzTrackFOV, zzCVDeny, zzCVDelay, zzShowClick, zzMinimumNetspeed,
		zzWaitTime,zzAntiTimerList,zzAntiTimerListCount,zzAntiTimerListState,
		zzWeapon, zzbDidMD5, zzStat;

	// Server->Client
	reliable if ( bNetOwner && ROLE == ROLE_Authority )
		zzHUDType, zzSBType, zzSIType, xxClientAcceptMutator, zzbWeaponTracer, zzForceSettingsLevel,
		zzHitSounds, zzHUDInfo, zzbForceDemo, zzbGameStarted,
		zzPlayerReplicationInfo, zzGameReplicationInfo;

	//Server->Client function reliable.. no demo propogate! .. bNetOwner? ...
	reliable if ( bNetOwner && ROLE == ROLE_Authority && !bDemoRecording)
		xxCheatFound,xxClientMD5,xxClientSet,xxClientDoScreenshot,xxClientDoEndShot,xxClientConsole,
		xxClientKeys,xxClientReadINT;

	// Server->Client function.
	unreliable if (RemoteRole == ROLE_AutonomousProxy)
		xxPureCAP,xxPureCAPLevelBase,					// ClientAdjustPosition (vector based)
		xxPureCAPWalking,
		xxPureCAPWalkingWalkingLevelBase,xxPureCAPWalkingWalking;

	// Server->Client function.
	unreliable if (RemoteRole == ROLE_AutonomousProxy)
		xxCAP,xxCAPLevelBase,						// ClientAdjustPosition (float based)
		xxCAPWalking,
		xxCAPWalkingWalkingLevelBase,xxCAPWalkingWalking;

	// Client->Server
	unreliable if( ROLE < ROLE_Authority )
		xxServerMove, xxServerCheater,
		zzbConsoleInvalid, zzFalse, zzTrue, zzNetspeed, zzbBadConsole, zzbBadCanvas, zzbVRChanged,
		zzbStoppingTraceBot, zzbForcedTick, zzbDemoRecording, zzbBadLighting, zzClientTD, zzbBadMaxShake;

	// Client->Server
	reliable if ( ROLE < ROLE_Authority)
		xxServerCheckMutator,xxServerTestMD5,xxServerSetNetCode,xxSet,
		xxServerReceiveMenuItems,xxServerSetNoRevert,xxServerSetReadyToPlay,Hold,Go,
		xxServerSetHitSounds, xxServerSetTeamInfo, ShowStats,
		xxServerAckScreenshot, xxServerReceiveConsole, xxServerReceiveKeys, xxServerReceiveINT,
		xxServerDemoReply;
}

event PostBeginPlay()
{
	if (DeathMatchPlus(Level.Game) != None)
		zzShowClick =  DeathMatchPlus(Level.Game).bTournament;

	Super.PostBeginPlay();

	if ( Level.NetMode != NM_Client )
	{
		zzHUDType = HUDType;
		zzSBType  = ScoringType;
		zzSIType  = zzUTPure.zzSI;
		zzGameReplicationInfo = Level.Game.GameReplicationInfo;
		zzPlayerReplicationInfo = PlayerReplicationInfo;
		zzbCanCSL = True;
		zzMinimumNetspeed = Class'UTPure'.Default.MinClientRate;
		zzWaitTime = 3.0;
	}
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	if ( Role != ROLE_SimulatedProxy )	// Other players are Simulated, local player is Autonomous or Authority (if listen server which pure doesn't support anyway :P)
	{
		return;
	}

	zzbValidFire = zzTrue;

	if ( bIsMultiSkinned )
	{
		if ( MultiSkins[1] == None )
		{
			if ( bIsPlayer && PlayerReplicationInfo != None)
				SetMultiSkin(self, "","", PlayerReplicationInfo.team);
			else
				SetMultiSkin(self, "","", 0);
		}
	}
	else if ( Skin == None )
		Skin = Default.Skin;


	if ( (PlayerReplicationInfo != None)
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(self);
}

event Possess()
{
	local int zzx;
	local class<PureInfo> cPureInfo;

	if ( Level.Netmode == NM_Client )
	{	// Only do this for clients.
		zzTrue = !zzFalse;
		zzInfoThing = Spawn(Class'PureInfo');
		xxServerSetNetCode(bNewNetCode);
		xxServerSetNoRevert(bNoRevert);
		xxServerSetHitSounds(bHitSounds);
		xxServerSetTeamInfo(bTeamInfo);
		if (class'UTPlayerClientWindow'.default.PlayerSetupClass != class'UTPureSetupScrollClient')
			class'UTPlayerClientWindow'.default.PlayerSetupClass = class'UTPureSetupScrollClient';
		// This blocks silly set commands by kicking player, after resetting them.
		if (	Class'ZoneInfo'.Default.AmbientBrightness != 0		||
			Class'ZoneInfo'.Default.AmbientSaturation != 255	||
			Class'LevelInfo'.Default.AmbientBrightness != 0		||
			Class'LevelInfo'.Default.AmbientSaturation != 255	||
			Class'WaterZone'.Default.AmbientBrightness != 0		||
			Class'WaterZone'.Default.AmbientSaturation != 255)
		{
			Class'ZoneInfo'.Default.AmbientBrightness = 0;
			Class'ZoneInfo'.Default.AmbientSaturation = 255;
			Class'LevelInfo'.Default.AmbientBrightness = 0;
			Class'LevelInfo'.Default.AmbientSaturation = 255;
			Class'WaterZone'.Default.AmbientBrightness = 0;
			Class'WaterZone'.Default.AmbientSaturation = 255;
			xxServerCheater(chr(90)$chr(68));		// ZD
		}
		if (	Class'WaterTexture'.Default.bInvisible		||
			Class'Actor'.Default.Fatness != 128		||
			Class'PlayerShadow'.Default.DrawScale != 0.5	||
			Class'PlayerShadow'.Default.Texture != Texture'Botpack.EnergyMark')
		{
			Class'WaterTexture'.Default.bInvisible = False;
			Class'Actor'.Default.Fatness = 128;
			Class'PlayerShadow'.Default.DrawScale = 0.5;
			Class'PlayerShadow'.Default.Texture = Texture'Botpack.EnergyMark';
			xxServerCheater(chr(90)$chr(69));		// ZE
		}
		SetPropertyText("PureLevel", GetPropertyText("xLevel"));
		SetPropertyText("PurePlayer", GetPropertyText("Player"));
	}
	Super.Possess();
}

function ClientSetLocation( vector zzNewLocation, rotator zzNewRotation )
{
	if (zzbCanCSL ||
	     (zzNewRotation.Roll == 0 && zzNewRotation == ViewRotation &&
	      (WarpZoneInfo(Region.Zone) != None || WarpZoneInfo(HeadRegion.Zone) != None || WarpZoneInfo(FootRegion.Zone) != None)))
	{
		zzViewRotation      = zzNewRotation; // mm..
		ViewRotation		= zzNewRotation; // mm.. even more !
		If ( (zzViewRotation.Pitch > RotationRate.Pitch) && (zzViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (zzViewRotation.Pitch < 32768)
				zzNewRotation.Pitch = RotationRate.Pitch;
			else
				zzNewRotation.Pitch = 65536 - RotationRate.Pitch;
		}
		zzNewRotation.Roll  = 0;
		SetRotation( zzNewRotation );
		SetLocation( zzNewLocation );
}


event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (Message == class'CTFMessage2' && PureFlag(PlayerReplicationInfo.HasFlag) != None)
		return;

	// Handle hitsounds properly here before huds get it. Remove damage except if demoplayback :P
	if (Message == class'PureHitSound')
	{
		if (zzHitSounds == 0 || RelatedPRI_1 == None)
			return;			// Ignore
		if (zzHitSounds != 3)		// Let it through every check :P
		{
			if (zzHitSounds == 2 || (zzHitSounds == 1 && !GameReplicationInfo.bTeamGame))
			{	// Only do LOS check if it's not teamgame or mode 2.
				if (RelatedPRI_1.Owner == None || !FastTrace(RelatedPRI_1.Owner.Location))
					return;
				Sw = 0;
			}
			else if (zzHitSounds == 1 && RelatedPRI_1.Team != PlayerReplicationInfo.Team)
			{	// Must be zzHitSounds == 1
				if (RelatedPRI_1.Owner == None || !FastTrace(RelatedPRI_1.Owner.Location))
					return;
				Sw = 0;
			}
			else
				return;
		}
	}

	Super.ReceiveLocalizedMessage(Message, Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

event PlayerTick( float Time )
{
	zzbCanCSL = zzFalse;
	xxPlayerTickEvents();
	zzTick = Time;
}

function ClientSetRotation( rotator zzNewRotation )
{
    // TNSe: I don't like this, it's waaaaaaaay too easy to bytehack.

	if (zzbCanCSL)
	{
		ViewRotation		= zzNewRotation;
		zzNewRotation.Pitch = 0;
		zzNewRotation.Roll  = 0;
		SetRotation( zzNewRotation );
	}
}

simulated function xxClientDemoMessage(string zzS)
{
	if (zzS == zzPrevClientMessage)
		return;
	ClientMessage(zzS);
}

event ClientMessage( coerce string zzS, optional Name zzType, optional bool zzbBeep )
{
	zzPrevClientMessage = zzS;

	xxClientDemoMessage(zzS);
	Super.ClientMessage(zzS, zzType, zzbBeep);
	zzPrevClientMessage = "";
}

event bool PreTeleport( Teleporter zzInTeleporter )
{
	zzTP = zzInTeleporter;
	zzTPE = zzTP.Event;
	zzTP.Event = 'UTPure';
	Tag = 'UTPure';
	return False;
}

event Trigger( Actor zzOther, Pawn zzEventInstigator )
{
	local Actor zzA;

	// Only way we get triggered is from Teleport
	if (zzTP != None)
	{
		zzTP.Event = zzTPE;
		zzTP = None;
		Tag = '';
		// Be nice and call std event
		zzViewRotation = Rotation;
		ViewRotation = Rotation;
		if (zzTPE != '')
			foreach AllActors( class 'Actor', zzA, zzTPE )
				zzA.Trigger( zzOther, zzEventInstigator );
	}
}


function rotator GR()
{
	return zzViewRotation;
}

event UpdateEyeHeight(float zzDeltaTime)
{
	local float zzsmooth, zzbound;

	// smooth up/down stairs
	If( (Physics==PHYS_Walking) && !bJustLanded )
	{
		zzsmooth = FMin(1.0, 10.0 * zzDeltaTime/Level.TimeDilation);
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - zzsmooth) + ( ShakeVert + BaseEyeHeight) * zzsmooth;
		zzbound = -0.5 * CollisionHeight;
		if (EyeHeight < zzbound)
			EyeHeight = zzbound;
		else
		{
			zzbound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight);
			if ( EyeHeight > zzbound )
				EyeHeight = zzbound;
		}
	}
	else
	{
		zzsmooth = FClamp(10.0 * zzDeltaTime/Level.TimeDilation, 0.35,1.0);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - zzsmooth) + (BaseEyeHeight + ShakeVert) * zzsmooth;
	}

	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * zzDeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.9 * zzDeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{
		ZoomLevel += zzDeltaTime;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}
	xxCheckFOV();
}

function xxCheckFOV()
{
	if (zzTrackFOV == 1)
	{
		if (zzOrigFOV < 80)
		{
			if (DesiredFOV < 80)
				DesiredFOV = 90;
			zzOrigFOV = DesiredFOV;
		}
		if (zzOrigFOV != DesiredFOV && (Weapon == None || !Weapon.IsA('SniperRifle')))
		{
			DesiredFOV = zzOrigFOV;
			FOVAngle = zzOrigFOV;
		}
	}
	else if (zzTrackFOV == 2)
	{
		if ((DesiredFOV < 80 || FOVAngle < 80) && (Weapon == None || !Weapon.IsA('SniperRifle')))
		{
			if (zzOrigFOV < 80)
			{
				if (DesiredFOV < 80)
					DesiredFOV = 90;
				zzOrigFOV = DesiredFOV;
			}
			DesiredFOV = zzOrigFOV;
			FOVAngle = zzOrigFOV;
		}
	}
}

event PlayerInput( float DeltaTime )
{
	local float SmoothTime, FOVScale, MouseScale, AbsSmoothX, AbsSmoothY, MouseTime;

	if ( bShowMenu && (zzMyHud != None) )
	{
		// clear inputs
		bEdgeForward = false;
		bEdgeBack = false;
		bEdgeLeft = false;
		bEdgeRight = false;
		bWasForward = false;
		bWasBack = false;
		bWasLeft = false;
		bWasRight = false;
		aStrafe = 0;
		aTurn = 0;
		aForward = 0;
		aLookUp = 0;
		return;
	}

	// Check for Dodge move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe > 0));
	bEdgeRight = (bWasRight ^^ (aStrafe < 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe > 0);
	bWasRight = (aStrafe < 0);

	// Smooth and amplify mouse movement
	SmoothTime = FMin(0.2, 3 * DeltaTime * Level.TimeDilation);
	FOVScale = DesiredFOV * 0.01111;
	MouseScale = MouseSensitivity * FOVScale;

	aMouseX *= MouseScale;
	aMouseY *= MouseScale;

//************************************************************************

	AbsSmoothX = SmoothMouseX;
	AbsSmoothY = SmoothMouseY;
	MouseTime = (Level.TimeSeconds - MouseZeroTime)/Level.TimeDilation;
	if ( bMaxMouseSmoothing && (aMouseX == 0) && (MouseTime < MouseSmoothThreshold) )
	{
		SmoothMouseX = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothX/MouseSmoothThreshold;
		BorrowedMouseX += SmoothMouseX;
	}
	else
	{
		if ( (SmoothMouseX == 0) || (aMouseX == 0)
				|| ((SmoothMouseX > 0) != (aMouseX > 0)) )
		{
			SmoothMouseX = aMouseX;
			BorrowedMouseX = 0;
		}
		else
		{
			SmoothMouseX = 0.5 * (SmoothMouseX + aMouseX - BorrowedMouseX);
			if ( (SmoothMouseX > 0) != (aMouseX > 0) )
			{
				if ( AMouseX > 0 )
					SmoothMouseX = 1;
				else
					SmoothMouseX = -1;
			}
			BorrowedMouseX = SmoothMouseX - aMouseX;
		}
		AbsSmoothX = SmoothMouseX;
	}
	if ( bMaxMouseSmoothing && (aMouseY == 0) && (MouseTime < MouseSmoothThreshold) )
	{
		SmoothMouseY = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothY/MouseSmoothThreshold;
		BorrowedMouseY += SmoothMouseY;
	}
	else
	{
		if ( (SmoothMouseY == 0) || (aMouseY == 0)
				|| ((SmoothMouseY > 0) != (aMouseY > 0)) )
		{
			SmoothMouseY = aMouseY;
			BorrowedMouseY = 0;
		}
		else
		{
			SmoothMouseY = 0.5 * (SmoothMouseY + aMouseY - BorrowedMouseY);
			if ( (SmoothMouseY > 0) != (aMouseY > 0) )
			{
				if ( AMouseY > 0 )
					SmoothMouseY = 1;
				else
					SmoothMouseY = -1;
			}
			BorrowedMouseY = SmoothMouseY - aMouseY;
		}
		AbsSmoothY = SmoothMouseY;
	}
	if ( (aMouseX != 0) || (aMouseY != 0) )
		MouseZeroTime = Level.TimeSeconds;

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 )
	{
		// Strafe.
		aStrafe += aBaseX + SmoothMouseX;
		aBaseX   = 0;
	}
	else
	{
		// Forward.
		aTurn  += aBaseX * FOVScale + SmoothMouseX;
		aBaseX  = 0;
	}

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else
	{
		// Move forward/backward.
		aForward += SmoothMouseY;
	}
	SmoothMouseX = AbsSmoothX;
	SmoothMouseY = AbsSmoothY;

	if ( bSnapLevel != 0 && !bAlwaysMouseLook && !zzCVDeny && (Level.TimeSeconds - zzCVTO) > zzCVDelay )
	{
		zzCVTO = Level.TimeSeconds;
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	if (zzSMCnt == 0)
		Log("SM Attempt to cheat by"@PlayerReplicationInfo.PlayerName, 'UTCheat');

	zzSMCnt++;
	if (zzSMCnt > 30)
	{
		xxServerCheater("SM");
	}
}

// ClientAdjustPosition - pass newloc and newvel in components so they don't get rounded

function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
}

// OLD STYLE (3xfloat) CAP

function xxCAP(float TimeStamp, name newState, EPhysics newPhysics,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp, newState, newPhysics,Loc,Vel,NewBase);
}

function xxCAPLevelBase(float TimeStamp, name newState, EPhysics newPhysics,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,newState,newPhysics,Loc,Vel,Level);
}

function xxCAPWalking(float TimeStamp, EPhysics newPhysics,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,'PlayerWalking',newPhysics,Loc,Vel,NewBase);
}

function xxCAPWalkingWalkingLevelBase(float TimeStamp,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,'PlayerWalking',PHYS_Walking,Loc,Vel,Level);
}

function xxCAPWalkingWalking(float TimeStamp,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,'PlayerWalking',PHYS_Walking,Loc,Vel,NewBase);
}

// NEW STYLE (vector based) CAP

function xxPureCAP(float TimeStamp, name newState, EPhysics newPhysics, vector NewLoc, vector NewVel, Actor NewBase)
{
	local Decoration Carried;
	local vector OldLoc;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	zzPingAdjust = Level.TimeSeconds - CurrentTimeStamp;

	Velocity = NewVel;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLoc += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$Location);
	Carried = CarriedDecoration;
	OldLoc = Location;

	bCanTeleport = false;
	SetLocation(NewLoc);
	bCanTeleport = true;

	if ( Carried != None )
	{
		CarriedDecoration = Carried;
		CarriedDecoration.SetLocation(NewLoc + CarriedDecoration.Location - OldLoc);
		CarriedDecoration.SetPhysics(PHYS_None);
		CarriedDecoration.SetBase(self);
	}
	SetPhysics(newPhysics);

	if ( !IsInState(newState) )
		GotoState(newState);

	bUpdatePosition = true;
}

function xxPureCAPLevelBase(float TimeStamp, name newState, EPhysics newPhysics, vector NewLoc, vector NewVel)
{
	xxPureCAP(TimeStamp,newState,newPhysics,NewLoc,NewVel,Level);
//	Log("CAPLevelBase");
}

function xxPureCAPWalking(float TimeStamp, EPhysics newPhysics, vector NewLoc, vector NewVel, Actor NewBase)
{
	xxPureCAP(TimeStamp,'PlayerWalking',newPhysics,NewLoc,NewVel,NewBase);
//	Log("CAPWalking");
}

function xxPureCAPWalkingWalkingLevelBase(float TimeStamp, vector NewLoc, vector NewVel)
{
	xxPureCAP(TimeStamp,'PlayerWalking',PHYS_Walking,NewLoc,NewVel,Level);
//	Log("CAPWalkingWalkingLevelBase");
}

function xxPureCAPWalkingWalking(float TimeStamp, vector NewLoc, vector NewVel, Actor NewBase)
{
	xxPureCAP(TimeStamp,'PlayerWalking',PHYS_Walking,NewLoc,NewVel,NewBase);
//	Log("CAPWalkingWalking");
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.DodgeMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
		}
	}
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
}

function xxServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;
	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDodgeDir OldDodgeMove;
	local name zzMyState;

	if (ROLE < ROLE_Authority)
	{
		zzbDidMD5 = True;
		zzbLogoDone = True;
		zzbRenderHUD = True;
		zzTrackFOV = 0;
		zzbDemoPlayback = True;
		return;
	}

	if (bFWS && PendingWeapon != None)
		ChangedWeapon();

	zzbWeaponTracer = (Health > 0) && (Weapon != None && (Weapon.bInstantHit || Weapon.bAltInstantHit));

	//////////////
	// CRC stuff:
	if (!zzbMD5RequestSent)
	{
		xxClientMD5(zzUTPure.zzPurePackageName, zzUTPure.zzMD5KeyInit);
		zzbMD5RequestSent = True;
	}
	if (!zzbDidMD5)
	{
		CurrentTimeStamp = TimeStamp;
		ServerTimeStamp = Level.TimeSeconds;
		Acceleration = vect(0,0,0);
		return;
	}

	// SHOULD NEVER BE TRUE ON SERVER
	if (zzbBadConsole)
		xxServerCheater("BC");
	if (zzbBadCanvas)
		xxServerCheater("BA");
	if (TimeStamp > 20.0)
	{
		if (zzFalse || !zzTrue)	// Wait 20 seconds before checking this to allow repl.
			xxServerCheater("TF");
		if (zzClientTD != Level.TimeDilation)
			xxServerCheater("TD");
	}
	if (zzbConsoleInvalid)
		xxServerCheater("IC");
	if (zzbForcedTick && !zzUTPure.zzbPaused)
		xxServerCheater("FT");		// This will arrive shortly after a pause unfortunately :P

	if (zzbVRChanged)			// View rotation changed on client at wrong time!
		xxServerCheater("VR");

	if (zzbBadLighting)
		xxServerCheater("BL");

	if (zzbBadMaxShake)
		xxServerCheater("MS");

	zzKickReady = Max(zzKickReady - 1,0);

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;

			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDodgeMove = DODGE_None;
					break;
				case 1:
					OldDodgeMove = DODGE_Left;
					break;
				case 2:
					OldDodgeMove = DODGE_Right;
					break;
				case 3:
					OldDodgeMove = DODGE_Forward;
					break;
				case 4:
					OldDodgeMove = DODGE_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// handle firing and alt-firing
	if ( bFired )
	{
		if ( bForceFire && (Weapon != None) )
			Weapon.ForceFire();
		else if ( bFire == 0 )
			Fire(0);
		bFire = 1;
	}
	else
		bFire = 0;


	if ( bAltFired )
	{
		if ( bForceAltFire && (Weapon != None) )
			Weapon.ForceAltFire();
		else if ( bAltFire == 0 )
			AltFire(0);
		bAltFire = 1;
	}
	else
		bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768)
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);

// Big changes Upcoming here....

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )	// Was 500.0 / Player.CurrentNetSpeed
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 200.0/Player.CurrentNetSpeed )	// Was 180.0/netspeed
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > MaxPosError )	// 3 = 0.999..*0.999... * 3 (3 parts of vector close to 1 in the Dot), *2 for 2 way error.
	{
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
		LastUpdateTime = Level.TimeSeconds;
		zzMyState = GetStateName();
		if (bNewNetCode)
		{
			if (zzMyState == 'PlayerWalking')
			{
				if (Physics == PHYS_Walking)
				{
					if (Base == Level)
						xxPureCAPWalkingWalkingLevelBase(TimeStamp, ClientLoc, Velocity);
					else
						xxPureCAPWalkingWalking(TimeStamp, ClientLoc, Velocity, Base);
				}
				else
				{
					xxPureCAPWalking(TimeStamp, Physics, ClientLoc, Velocity, Base);
				}
			}
			else
			{
				if (Base == Level)
					xxPureCAPLevelBase(TimeStamp, zzMyState, Physics, ClientLoc, Velocity);
				else
					xxPureCAP(TimeStamp, zzMyState, Physics, ClientLoc, Velocity, Base);
			}
		}
		else
		{
			if (zzMyState == 'PlayerWalking')
			{
				if (Physics == PHYS_Walking)
				{
					if (Base == Level)
						xxCAPWalkingWalkingLevelBase(TimeStamp, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z);
					else
						xxCAPWalkingWalking(TimeStamp, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);
				}
				else
				{
					xxCAPWalking(TimeStamp, Physics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);
				}
			}
			else
			{
				if (Base == Level)
					xxCAPLevelBase(TimeStamp, zzMyState, Physics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z);
				else
					xxCAP(TimeStamp, zzMyState, Physics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);
			}
		}
	}
}

function xxServerReceiveMenuItems(string zzMenuItem, bool zzbLast)
{
	Mutate("PMI"@zzMenuItem@byte(zzbLast));
}

exec function Fire( optional float F )
{
	if (xxCanFire())
		Super.Fire(F);
}

exec function AltFire( optional float F)
{
	if (xxCanFire())
		Super.AltFire(F);
}

function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	xxServerCheater("RM");
}

function xxReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds;
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
		PendingMove.bRun = (bRun > 0);
		PendingMove.bDuck = (bDuck > 0);
		PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	// Set this move's data.
	NewMove.DodgeMove = DodgeMove;
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;
	NewMove.bFire = (bJustFired || (bFire != 0));
	NewMove.bForceFire = bJustFired;
	NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire = bJustAltFired;
	if ( Weapon != None ) // approximate pointing so don't have to replicate
		Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));
	bJustFired = false;
	bJustAltFired = false;

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
	AutonomousPhysics(NewMove.Delta);
	if (Role < ROLE_Authority)
	{
		zzbValidFire = false;
		zzbFire = bFire;
		zzbAltFire = bAltFire;
	}

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);

	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23)
					+ (CompressAccel(BuildAccel.Y) << 15)
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DodgeMove;
	}

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	xxServerMove
	(
		NewMove.TimeStamp,
		NewMove.Acceleration * 10,
		Location,
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus,
		NewMove.bFire,
		NewMove.bAltFire,
		NewMove.bForceFire,
		NewMove.bForceAltFire,
		NewMove.DodgeMove,
		ClientRoll,
		(32767 & (zzViewRotation.Pitch/2)) * 32768 + (32767 & (zzViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel
	);
	if ( (Weapon != None) && !Weapon.IsAnimating() )
	{
		if ( (Weapon == ClientPending) || (Weapon != OldClientWeapon) )
		{
			if ( Weapon.IsInState('ClientActive') )
				AnimEnd();
			else
				Weapon.GotoState('ClientActive');
			if ( (Weapon != ClientPending) && (zzMyHUD != None) && zzMyHUD.IsA('ChallengeHUD') )
				ChallengeHUD(zzMyHUD).WeaponNameFade = 1.3;
			if ( (Weapon != OldClientWeapon) && (OldClientWeapon != None) )
				OldClientWeapon.GotoState('');

			ClientPending = None;
			bNeedActivate = false;
		}
		else
		{
			Weapon.GotoState('');
			Weapon.TweenToStill();
		}
	}
	OldClientWeapon = Weapon;
}


exec function ThrowWeapon()
{
	if( Level.NetMode == NM_Client )
		return;
	if ( zzUTPure.bNoWeaponThrow )
		return;
	if( Weapon==None || (Weapon.Class==Level.Game.BaseMutator.MutatedDefaultWeapon())
		|| !Weapon.bCanThrow || !Weapon.IsInState('Idle'))	// <-- That fixes fws, but don't tell :P
		return;
	Weapon.Velocity = Vector(ViewRotation) * 500 + vect(0,0,220);
	Weapon.bTossedOut = true;
	TossWeapon();
	if ( Weapon == None )
		SwitchToBestWeapon();
}


function xxCalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = zzViewRotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;
	local bbPlayer bbTarg;


	if (zzInfoThing != None)
			zzInfoThing.zzPlayerCalcViewCalls--;

	if ( ViewTarget != None )
	{
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		PTarget = Pawn(ViewTarget);
		bbTarg = bbPlayer(ViewTarget);
		if ( PTarget != None )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer )
				{
					if (bbTarg != None)
						bbTarg.zzViewRotation = TargetViewRotation;
					PTarget.ViewRotation = TargetViewRotation;
				}
				PTarget.EyeHeight = TargetEyeHeight;
				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
			}
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;
			if ( !bBehindView )
				CameraLocation.Z += PTarget.EyeHeight;
		}
		if ( bBehindView )
			xxCalcBehindView(CameraLocation, CameraRotation, 180);
		return;
	}

	ViewActor = Self;
	CameraLocation = Location;

	if( bBehindView ) //up and behind
		xxCalcBehindView(CameraLocation, CameraRotation, 150);
	else
	{
		if (zzbRepVRData)
		{	// Received data through demo replication.
			CameraRotation.Yaw = zzRepVRYaw;
			CameraRotation.Pitch = zzRepVRPitch;
			CameraRotation.Roll = 0;
			EyeHeight = zzRepVREye;
		}
		else if (zzInfoThing != None && zzInfoThing.zzPlayerCalcViewCalls == zzNull)
			CameraRotation = zzViewRotation;
		else
			CameraRotation = ViewRotation;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
	}
}

function ViewShake(float DeltaTime)
{
	if (shaketimer > 0.0) //shake view
	{
		shaketimer -= DeltaTime;
		if ( verttimer == 0 )
		{
			verttimer = 0.1;
			ShakeVert = -1.1 * maxshake;
		}
		else
		{
			verttimer -= DeltaTime;
			if ( verttimer < 0 )
			{
				verttimer = 0.2 * FRand();
				shakeVert = (2 * FRand() - 1) * maxshake;
			}
		}
		zzViewRotation.Roll = zzViewRotation.Roll & 65535;
		if (bShakeDir)
		{
			zzViewRotation.Roll += Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (zzViewRotation.Roll > 32768) || (zzViewRotation.Roll < (0.5 + FRand()) * shakemag);
			if ( (zzViewRotation.Roll < 32768) && (zzViewRotation.Roll > 1.3 * shakemag) )
			{
				zzViewRotation.Roll = 1.3 * shakemag;
				bShakeDir = false;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		else
		{
			zzViewRotation.Roll -= Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (zzViewRotation.Roll > 32768) && (zzViewRotation.Roll < 65535 - (0.5 + FRand()) * shakemag);
			if ( (zzViewRotation.Roll > 32768) && (zzViewRotation.Roll < 65535 - 1.3 * shakemag) )
			{
				zzViewRotation.Roll = 65535 - 1.3 * shakemag;
				bShakeDir = true;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
	}
	else
	{
		ShakeVert = 0;
		zzViewRotation.Roll = zzViewRotation.Roll & 65535;
		if (zzViewRotation.Roll < 32768)
		{
			if ( zzViewRotation.Roll > 0 )
				zzViewRotation.Roll = Max(0, zzViewRotation.Roll - (Max(zzViewRotation.Roll,500) * 10 * FMin(0.1,DeltaTime)));
		}
		else
		{
			zzViewRotation.Roll += ((65536 - Max(500,zzViewRotation.Roll)) * 10 * FMin(0.1,DeltaTime));
			if ( zzViewRotation.Roll > 65534 )
				zzViewRotation.Roll = 0;
		}
	}
	ViewRotation = RotRand(False);
	ViewRotation.Roll = zzViewRotation.Roll;
}

function UpdateRotation(float DeltaTime, float maxPitch);

function xxUpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;

	DesiredRotation = zzViewRotation; //save old rotation
	zzViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	zzViewRotation.Pitch = zzViewRotation.Pitch & 65535;
	If ((zzViewRotation.Pitch > 18000) && (zzViewRotation.Pitch < 49152))
	{
		If (aLookUp > 0)
			zzViewRotation.Pitch = 18000;
		else
			zzViewRotation.Pitch = 49152;
	}
	zzViewRotation.Yaw += 32.0 * DeltaTime * aTurn;

	ViewShake(deltaTime);		// ViewRotation is fuked in here.
	ViewFlash(deltaTime);

	newRotation = Rotation;
	newRotation.Yaw = zzViewRotation.Yaw;
	newRotation.Pitch = zzViewRotation.Pitch;
	If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (zzViewRotation.Pitch < 32768)
			newRotation.Pitch = maxPitch * RotationRate.Pitch;
		else
			newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	setRotation(newRotation);

	if (!zzbRepVRData)
	{
		xxReplicateVRToDemo(zzViewRotation.Yaw, zzViewrotation.Pitch, EyeHeight);
		zzbRepVRData = False;		// When xxReplicateVRToDemo is executed, this var is set to true
	}
}

function xxReplicateVRToDemo(int zzYaw, int zzPitch, float zzEye)
{	// This is called before tick in a demo, but in xxUpdateRotation during creating.
	zzRepVRYaw = zzYaw;
	zzRepVRPitch = zzPitch;
	zzRepVREye = zzEye;
	zzbRepVRData = True;
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	if (Sender == PlayerReplicationInfo)
  		super.SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID,broadcasttype);  //lame anti-cheat :P
}

function ServerTaunt(name Sequence )
{
	if (Level.TimeSeconds - zzLastTaunt > 1.0)
	{
		if ( GetAnimGroup(Sequence) == 'Gesture' )
			PlayAnim(Sequence, 0.7, 0.2);
	}
	else
		zzKickReady++;
	zzLastTaunt = Level.TimeSeconds;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local int ModifiedDamage1, ModifiedDamage2;
	local bool bPreventLockdown;		// Avoid the lockdown effect.
	local Pawn P;

	if ( Role < ROLE_Authority )
	{
		Log(Self@"client damage type"@damageType@"by"@instigatedBy);
		return;
	}

	if (DamageType == 'shot' || DamageType == 'zapped')
		bPreventLockdown = zzUTPure.bNoLockdown;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
						// ReduceDamage handles HardCore mode (*1.5) and Damage Scaling (Amp, etc)
	ModifiedDamage1 = actualDamage;		// In team games it also handles team scaling.

	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	ModifiedDamage2 = actualDamage;		// This is post-armor and such.

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	if (zzStatMut != None)
	{	// Damn epic. Damn Damn. Why is armor handled before mutator gets it? Instead of doing it simple, I now have
		// to do all this magic. :/
		// If epic hadn't done this mess, I could have done this entirely in a mutator. GG epic.
		// Also must limit damage incase player has Health < Damage
		ModifiedDamage1 -= (ModifiedDamage2 - actualDamage);
		zzStatMut.PlayerTakeDamage(Self, instigatedBy, Min(Health, ModifiedDamage1), damageType);
	}

	if (instigatedBy != Self && PlayerPawn(instigatedBy) != None)
	{	// Send the hitsound local message.
		PlayerPawn(instigatedBy).ReceiveLocalizedMessage(Class'PureHitSound', ModifiedDamage1, PlayerReplicationInfo);
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			if (P.IsA('bbCHSpectator') && (PlayerPawn(P).ViewTarget == Self || PlayerPawn(P).ViewTarget == instigatedBy))
				PlayerPawn(P).ReceiveLocalizedMessage(Class'PureHitSound', ModifiedDamage1, PlayerReplicationInfo);
		}
	}

	if (!bPreventLockdown)	// FIX BY LordHypnos, http://forums.prounreal.com/viewtopic.php?t=34676&postdays=0&postorder=asc&start=0
		AddVelocity( momentum );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.BaseMutator.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	if ( bDeleteMe )
		return; //already destroyed
	StopZoom();
	Health = Min(0, Health);
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(Killer, self, damageType);
	if ( CarriedDecoration != None )
		DropDecoration();
	level.game.Killed(Killer, self, damageType);
	if (zzStatMut != None)
		zzStatMut.PlayerKill(Killer, Self);

	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );
	Level.Game.DiscardInventory(self);
	Velocity.Z *= 1.3;
	if ( Gibbed(damageType) )
	{
		SpawnGibbedCarcass();
		if ( bIsPlayer )
			HidePlayer();
		else
			Destroy();
	}
	PlayDying(DamageType, HitLocation);
	if ( Level.Game.bGameEnded )
		return;
	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);
	GotoState('Dying');
}

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


/// ----------- States

state FeigningDeath
{
	function xxServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.xxServerMove(TimeStamp, Accel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
	}

	function PlayerMove( float DeltaTime)
	{
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !FeignAnimCheck()  && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		xxUpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function BeginState()
	{
	local byte zzOldbfire, zzOldbAlt;

		Super.BeginState();
		// Stop weapon firing
 		//UsAaR33: prevent weapon from firing (brought on by missing bchangedweapon checks)
		if (zzbNoMultiWeapon && Weapon != none && (baltfire>0||bfire>0) )
		{ //could only be true on server
			zzoldbfire=bfire;
			zzoldbalt=baltfire;
			baltfire=0;
			bfire=0;
			//additional hacks to stop weapons:
			if (Weapon.Isa('Minigun2'))
				Minigun2(Weapon).bFiredShot=true;
			if (Weapon.IsA('Chainsaw'))   //Saw uses sleep delays in states.
				Weapon.Finish();
			Weapon.Tick(0);
			Weapon.AnimEnd();
			zzbfire=zzoldbfire;
			zzbaltfire=zzoldbalt;
		}
	}
}
//==========================================

state PlayerSwimming
{

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector X,Y,Z, Temp;

		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		SwimAnimUpdate( (X Dot Acceleration) <= 0 );

		bUpAndOut = ((X Dot Acceleration) > 0) && ((Acceleration.Z > 0) || (ViewRotation.Pitch > 2048));

		if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump(Temp) ) //check for waterjump
		{
			velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
			PlayDuck();
			GotoState('PlayerWalking');
		}
	}

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		GetAxes(zzViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		//add bobbing when swimming
		if ( !bShowMenu )
		{
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
		}

		// Update rotation.
		oldRotation = Rotation;
		xxUpdateRotation(DeltaTime, 2);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		bPressedJump = false;
	}


	event UpdateEyeHeight(float DeltaTime)
	{
		Super.UpdateEyeHeight(DeltaTime);
		xxCheckFOV();
	}

	function Timer()
	{
		if ( !Region.Zone.bWaterZone && (Role == ROLE_Authority) )
		{
			//log("timer out of water");
			GotoState('PlayerWalking');
			AnimEnd();
		}

		Disable('Timer');
	}

	function BeginState()
	{
		Disable('Timer');
		if ( !IsAnimating() )
			TweenToWaiting(0.3);
//		log("BeginState: PlayerSwimming");
	}
}

state PlayerFlying
{
	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.2;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		Acceleration = aForward*X + aStrafe*Y;
		// Update rotation.
		xxUpdateRotation(DeltaTime, 2);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
}

// ==================================================================

state CheatFlying
{
	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(zzViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function Landed(vector HitNormal)
	{
		if (DodgeDir == DODGE_Active)
		{
			DodgeDir = DODGE_Done;
			DodgeClickTimer = 0.0;
			Velocity.X *= 0.1;
			Velocity.Y *= 0.1;
		}
		else
			DodgeDir = DODGE_None;
		Global.Landed(HitNormal);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		if (Mesh == None)
		{
			SetMesh();
			return;		// WHY???
		}

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else
			DodgeMove = DODGE_None;
		if (DodgeClickTime > 0.0)
		{
			if ( DodgeDir < DODGE_Active )
			{
				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;
				if (bEdgeForward && bWasForward)
					DodgeDir = DODGE_Forward;
				if (bEdgeBack && bWasBack)
					DodgeDir = DODGE_Back;
				if (bEdgeLeft && bWasLeft)
					DodgeDir = DODGE_Left;
				if (bEdgeRight && bWasRight)
					DodgeDir = DODGE_Right;
				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ( DodgeDir != OldDodge )
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else
					DodgeMove = DodgeDir;
			}

			if (DodgeDir == DODGE_Done)
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < -0.35)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
			else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}

		// Fix by DB
		if (AnimSequence != '')
			AnimGroupName = GetAnimGroup(AnimSequence);

		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					zzViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					zzViewRotation.Pitch = zzViewRotation.Pitch & 65535;
					if (zzViewRotation.Pitch > 32768)
						zzViewRotation.Pitch -= 65536;
					zzViewRotation.Pitch = zzViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(zzViewRotation.Pitch) < 1000 )
						zzViewRotation.Pitch = -500;
				}
			}

			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			//add bobbing when walking
			if ( !bShowMenu )
				CheckBob(DeltaTime, Speed2D, Y);
		}
		else if ( !bShowMenu )
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		xxUpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function BeginState()
	{
		if ( Mesh == None )
			SetMesh();
		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		bIsCrouching = false;
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling) SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
			PlayWaiting();
	}

	function EndState()
	{
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}

//==========================================

function bool FeignAnimCheck() //for VA compatibility
{
	return IsAnimating();
}

// ==============================================
state PlayerWaiting
{
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

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(zzViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	exec function Fire(optional float F)
	{
		bReadyToPlay = true;
		xxServerSetReadyToPlay();
	}

	exec function AltFire(optional float F)
	{
		bReadyToPlay = true;
		xxServerSetReadyToPlay();
	}

}

function xxServerSetReadyToPlay()
{
	local CTFFlag Flag;
	if (zzUTPure.zzDMP == None)
		return;
	if (zzUTPure.zzDMP.bTournament && zzUTPure.bWarmup && zzUTPure.zzDMP.bRequireReady && (zzUTPure.zzDMP.CountDown >= 10))
	{
		PlayerRestartState = 'PlayerWarmup';
		GotoState('PlayerWarmup');
		zzUTPure.zzDMP.ReStartPlayer(Self);
		zzUTPure.zzbWarmupPlayers = True;
	}

}

function GiveMeWeapons()
{
	local Inventory Inv;
	local Weapon Weap;
	local DeathMatchPlus DMP;
	local string WeaponList[32], s;
	local int WeapCnt, x;				// Grr, wish UT had dyn arrays :P
	local bool bAlready;

	DMP = DeathMatchPlus(Level.Game);
	if (DMP == None) return;			// If DMP is none, I would never be here, so darnit really? :P

	if (DMP.BaseMutator != None)			// Add the default weapon
		WeaponList[WeapCnt++] = string(DMP.BaseMutator.MutatedDefaultWeapon());

	WeaponList[WeapCnt++] = "Botpack.Enforcer";	// If it is instagib/other the enforcer will be removed upon spawn

	if (DMP.bUseTranslocator)			// Sneak in translocator
		WeaponList[WeapCnt++] = "Botpack.Translocator";

	ForEach AllActors(Class'Weapon', Weap)
	{	// Find the rest of the weapons around the map.
		s = string(Weap.Class);
		bAlready = False;
		for (x = 0; x < WeapCnt; x++)
		{
			if (WeaponList[x] ~= s)
			{
				bAlready = True;
				break;
			}
		}
		if (!bAlready)
			WeaponList[WeapCnt++] = s;
	}

	for (x = 0; x < WeapCnt; x++)
	{	// Distribute weapons.
		DMP.GiveWeapon(Self, WeaponList[x]);
	}

	for ( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{	// This gives max ammo.
		Weap = Weapon(Inv);
		if (Weap != None)
		{
			Weap.WeaponSet(Self);
			if ( Weap.AmmoType != None )
				Weap.AmmoType.AmmoAmount = Weap.AmmoType.MaxAmmo;
		}
	}

	Inv = Spawn(class'Armor2');
	if( Inv != None )
	{
		Inv.bHeldItem = true;
		Inv.RespawnTime = 0.0;
		Inv.GiveTo(Self);
	}

	SwitchToBestWeapon();
}


state PlayerWarmup extends PlayerWalking
{
	function BeginState()
	{
		GiveMeWeapons();
		Super.BeginState();
	}

	exec function SetProgressMessage( string S, int Index )
	{	// Bugly hack. But why not :/ It's only used during warmup anyway.
		// This also means that admins may not use say # >:|
		if (S == Class'DeathMatchPlus'.Default.ReadyMessage || S == Class'TeamGamePlus'.Default.TeamChangeMessage)
		{
			ClearProgressMessages();
			return;
		}
		Super.SetProgressMessage( S, Index );
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		if (Self == instigatedBy)
		{
			Damage = 0;		// No self damage in warmup.
			momentum *= 2;		// And 2x momentum.
		}
		Global.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	}

}



// =======================
state PlayerSpectating
{
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

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(zzViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if (!zzbWeaponTracer)
			ViewRotation = zzViewRotation;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

}
//===============================================================================
state PlayerWaking
{

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(Float DeltaTime)
	{
		ViewFlash(deltaTime * 0.5);
		if ( TimerRate == 0 )
		{
			zzViewRotation.Pitch -= DeltaTime * 12000;
			if ( zzViewRotation.Pitch < 0 )
			{
				zzViewRotation.Pitch = -500;
				GotoState('PlayerWalking');
			}
			ViewRotation.Pitch = zzViewRotation.Pitch;
		}

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
	}

	function BeginState()
	{
		if ( bWokeUp )
		{
			zzViewRotation.Pitch = -500;
			ViewRotation.Pitch = -500;
			SetTimer(0, false);
			return;
		}
		BaseEyeHeight = 0;
		EyeHeight = 0;
		SetTimer(3.0, false);
		bWokeUp = true;
	}
}

state Dying
{
	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(zzViewRotation,X,Y,Z);
			// Update view rotation.
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			zzViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			zzViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			zzViewRotation.Pitch = zzViewRotation.Pitch & 65535;
			If ((zzViewRotation.Pitch > 18000) && (zzViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					zzViewRotation.Pitch = 18000;
				else
					zzViewRotation.Pitch = 49152;
			}
			ViewRotation = zzViewRotation;
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				xxReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		ViewRotation = zzViewRotation;
	}

	function xxServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.xxServerMove(TimeStamp, Accel, ClientLoc, false, false, false, false, false, false, false,
				DodgeMove, ClientRoll, View);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		//fixme - try to pick view with killer visible
		//fixme - also try varying starting pitch

		zzViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = zzViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			zzViewRotation.Yaw += 4096;
		}
		if (zzInfoThing != None)
			zzInfoThing.zzPlayerCalcViewCalls = 1;

		zzViewRotation.Yaw = startYaw + besttry * 4096;
		ViewRotation.Yaw = zzViewRotation.Yaw;
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, PainTimer, Died;

	function ServerReStartGame();

	event PlayerTick( float DeltaTime )
	{
		zzbCanCSL = zzFalse;
		xxPlayerTickEvents();
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(zzViewRotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			zzViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			zzViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			zzViewRotation.Pitch = zzViewRotation.Pitch & 65535;
			If ((zzViewRotation.Pitch > 18000) && (zzViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					zzViewRotation.Pitch = 18000;
				else
					zzViewRotation.Pitch = 49152;
			}
		}
		else if ( ViewTarget != None )
			zzViewRotation = ViewTarget.Rotation;

		ViewRotation = zzViewRotation;
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}

	function xxServerMove
	(
		float TimeStamp,
		vector InAccel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.xxServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (zzViewRotation.Pitch/2)) * 32768 + (32767 & (zzViewRotation.Yaw/2)) );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		zzViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = zzViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			if ( ViewTarget != None )
				cameraLoc = ViewTarget.Location;
			else
				cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			zzViewRotation.Yaw += 4096;
		}
		if (zzInfoThing != None)
			zzInfoThing.zzPlayerCalcViewCalls = 1;

		zzViewRotation.Yaw = startYaw + besttry * 4096;
	}
}

function PlayWaiting()
{
	local name newAnim;

	if ( Mesh == None )
		return;

	if ( bIsTyping )
	{
		PlayChatting();
		return;
	}

	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		zzViewRotation.Pitch = zzViewRotation.Pitch & 65535;
		If ( (zzViewRotation.Pitch > RotationRate.Pitch)
			&& (zzViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (zzViewRotation.Pitch < 32768)
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpSm', 0.3);
				else
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnSm', 0.3);
				else
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
				LoopAnim('StillFRRP');
			else if ( Weapon.Mass < 20 )
				TweenAnim('StillSMFR', 0.3);
			else
				TweenAnim('StillFRRP', 0.3);
		}
		else
		{
			if ( FRand() < 0.1 )
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
				else
					PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}

				if ( AnimSequence == newAnim )
					LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
			}
		}
	}
}

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local float rnd;
	local Bubble1 bub;
	local bool bServerGuessWeapon;
	local vector BloodOffset, Mo;
	local int iDam;

	if ( (Damage <= 0) && (ReducedDamageType != 'All') )
		return;

	//DamageClass = class(damageType);
	if ( ReducedDamageType != 'All' ) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location
				+ 0.7 * CollisionRadius * vector(zzViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04;
		}
		else if ( (damageType != 'Burned') && (damageType != 'Corroded')
					&& (damageType != 'Fell') )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') )
			{
				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
			}
			else
				spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
		}
	}

	rnd = FClamp(Damage, 20, 60);
	if ( damageType == 'Burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'Corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'Drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else
		ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage);
	PlayTakeHitSound(Damage, damageType, 1);
	bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || (GetAnimGroup(AnimSequence) == 'Dodge') );
	iDam = Clamp(Damage,0,200);
	ClientPlayTakeHit(hitLocation - Location, iDam, bServerGuessWeapon );
	if ( !bServerGuessWeapon
		&& ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
	{
		Enable('AnimEnd');
		BaseEyeHeight = Default.BaseEyeHeight;
		bAnimTransition = true;
		PlayTakeHit(0.1, hitLocation, Damage);
	}
}

function ClientShake(vector shake)
{
	if ( (shakemag < shake.X) || (shaketimer <= 0.01 * shake.Y) )
	{
		shakemag = shake.X;
		shaketimer = 0.01 * shake.Y;
		zzRealMaxShake = 0.01 * shake.Z;
		maxshake = zzRealMaxShake;
		verttimer = 0;
		ShakeVert = -1.1 * maxshake;
	}
}

////////////////////////////
// CRC Checks on UTPure Itself
////////////////////////////

//Server asks Client for a CRC check (unreliable... called each servermove) <-- usaar = funney, reliable, called once
simulated function xxClientMD5(string zzPackage, string zzInit)
{
	xxServerTestMD5("", Level.ComputerName); //PackageMD5(zzPackage, zzInit));
}

function xxServerTestMD5(string zzClientMD5, string zzPCName)
{
	local string zzs;
	zzComputerName = zzPCName;
	zzs = GetPlayerNetworkAddress();
	zzs = Left(zzs,InStr(zzs,":"));
	zzUTPure.xxLogDate("Validated:"@PlayerReplicationInfo.PlayerName$","@zzComputerName$"."$zzs, Level);
	zzbDidMD5 = True;
}

function xxShowItems()
{
	local int zzx;

	for (zzx = 0; zzx < zzAntiTimerListCount; zzx++)
	{
		if (zzAntiTimerList[zzx] != None)
			zzAntiTimerList[zzx].bHidden = (zzAntiTimerListState & (1 << zzx)) != zzNull;	// Bitmapped
	}

}

function xxHideItems()
{
	for (zzAntiTimerFlippedCount = 0; zzAntiTimerFlippedCount < zzAntiTimerListCount; zzAntiTimerFlippedCount++)
	{
		if (zzAntiTimerList[zzAntiTimerFlippedCount] != None)
		{
			zzAntiTimerList[zzAntiTimerFlippedCount].bHidden = zzFalse;
		}
	}
}

function xxDoShot()
{
	local string zzs;

	zzs = ConsoleCommand("shot");

	if (zzMagicCode != "")
	{
		xxServerAckScreenshot(zzs, zzMagicCode);
		zzMagicCode = "";
	}
	zzbReportScreenshot = zzFalse;
}

function xxPlayerTickEvents()
{
	if (zzCannibal != None)
	{
		if ((zzCannibal.Font != zzCanOldFont) || (zzCannibal.Style != zzCanOldStyle))
		{
			xxServerCheater("HA");
		}
	}
	if (zzbReportScreenshot)
		xxDoShot();

	xxHideItems();

	zzbForcedTick = (zzInfoThing.zzTickOff != zzNull) || (zzInfoThing.zzLastTick != zzTick);

	zzInfoThing.zzTickOff++;
	zzInfoThing.zzLastTick = 0.0;
	if (zzForceSettingsLevel != zzOldForceSettingsLevel)
	{
		zzOldForceSettingsLevel = zzForceSettingsLevel;
		if (zzForceSettingsLevel > 0)
			zzInfoThing.xxStartupCheck(Self);
		if (zzForceSettingsLevel > 1)
			zzInfoThing.xxInstallSpawnNotify(Self);
	}
	zzClientTD = Level.TimeDilation;
	zzbBadMaxShake = zzRealMaxShake != MaxShake;

	if (PureLevel != None)	// Why would this be None?!
	{
		zzbDemoRecording = PureLevel.zzDemoRecDriver != None;

		if (!zzbDemoRecording && zzbGameStarted && (zzbForceDemo || bDoDemo))
			xxClientDemoRec();
	}
}

event PreRender( canvas zzCanvas )
{
	local SpawnNotify zzOldSN;
	local int zzx;
	local PlayerReplicationInfo zzPRI;
	local Pawn zzP;

	zzbConsoleInvalid = zzTrue;

	zzbBadCanvas = zzbBadCanvas || (zzCanvas.Class != Class'Canvas');

	zzLastVR = zzViewRotation;

	if (Role < ROLE_Authority)
		xxAttachConsole();

	if (zzbRenderHUD)
	{
		if ( zzmyHud != None )
		{
			zzmyHUD.PreRender(zzCanvas);
		}
		else if ( (Viewport(Player) != None) && (zzHUDType != None) && (zzSBType != None) )
		{
			zzOldSN = Level.SpawnNotify;
			Level.SpawnNotify = None;
			zzmyHUD = Spawn(zzHUDType, Self);
			zzScoring = Spawn(zzSBType, Self);
			Level.SpawnNotify = zzOldSN;
		}
	}
	if (myHUD == None && HUDType != None)
	{
		myHUD = Spawn(HUDType, Self);
	}
	if (Scoring == None && ScoringType != None)
		Scoring = Spawn(ScoringType, Self);

	// Set all other players' health to 0 (unless it's a teamgame and he's on your team) // also set location to something dumb ;)
	if (zzGameReplicationInfo != None && zzPlayerReplicationInfo != None)
	{
		for (zzx = 0; zzx < 32; zzx++)
		{
			zzStoredPRI[zzx] = None;		// Clear out stored PRI.
			zzPRI = zzGameReplicationInfo.PRIArray[zzx];
			if (zzPRI != None)
			{
				zzP = Pawn(zzPRI.Owner);
				if (zzPRI != zzPlayerReplicationInfo && zzP != None)
				{
					if (!zzGameReplicationInfo.bTeamGame || zzPRI.Team != zzPlayerReplicationInfo.Team)
					{
						zzPRI.PlayerLocation = zzPlayerReplicationInfo.PlayerLocation;
						zzPRI.PlayerZone = None;
						zzP.Health = -5*zzx-4;
					}
					zzStoredPRI[zzx] = zzPRI;
					if (CTFFlag(zzPRI.HasFlag) == None)
						zzP.PlayerReplicationInfo = None;
					zzP.bIsPlayer = zzFalse;
					if (zzP.LightType == LT_Steady)
					{
						zzbBadLighting = zzbBadLighting || (zzP.AmbientGlow != 254) || (zzP.LightRadius > 10);
					}
					else
					{
						zzP.LightRadius = 0;
						zzbBadLighting = zzbBadLighting || (zzP.AmbientGlow != 17);
					}
				}
			}
		}
		GameReplicationInfo = None;
		PlayerReplicationInfo = None;
	}
	xxShowItems();

	zzbDonePreRender = zzTrue;
}

simulated event RenderOverlays( canvas zzCanvas )
{
//	Log("PlayerPawn.RenderOverlays");
	xxHideItems();

	if (zzCanvas != None && zzbDonePreRender)
	{
		ViewRotation = zzLastVR;
	}

	if ( Weapon != None && Weapon == zzWeapon )
		Weapon.RenderOverlays(zzCanvas);

	if ( zzmyHUD != None )
		zzmyHUD.RenderOverlays(zzCanvas);
}

event PostRender( canvas zzCanvas )
{
	local SpawnNotify zzOldSN;
	local Pawn zzP;
	local int zzi;
	zzbDonePreRender = zzFalse;

	zzbBadCanvas = zzbBadCanvas || (zzCanvas.Class != Class'Canvas');

	for (zzi = 0; zzi < 32; zzi++)
	{
		if (zzStoredPRI[zzi] != None)
		{
			zzP = Pawn(zzStoredPRI[zzi].Owner);
			if (zzP != None)
			{
				zzP.PlayerReplicationInfo = zzStoredPRI[zzi];
				zzP.bIsPlayer = zzTrue;
			}
		}
	}
	GameReplicationInfo = zzGameReplicationInfo;
	PlayerReplicationInfo = zzPlayerReplicationInfo;

	if (zzbRenderHUD)
	{
		if (zzbRepVRData)
		{	// Received data through demo replication.
			ViewRotation.Yaw = zzRepVRYaw;
			ViewRotation.Pitch = zzRepVRPitch;
			ViewRotation.Roll = 0;
			EyeHeight = zzRepVREye;
		}
		else
			ViewRotation = zzViewRotation;

		if ( zzmyHUD != None )
		{
			//zzmyHUD.RenderOverlays(zzCanvas);
			xxHandlePostRenderHUD( zzCanvas);
			if (myHUD != zzmyHUD)
			{
				HUDType = zzHUDType;
				zzHUDWarnings++;
				myHUD.Destroy();
				myHUD = zzmyHUD;
			}
			if (Scoring != zzScoring)
			{
				ScoringType = zzSBType;
				zzHUDWarnings++;
				Scoring.Destroy();
				Scoring = zzScoring;
			}
			if (zzHUDWarnings > 10)
				xxServerCheater("HR");
		}
		else if ( (Viewport(Player) != None) && (zzHUDType != None) && (zzSBType != None) )
		{
			zzOldSN = Level.SpawnNotify;
			Level.SpawnNotify = None;
			zzmyHUD = Spawn(zzHUDType, Self);
			zzScoring = Spawn(zzSBType, Self);
			Level.SpawnNotify = zzOldSN;
		}
	}

	if (myHUD == None && HUDType != None)
	{
		myHUD = Spawn(HUDType, Self);
	}
	if (Scoring == None && ScoringType != None)
		Scoring = Spawn(ScoringType, Self);


	// Render our UTPure Logo
	xxRenderLogo(zzCanvas);
	xxCleanAVars();

	zzNetspeed = Player.CurrentNetspeed;
	if (zzMinimumNetspeed != 0 && zzNetspeed < zzMinimumNetspeed)
		ConsoleCommand("Netspeed"@zzMinimumNetspeed);

	if (zzDelayedStartTime != 0.0)
	{
		if (Level.TimeSeconds - zzDelayedStartTime > zzWaitTime)
		{
			if (zzDelayedName != "")
			{
				ChangeName(zzDelayedName);
				UpdateURL("Name", zzDelayedName, true);
				SaveConfig();
				zzDelayedName = "";
			}
			if (zzDelayedVoice != None)
			{
				PlayerReplicationInfo.VoiceType = zzDelayedVoice;
				UpdateURL("Voice", string(zzDelayedVoice), True);
				ServerSetVoice(zzDelayedVoice);
				zzDelayedVoice = None;
			}
			zzDelayedStartTime = 0.0;
		}
	}

	zzbVRChanged = zzbVRChanged || (zzViewRotation != zzLastVR);
}

exec simulated Function TellConsole()
{
	Log("Console class:"@player.console.class);
}

simulated function xxHandlePostRenderHUD( canvas zzCanvas )
{
	local Mutator zzMute,zzTM;
	local ChallengeHUD zzCHud;
	local int zzi;
	local GameReplicationInfo GRI;

	// Check for new HUD Mutators
	if (myHUD != None)
		for (zzMute = myHUD.HUDMutator; zzMute != None; zzMute = myHUD.HUDMutator)
		{
			for (zzi = 0; zzi < 50; zzi++)
			{
				if (zzWaitMutes[zzi] == None)
				{
					zzWaitMutes[zzi] = zzMute;
					zzWMCheck[zzi] = frand() + 2.0;
					xxServerCheckMutator(String(zzMute.class), zzWMCheck[zzi]);
					break;
				}
			}
			myHUD.HUDMutator = zzMute.NextHUDMutator;
			zzMute.NextHUDMutator = None;
		}

	if (Level.Pauser != "")
		ForEach AllActors(Class'GameReplicationInfo',GRI)
		{
			if (GRI != None)
			{
				GRI.SecondCount = Level.TimeSeconds;
			}
		}

	if (zzStat != None && zzStat.bShowStats)
	{
		zzStat.PostRender( zzCanvas );
		return;
	}

	zzmyHUD.PostRender( zzCanvas );	// Render HUD

	// Filter Out when i should not render HudMuties
	zzCHud = ChallengeHUD(zzMyHUD);

	if ( zzCHUD != None )
	{
		if ((zzCHud.bForceScores || bShowScores) && Scoring != None)
			return;

		if ( (zzCHUD.PawnOwner == None) || (PlayerReplicationInfo == None) ||
				zzCHud.bShowInfo || zzCHUD.bHideHUD )
			return;
	}

	// Call HudMutators render
	for (zzi = 0; zzi<zzHMCnt; zzi++)
	{
		zzMute = zzHudMutes[zzi];
		if (zzMute != None)
		{
			zzTM = zzMute.NextMutator;
			zzMute.NextHUDMutator = None;	// Bad hackers should die a bad death!
			zzMute.NextMutator = None;	// This is to make sure no "old" mutes accidentally
			zzMute.PostRender( zzCanvas );	// Transfers postrender to mutes that shouldn't
			zzMute.NextMutator = zzTM;	// be allowed.
		}
	}
}

// AUTODEMO CODE
function string xxExtractTag(string zzNicks[32], int zzCount)
{
	local int zzShortNickSize,zzPartSize;
	local string zzShortNick,zzPart;
	local int zzx, zzy, zzLoc, zzFound;
	local string zzParts[256];
	local int zzPartFound[256],zzPartCount;
	local string zzBestPart;
	local int zzBestFindNumber;
	local bool zzbAlready;

	zzShortNickSize = 999;
	for (zzx = 0; zzx < zzCount; zzx++)		// Find Shortest nick
	{
		if (Len(zzNicks[zzx]) < zzShortNickSize)
		{
			zzShortNickSize = Len(zzNicks[zzx]);
			zzShortNick = zzNicks[zzx];
		}
	}

	for (zzy = 0; zzy < zzCount; zzy++)		// Go through all nicks to find a potential tag.
	{
		zzPartSize = zzShortNickSize;	// Use the shortest nick as base for search.

		while (zzPartSize > 1)			// Ignore clantags less than 2 letters...
		{
			for (zzLoc = 0; zzLoc < (Len(zzNicks[zzy]) - zzPartSize + 1); zzLoc++)	// Go through all the parts of a nick..
			{
				zzPart = Mid(zzNicks[zzy],zzLoc,zzPartSize);
				zzFound = 0;
				for (zzx = 0; zzx < zzCount ; zzx++)	// Go through all nicks
				{
					if (InStr(zzNicks[zzx],zzPart) >= 0)
						zzFound++;
				}
				if (zzFound == zzCount)		// All nicks had this, so stop search (Gold nugget man!)
					return xxFixFileName(zzPart,"");
				if (zzFound > (zzCount / 2) && zzPartCount < 256)	// if more than half of the nicks had it, store it to the list
				{
					zzbAlready = False;
					for (zzx = 0; zzx < zzPartCount; zzx++)
					{
						if (zzParts[zzx] ~= zzPart)
						{
							zzbAlready = True;
							break;
						}
					}
					if (!zzbAlready)		// Don't readd if already in list.
					{
						zzPartFound[zzPartCount] = zzFound;
						zzParts[zzPartCount] = zzPart;
						zzPartCount++;
					}
				}
			}
			zzPartSize--;
		}
	}

	for (zzx = 0; zzx < zzPartCount; zzx++)	// Check through parts, see if we found one that all agrees on!
	{
		if (zzPartFound[zzx] > zzBestFindNumber)	// One that matches better
		{
			zzBestFindNumber = zzPartFound[zzx];
			zzBestPart = zzParts[zzx];
		}
	}

	if (zzBestPart == "")
		zzBestPart = "Unknown";

	return xxFixFileName(zzBestPart,"");
}

function string xxFindClanTags()
{
	local PlayerReplicationInfo zzPRI;
	local string zzTeamNames[32],zzFinalTags[2];
	local int zzTeamCount,zzTeamNr;
	local GameReplicationInfo zzGRI;

	ForEach Level.AllActors(Class'GameReplicationInfo',zzGRI)
		if (!zzGRI.bTeamGame)
		{
			return "FFA";
		}

	zzTeamNr = 0;
	while (zzTeamNr < 2)
	{
		zzTeamCount = 0;
		ForEach Level.AllActors(Class'PlayerReplicationInfo',zzPRI)
			if (zzPRI.Team == zzTeamNr)
				zzTeamNames[zzTeamCount++] = zzPRI.PlayerName;

		zzFinalTags[zzTeamNr] = xxExtractTag(zzTeamNames,zzTeamCount);
		zzTeamNr++;
	}

	return zzFinalTags[0]$"_"$zzFinalTags[1];
}


function string xxFixFileName(string zzs, string zzReplaceChar)
{
	local int zzx;
	local string zzs2,zzs3;

	zzs3 = "";
	for (zzx = 0; zzx < Len(zzs); zzx++)
	{
		zzs2 = Mid(zzs,zzx,1);
		if (asc(zzs2) < 32 || asc(zzs2) > 128)
			zzs2 = zzReplaceChar;
		else
		{
			switch(zzs2)
			{
				Case "|":
				Case ".":
				Case ":":
				Case "%":
				Case "\\":
				Case "/":
				Case "*":
				Case "?":
				Case ">":
				Case "<":
				Case "(":	//
				Case ")":	//
				Case "`":	//
				Case "\"":	//
				Case "'":	//
				Case "´":	//
				Case "&":	// Weak Linux, Weak
				Case " ":	zzs2 = zzReplaceChar;
						break;
			}
		}
		zzs3 = zzs3$zzs2;
	}
	return zzs3;
}

function string xxCreateDemoName(string zzDemoName)
{
	local int zzx;
	local string zzs;

	if (zzDemoName == "")
		zzDemoName = "%l_[%y_%m_%d_%t]_[%c]_%e";	// Incase admin messes up :/

	while (True)
	{
		zzx = InStr(zzDemoName,"%");
		if (zzx < 0)
			break;
		zzs = Mid(zzDemoName,zzx+1,1);
		Switch(Caps(zzs))
		{
			Case "E":	zzs = string(Level);
					zzs = Left(zzs,InStr(zzs,"."));
					break;
			Case "F":	zzs = Level.Title;		// Level.Title
					break;
			Case "D":	if (Level.Day < 10)		// Day
						zzs = "0"$string(Level.Day);
					else
						zzs = string(Level.Day);
					break;
			Case "M":	if (Level.Month < 10)		// Month
						zzs = "0"$string(Level.Month);
					else
						zzs = string(Level.Month);
					break;
			Case "Y":	zzs = string(Level.Year);	// Year
					break;
			Case "H":	if (Level.Hour < 10)		// Hour
						zzs = "0"$string(Level.Hour);
					else
						zzs = string(Level.Hour);
					break;
			Case "N":	if (Level.Minute < 10)		// Minute
						zzs = zzs$"0"$string(Level.Minute);
					else
						zzs = string(Level.Minute);
					break;
			Case "T":	if (Level.Hour < 10)		// Time (HourMinute)
						zzs = "0"$string(Level.Hour);
					else
						zzs = string(Level.Hour);
					if (Level.Minute < 10)		// Minute
						zzs = zzs$"0"$string(Level.Minute);
					else
						zzs = zzs$string(Level.Minute);
					break;
			Case "C":	// Try to find 2 unique tags within the 2 teams. If only 2 players exists, add their names.
					zzs = xxFindClanTags();
					break;
			Case "L":	// Find the name of the local player
					zzs = PlayerReplicationInfo.PlayerName;
					break;
			Case "%":	break;
			Default:	zzs = "%"$zzs;
					break;
		}
		zzDemoName = Left(zzDemoName,zzx)$zzs$Mid(zzDemoName,zzx+2);
	}
	zzDemoName = DemoPath$xxFixFileName(zzDemoName,DemoChar);
	return zzDemoName;
}

exec function SetDemoAuto(bool zzb)
{
	bDoDemo = zzb;
	ClientMessage("Auto Demo Recording is now:"@zzb);
	SaveConfig();
}

exec function SetDemoMask(optional string zzMask)
{
	local string zzs;

	if (zzMask != "")
	{
		DemoMask = zzMask;
		SaveConfig();
	}

	ClientMessage("Current demo mask:"@DemoMask);
}

exec function DemoStart()
{
	if (zzbDemoRecording)
	{
		ClientMessage("Already recording!");
		return;
	}

	xxClientDemoRec();
}

simulated function xxClientDemoRec()
{
	local string zzs;

	zzs = ConsoleCommand("DemoRec"@xxCreateDemoName(DemoMask));
	ClientMessage(zzs);
	if (zzbForceDemo)
		xxServerDemoReply(zzs);
}

function xxServerDemoReply(string zzs)
{
	zzUTPure.xxLog("Forced Demo:"@PlayerReplicationInfo.PlayerName@zzs);
}

// END AUTODEMO CODE

simulated function xxClientDoScreenshot(string zzMagic)
{
	zzMagicCode = zzMagic;
	zzbDoScreenshot = zzTrue;
}

function xxServerCheckMutator(string zzClass, float zzv)
{
	local class<Mutator> zzAc;

	zzAc = class<Mutator>(DynamicLoadObject(zzClass, class'Class'));
	if (zzAc == None)
	{
		zzv = -zzv;	// - = it's a naughty naughty boy (client side only)
		if (++zzFailedMutes == 50)
			xxServerCheater("FM");
	}

	xxClientAcceptMutator(zzClass, zzv);
}

simulated function xxClientAcceptMutator(string zzClass, float zzv)
{
	local int zzi,zzi2;


	if (zzHMCnt == 50)
		return;

	for (zzi = 0; zzi<50; zzi++)
	{
		if (zzWaitMutes[zzi] != None && string(zzWaitMutes[zzi].class) == zzClass)
		{
			if (zzv == zzWMCheck[zzi])
			{
				for (zzi2 = 0; zzi2 < zzHMCnt; zzi2++)	// Check if HUDMut is already in
				{
					if (zzHUDMutes[zzi2] != None &&
					    string(zzHUDMutes[zzi2].Class) == zzClass)
					{
						zzHUDMutes[zzi2].Destroy();
						break;
					}
				}
				zzHudMutes[zzi2] = zzWaitMutes[zzi];
				zzHMCnt++;
				zzWaitMutes[zzi] = None;
				zzWMCheck[zzi] = 0.0;
			}
			else if (zzv < 0 && -zzv == zzWMCheck[zzi])
			{
				zzWaitMutes[zzi].Destroy();
				zzWaitMutes[zzi] = None;
				zzWMCheck[zzi] = 0.0;
				break;
			}
		}
	}
}

simulated function xxDrawLogo(canvas zzC, float zzX, float zzY, float zzFadeValue)
{
	zzC.Style = ERenderStyle.STY_Translucent;
	zzC.DrawColor = ChallengeHud(MyHud).GoldColor * zzFadeValue;
	zzC.SetPos(zzX+70,zzY+5);
	zzC.Font = ChallengeHud(MyHud).MyFonts.GetSmallestFont(zzC.ClipX);
	zzC.DrawText("UTPure");
	zzC.SetPos(zzX+70,zzY+32);
	zzC.Font = ChallengeHud(MyHud).MyFonts.GetBigFont(zzC.ClipX);
	zzC.DrawText(class'UTPure'.default.LongVersion$class'UTPure'.default.ThisVer);
	zzC.SetPos(zzX,zzY+59);
	if (zzbDoScreenshot)
	{
		zzMagicCode = PlayerReplicationInfo.PlayerName@Level.ComputerName@zzMagicCode@PurePlayer.zzRenDev;
		zzC.DrawText(zzMagicCode);
		zzC.DrawColor = ChallengeHUD(myHUD).BlueColor * zzFadeValue;
		zzC.SetPos(zzX + 1, zzY);
		zzC.DrawIcon(texture'PUREShield', 1.0);
		zzC.DrawColor = ChallengeHUD(myHUD).RedColor * zzFadeValue;
		zzC.SetPos(zzX - 1, zzY);
		zzC.DrawIcon(texture'PUREShield', 1.0);
		zzC.DrawColor = ChallengeHUD(myHUD).GreenColor * zzFadeValue;
		zzC.SetPos(zzX, zzY);
		zzC.DrawIcon(texture'PUREShield', 1.0);

	}
	else
	{
		if (!zzbDidMD5)
			zzC.DrawText("Validating...");
		else
			zzC.DrawText("Type 'PureHelp' into console for extra Pure commands!");
		zzC.DrawColor = ChallengeHud(MyHud).WhiteColor * zzFadeValue;
		zzC.SetPos(zzX,zzY);
		zzC.DrawIcon(texture'PUREShield',1.0);
	}
	zzC.Style = ERenderStyle.STY_Normal;
}

simulated function xxRenderLogo(canvas zzC)
{
	local float zzFadeValue, zzTimeUsed;

	if (zzbDoScreenshot)
	{
		if (zzMagicCode != "")
			xxDrawLogo(zzC, 10, zzC.ClipY - 128, 0.75);
		zzbDoScreenshot = zzFalse;
		zzbReportScreenshot = zzTrue;
	}

	if (zzbLogoDone)
		return;

	if (!zzbDidMD5)
		zzLogoStart = Level.TimeSeconds;

	zzTimeUsed = Level.TimeSeconds - zzLogoStart;
	if (zzTimeUsed > 5.0)
	{
		zzbLogoDone = True;
		zzbRenderHUD = True;
		return;
	}

	if (zzTimeUsed > 3.0)
	{
		if (!zzbRenderHUD)
			PlaySound(sound'SpeechWindowClick', SLOT_Interact);
		zzbRenderHUD = True;
		zzFadeValue = (5.0 - zzTimeUsed) / 2.0;
	}
	else
		zzFadeValue = 1.0;

	xxDrawLogo(zzC, 10, zzC.ClipY - 128, zzFadeValue);
}

exec function PureLogo()
{
	zzbLogoDone = False;
	zzLogoStart = Level.TimeSeconds;
}

// ==================================================================================
// AttachConsole - Adds our console
// ==================================================================================
simulated function xxAttachConsole()
{
	local PureSuperDuperUberConsole c;
	local UTConsole oldc;

	if (Player.Actor != Self)
		xxServerCheater("VA");

	if (zzMyConsole == None)
	{
		zzMyConsole = PureSuperDuperUberConsole(Player.Console);
		if (zzMyConsole == None)
		{
			// Initialize Logo Display
			zzbLogoDone = False;
			//
			Player.Console.Disable('Tick');
			c = New(None) class'PureSuperDuperUberConsole';
			if (c != None)
			{
				oldc = UTConsole(Player.Console);
				c.zzOldConsole = oldc;
				Player.Console = c;
				zzMyConsole = c;
				zzMyConsole.xxGetValues(); //copy all values from old console to new
			}
			else
			{
            			zzbBadConsole = zzTrue;
			}
		}
	}
	// Do not use ELSE or it wont work correctly

	zzbBadConsole = (Player.Console.Class != Class'PureSuperDuperUberConsole');
}

function xxServerCheater(string zzCode)
{
	local string zzs;
	local Pawn zzP;

	if (zzbBadGuy)
		return;

	if (Len(zzCode) == 2)
	{
		if (zzCode == "BC")
			zzs = "Bad Console!";
		else if (zzCode == "BA")
			zzs = "Bad Canvas!";
		else if (zzCode == "SM")
			zzs = "Should not happen!";
		else if (zzCode == "TF")
			zzs = "Possible heavy ping/packetloss!";
		else if (zzCode == "IC")
			zzs = "Console not responding!";
		else if (zzCode == "HR")
			zzs = "HUD Replaced!";
		else if (zzCode == "FM")
			zzs = "Failed Mutator!";
		else if (zzCode == "AV" || zzCode == "TB" || zzCode == "FF")
			zzs = "Hacked Pure?";
		else if (zzCode == "PT")
			zzs = "Should not happen!";
		else if (zzCode == "AL")
			zzs = "Failed Adminlogin 5 times!";
		else if (zzCode == "NC")
			zzs = "Excess netspeed changes!";
		else if (zzCode == "S1" || zzCode == "S2")
			zzs = "Client Tampering!";
		else if (zzCode == "ZD")
			zzs = "Noshadow TCCs!";
		else if (zzCode == "ZE")
			zzs = "Other TCCs!";
		else if (zzCode == "HA")
			zzs = "Bloody not good (Pure messed up??)";
		else if (zzCode == "MT")
			zzs = "Mutator Kick!";
		else if (zzCode == "BL")
			zzs = "Bad Lighting!";
		else if (zzCode == "TD")
			zzs = "Bad TimeDilation!";
		else if (zzCode == "MS")
			zzs = "Illegal Variable Change!";
		else if (zzCode == "BN")
			zzs = "Player was Banned!";
		else
			zzs = "UNKNOWN!";
		zzCode = zzCode@"-"@zzs;
	}
	xxCheatFound(zzCode);
	zzs = GetPlayerNetworkAddress();
	zzs = Left(zzs, InStr(zzs, ":"));
	zzUTPure.xxLogDate("UTPureCheat:"@PlayerReplicationInfo.PlayerName@"("$zzs$") ("$zzComputerName$") had an impurity ("$zzCode$")", Level);
	if (zzUTPure.bTellSpectators)
	{
		for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
		{
			if (zzP.IsA('MessagingSpectator'))
				zzP.ClientMessage(PlayerReplicationInfo.PlayerName@zzs@"Pure:"@zzCode);
		}
	}
	Destroy();
	zzbBadGuy = True;
}

// ==================================================================================
// CheatFound
// ==================================================================================
simulated function xxCheatFound(string zzCode)
{
	local UTConsole zzcon;

	if (zzbBadGuy)
		return;
	zzbBadGuy = True;

	if (zzMyConsole == None || zzCon == None)
		return;

	zzMyconsole.xxRevert();
	zzCon = zzMyconsole.zzOldConsole;
	zzCon.AddString( "=====================================================================" );
	zzCon.AddString( "  UTPure has detected an impurity hiding in your client!" );
	zzCon.AddString( "  ID:"@zzCode );
	zzCon.AddString( "=====================================================================" );
	zzCon.AddString( "Because of this you have been removed from the" );
	zzCon.AddString( "server.  Fair play is important, remove the impurity" );
	zzCon.AddString( "and you can return!");
	zzCon.AddString( " ");
	zzCon.AddString( "If you feel this was in error, please contact the admin" );
	zzCon.AddString( "at: "$GameReplicationInfo.AdminEmail);
	zzCon.AddString( " ");
	zzCon.AddString( "Please visit http://forums.utpure.com" );
	zzCon.AddString( "You can read info regarding what UTPure is and maybe find a fix there!" );

	if (int(Level.EngineVersion) < 436)
	{
		zzCon.AddString(" ");
		zzCon.AddString("You currently have UT version"@Level.EngineVersion$"!");
		zzCon.AddString("In order to play on this server, you must have version 436 or greater!");
		zzCon.AddString("To download newest patch, go to: http://unreal.epicgames.com/Downloads.htm");
	}
	zzCon.bQuickKeyEnable = True;
	zzCon.LaunchUWindow();
	zzCon.ShowConsole();
}

simulated function String GetItemName( string FullName )	// Originally not Simulated .. wtf!
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	// Hack to prevent usage of Bad texture.
	if (FaceName ~= "SoldierSkins.Ivan")
		FaceName = "SoldierSkins.Von";
	Super.SetMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
}

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
local Texture NewSkin;
local bool bProscribed;
local string pkg, SkinItem, MeshName;


	if (Default.zzMyPacks == "")
		Default.zzMyPacks = Caps(SkinActor.ConsoleCommand("get engine.gameengine serverpackages"));

	if ( (SkinActor.Level.NetMode != NM_Standalone)	&& (SkinActor.Level.NetMode != NM_Client) && (DefaultSkinName != "") )
	{
		// make sure that an illegal skin package is not used
		// ignore if already have skins set
		if ( SkinActor.Mesh != None )
			MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));
		else
			MeshName = SkinActor.GetItemName(string(SkinActor.Default.Mesh));
		SkinItem = SkinActor.GetItemName(SkinName);
		pkg = Left(SkinName, Len(SkinName) - Len(SkinItem) - 1);
		bProscribed = !xxValidSP(SkinName, MeshName);
		if ( bProscribed )
			log("Attempted to use illegal skin from package "$pkg$" for "$Meshname);
	}

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( !bProscribed && (NewSkin != None) )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName$" so load "$DefaultSkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}

static function string xxGetClass(string zzClassname)
{
	local string zzcls;
	local int zzp;

	zzcls = Caps(zzClassname);
	zzp = instr(zzcls,".");
	return left(zzcls,zzp);
}

static function bool xxValidSP(string zzSkinName, string zzMeshName)
{
	local int zzp;
	local string zzPackName;

	zzPackName = xxGetClass(zzSkinName);

	zzp  = Instr(Default.zzMyPacks, Chr(34)$zzPackName$Chr(34));
	if (zzp == -1 || zzPackName ~= "BOTPACK" || zzPackName ~= "UNREALI" || zzPackName ~= "UNREALSHARE")
    	return false;

  	return (Left(zzPackName, Len(zzMeshName)) ~= zzMeshName && !(Right(zzSkinName,2) ~= "t_"));
}

exec function Set(optional string zzs)
{
	xxSet(zzs, Level.NetMode);
}

function xxSet(string zzs, byte zzNetMode)
{
	if (zzNetMode != 3)
		zzUTPure.ConsoleCommand("set"@zzs);
	else
	{
		if (Left(zzs, 6) ~= "input " && InStr(Caps(zzs), "MOUSE") < 0)
			xxClientSet("set"@zzs);
		Mutate("ps"@zzs);
	}
}

function xxClientSet(string zzs)
{
	if (!zzbDemoPlayback)
		zzInfoThing.ConsoleCommand(zzs);
}

simulated function xxClientDoEndShot()
{
	if (bDoEndShot)
	{
		bShowScores = True;
		zzbDoScreenshot = True;
	}
}

// Try to set the pause state; returns success indicator.
function bool SetPause( BOOL bPause )
{	// Added to avoid accessed nones in demos
	if (Level.Game != None)
		return Level.Game.SetPause(bPause, self);
	return false;
}

exec function SetName( coerce string S )
{
	if ( Len(S) > 28 )
		S = left(S,28);
	ReplaceText(S, " ", "_");
	zzDelayedName = S;
	zzDelayedStartTime = Level.TimeSeconds;
}

function ChangeName( coerce string S )
{
	if (Level.TimeSeconds - zzDelayedStartTime > 2.5)
	{
		if (zzNameChanges < 3)
		{
			Level.Game.ChangeName( self, S, false );
			zzNameChanges++;
		}
	}
	zzDelayedStartTime = Level.TimeSeconds;
}

function SetVoice(class<ChallengeVoicePack> V)
{
	zzDelayedVoice = V;
	zzDelayedStartTime = Level.TimeSeconds;
}

function ServerSetVoice(class<ChallengeVoicePack> V)
{
	if (Level.TimeSeconds - zzDelayedStartTime > 2.5)
	{
		PlayerReplicationInfo.VoiceType = V;
		zzDelayedStartTime = Level.TimeSeconds;
	}
	else
		zzKickReady++;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	if (Level.TimeSeconds - zzLastSpeech > 1.0)
	{
		V = Spawn( PlayerReplicationInfo.VoiceType, Self );
		if (V != None)
			V.PlayerSpeech( Type, Index, Callsign );
		zzLastSpeech = Level.TimeSeconds;
	}
	else
		zzKickReady++;
}

exec function ViewPlayerNum(optional int num)
{
	if (zzLastView != Level.TimeSeconds)
	{
		DoViewPlayerNum(num);
		zzLastView = Level.TimeSeconds;
	}
}

function DoViewPlayerNum(int num)
{
	local Pawn P;

	if ( !PlayerReplicationInfo.bIsSpectator && !Level.Game.bTeamGame )
		return;
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
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
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
	if (zzLastView != Level.TimeSeconds)
	{
		Super.ViewPlayer(S);
		zzLastView = Level.TimeSeconds;
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

exec function BehindView( Bool B )
{
	if (Class'UTPure'.Default.bAllowBehindView)
		bBehindView = B;
	else if (ViewTarget != None && ViewTarget != Self)
		bBehindView = B;
	else
		bBehindView = False;
}

// Wiped due to lack of unusefulness
exec function ShowPath();

exec function ShowInventory();

exec function ToggleInstantRocket()
{
	bInstantRocket = !bInstantRocket;
	ServerSetInstantRocket(bInstantRocket);
	ClientMessage("Instant Rockets :"@bInstantRocket);
}

exec function ShowStats(optional byte zzType)
{
	if (zzStat != None)
		zzStat.SetState(zzType);
}

function AttachStats(PureStats zzS, PureStatMutator zzM)
{
	zzStat = zzS;
	zzStatMut = zzM;
}

function PureStats GetStats()
{
	return zzStat;
}

exec function NeverSwitchOnPickup( bool B )
{
	bNeverAutoSwitch = B;
	bNeverSwitchOnPickup = B;
	ServerNeverSwitchOnPickup(B);
}

// Administrator functions
exec function Admin( string CommandLine )
{
	local string Result;
	if( bAdmin )
		Result = ConsoleCommand( CommandLine );

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
		zzUTPure.xxLog("Admin is"@PlayerReplicationInfo.PlayerName);
	}
	else if (zzAdminLoginTries == 5)
		xxServerCheater("AL");
}

exec function AdminLogout()
{
	Level.Game.AdminLogout( Self );
	zzUTPure.xxLog("Admin was"@PlayerReplicationInfo.PlayerName);
}


exec function Sens(float F)
{
	UpdateSensitivity(F);
}

exec function NewNetCode(bool bUseIt)
{
	bNewNetCode = bUseIt;
	xxServerSetNetCode(bNewNetCode);
	SaveConfig();
}

exec function NoRevert(bool b)
{
	bNoRevert = b;
	xxServerSetNoRevert(b);
	SaveConfig();
}

exec function HitSounds(bool b)
{
	bHitSounds = b;
	xxServerSetHitSounds(b);
	SaveConfig();
}

exec function TeamInfo(bool b)
{
	bTeamInfo = b;
	xxServerSetTeamInfo(b);
	SaveConfig();
}

function xxServerSetNetCode(bool bNewCode)
{
	bNewNetCode = bNewCode;
	if (bNewNetCode)
		MaxPosError = 6.0;
	else
		MaxPosError = 3.0;
}

function xxServerSetNoRevert(bool b)
{
	bNoRevert = b;
}

function xxServerSetHitSounds(bool b)
{
	local int zzLevel;

	if (b)
	{
		if (zzUTPure != None)
		{
			if (zzUTPure.bHitSounds)
			{
				zzLevel++;
				if (zzUTPure.bTeamHitSounds)
					zzLevel++;
			}
		}
		else if (zzbDemoPlayback)
			zzLevel = 3;
	}

	zzHitSounds = zzLevel;			// 0 = disabled, 1 = Only when hit enemy, 2 = When hit enemy & team, 3 (demos)
}

function xxServerSetTeamInfo(bool b)
{
	if (zzUTPure != None && zzUTPure.ImprovedHUD > 0)
	{
		if (b)				// Show team info as well if server allows
			zzHUDInfo = zzUTPure.ImprovedHUD;
		else				// Show improved hud. (Forced by server)
			zzHUDInfo = 1;
	}
	else
		zzHUDInfo = 0;
}

exec function EndShot(optional bool b)
{
	bDoEndShot = b;
	ClientMessage("Screenshot at end of match:"@b);
	SaveConfig();
}

exec function Hold()
{
	if (zzUTPure.zzAutoPauser != None)
		zzUTPure.zzAutoPauser.PlayerHold(PlayerReplicationInfo);
}

exec function Go()
{
	if (zzUTPure.zzAutoPauser != None)
		zzUTPure.zzAutoPauser.PlayerGo(PlayerReplicationInfo);
}

function xxServerAckScreenshot(string zzResult, string zzMagic)
{
	local Pawn zzP;
	local PlayerPawn zzPP;
	local bool zzb;
	local string zzs;

	zzb = (InStr(zzMagic, zzMagicCode) >= 0) && (InStr(zzMagic, zzComputerName) >= 0);

	if (zzb)
		zzs = zzMagic@" Screenshot taken!";
	else
		zzs = PlayerReplicationInfo.PlayerName@"failed/illegal screenshot return!"@zzMagic;

	for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
	{
		zzPP = PlayerPawn(zzP);
		if (zzPP != None && zzPP.bAdmin)

			zzPP.ClientMessage(zzs);
	}
	zzUTPure.xxLog("Screenshot from"@zzPP.PlayerReplicationInfo.PlayerName@"->"@zzResult@zzMagic@"Valid?"@zzb);
}

function xxServerReceiveINT(string zzs)
{
	if (zzs == "")
	{
		bRemValid = True;
		Mutate("pir"@zzRemCmd@zzRemResult);
		bRemValid = False;
		zzRemCmd = zzs;
		zzRemResult = zzs;

	}
	else
		zzRemResult = zzRemResult$"("$zzs$")";
}

simulated function xxClientReadINT(string zzClass)
{
	local int zzx;
	local string zzEntry, zzDesc, zzs;

	if (Level.NetMode == NM_DedicatedServer)
	{
		zzRemCmd = "";	// Oooops, no client to receive
		return;		// Dont run on server (in case of disconnect)
	}

	while (zzx < 50)
	{
		GetNextIntDesc( zzClass, zzx, zzEntry, zzDesc);
		if (zzEntry == "")
			break;
		zzx++;
		zzs = zzEntry$","$zzDesc;
		xxServerReceiveINT(zzs);
		xxClientLogToDemo(zzs);
	}
	xxServerReceiveINT("");
}

function xxServerReceiveConsole(string zzs, bool zzbLast)
{
	if (zzbLast)
	{
		bRemValid = True;
		Mutate("pcr"@zzRemCmd@zzRemResult);
		bRemValid = False;
		zzRemCmd = "";
		zzRemResult = "";
	}
	else
		zzRemResult = zzRemResult$zzs;
}

simulated function xxClientConsole(string zzCon, int zzc)
{	// Does a console command, splits up the result, and sends back to server after splitting up
	local int zzx, zzl;
	local string zzs;
	local string zzRes;

	if (Level.NetMode == NM_DedicatedServer)
	{
		zzRemCmd = "";	// Oooops, no client to receive
		return;		// Dont run on server (in case of disconnect)
	}

	zzRes = zzInfoThing.ConsoleCommand(zzCon);

	zzl = Len(zzRes);
	while (zzl > zzx)
	{
		zzs = Mid(zzRes, zzx, zzc);
		xxServerReceiveConsole(zzs, False);
		xxClientLogToDemo(zzs);
		zzx += zzc;
	}
	xxServerReceiveConsole("", True);
}

function xxServerReceiveKeys(string zzIdent, string zzValue, bool zzbBind, bool zzbLast)
{
	if (zzbLast)
	{
		bRemValid = True;
		Mutate("pkr"@zzRemCmd@zzRemResult);
		bRemValid = False;
		zzRemCmd = "";
		zzRemResult = "";
	}
	else
	{
		if (zzbBind)
		{
			zzRemResult = zzRemResult$"A("$zzIdent$"="$zzValue$")";
		}
		else
		{
			zzRemResult = zzRemResult$"B("$zzIdent$"="$zzValue$")";
		}
	}
}

simulated function xxClientKeys(bool zzbKeysToo)
{
	local int zzx;
	local string zzs;
	local PureSystem zzPureInput;

	if (Level.NetMode == NM_DedicatedServer)
	{
		zzRemCmd = "";	// Oooops, no client to receive
		return;		// Dont run on server (in case of disconnect)
	}

	zzPureInput = PurePlayer.zzInput;

	if (zzPureInput != None)
	{
		for (zzx = 0; zzx < 10; zzx++)
		{
			xxSendKeys(string(zzPureInput.zzAliases1[zzx].zzAlias), zzPureInput.zzAliases1[zzx].zzCommand, True, False);
		}
		for (zzx = 0; zzx < 10; zzx++)
		{
			xxSendKeys(string(zzPureInput.zzAliases2[zzx].zzAlias), zzPureInput.zzAliases2[zzx].zzCommand, True, False);
		}
		for (zzx = 0; zzx < 10; zzx++)
		{
			xxSendKeys(string(zzPureInput.zzAliases3[zzx].zzAlias), zzPureInput.zzAliases3[zzx].zzCommand, True, False);
		}
		for (zzx = 0; zzx < 10; zzx++)
		{
			xxSendKeys(string(zzPureInput.zzAliases4[zzx].zzAlias), zzPureInput.zzAliases4[zzx].zzCommand, True, False);
		}
		if (zzbKeysToo)
		{
			for (zzx = 0; zzx < 255; zzx++)
			{
				zzs = Mid(string(GetEnum(Enum'EInputKey', zzx)), 3);
				xxSendKeys(zzs, zzPureInput.zzKeys[zzx], False, False);
			}
		}
	}
	xxServerReceiveKeys("", "", False, True);
}

simulated function xxSendKeys(string zzIdent, string zzValue, bool zzbBind, bool zzbLast)
{
	xxServerReceiveKeys(zzIdent, zzValue, zzbBind, zzbLast);
	xxClientLogToDemo(zzIdent$"="$zzValue);
}

simulated function xxClientLogToDemo(string zzs)
{
	Log(zzs, 'DevGarbage');
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{	// Slightly improved GetWeapon
	local Inventory Inv;

	if ( (Inventory == None) || (NewWeaponClass == None)
		|| ((Weapon != None) && Weapon.IsA(NewWeaponClass.Name)) )
		return;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.IsA(NewWeaponClass.Name) )
		{
			PendingWeapon = Weapon(Inv);
			if ( (PendingWeapon.AmmoType != None) && (PendingWeapon.AmmoType.AmmoAmount <= 0) )
			{
				Pawn(Owner).ClientMessage( PendingWeapon.ItemName$PendingWeapon.MessageNoAmmo );
				PendingWeapon = None;
				return;
			}
			Weapon.PutDown();
			return;
		}
}

function ChangedWeapon()
{
	if (Weapon != None && bFWS)
	{
		Weapon.GotoState('');
		Weapon.ClientPutDown(PendingWeapon);
	}
	Super.ChangedWeapon();
	zzWeapon = Weapon;
}

//enhanced teamsay:
exec function TeamSay( string Msg )
{
	local string OutMsg;
	local string cmd;
	local int pos,i, zzi;
	local int ArmorAmount;
	local inventory inv;

	local int x;
	local int zone;  // 0=Offense, 1 = Defense, 2= float
	local flagbase Red_FB, Blue_FB;
	local CTFFlag F,Red_F, Blue_F;
	local float dRed_b, dBlue_b, dRed_f, dBlue_f;

	if (!Class'UTPure'.Default.bAdvancedTeamSay || PlayerReplicationInfo.Team == 255)
	{
		Super.TeamSay(Msg);
		return;
	}

	pos = InStr(Msg,"%");

	if (pos>-1)
	{
		for (i=0; i < 100; i = 1)
		{
			if (pos > 0)
			{
				OutMsg = OutMsg$Left(Msg,pos);
				Msg = Mid(Msg,pos);
				pos = 0;
			}

			x = len(Msg);
			cmd = Mid(Msg,pos,2);
			if (x-2 > 0)
				Msg = Right(Msg,x-2);
			else
				Msg = "";

			if (cmd == "%H")
			{
				OutMsg = OutMsg$Health$" Health";
			}
			else if (cmd == "%h")
			{
				OutMsg = OutMsg$Health$"%";
			}
			else if (cmd ~= "%W")
			{
				if (Weapon == None)
					OutMsg = OutMsg$"Empty hands";
				else
					OutMsg = OutMsg$Weapon.GetHumanName();
			}
			else if (cmd == "%A")
			{
				ArmorAmount = 0;
				for( Inv=Inventory; Inv != None; Inv = Inv.Inventory )
				{
					if (Inv.bIsAnArmor)
					{
						if ( Inv.IsA('UT_Shieldbelt') )
							OutMsg = OutMsg$Inv.Charge@"Shieldbelt and ";
						else
							ArmorAmount += Inv.Charge;
					}
				}
				OutMsg = OutMsg$ArmorAmount$" Armor";
			}
			else if (cmd == "%a")
			{
				ArmorAmount = 0;
				for( Inv=Inventory; Inv != None; Inv = Inv.Inventory )
				{
					if (Inv.bIsAnArmor)
					{
						if ( Inv.IsA('UT_Shieldbelt') )
							OutMsg = OutMsg$Inv.Charge$"SB ";
						else
							ArmorAmount += Inv.Charge;
					}
				}
				OutMsg = OutMsg$ArmorAmount$"A";
			}
			else if (cmd ~= "%P" && GameReplicationInfo.IsA('CTFReplicationInfo')) //CTF only
			{
			        // Figure out Posture.

				for (zzi=0; zzi < 4; zzi++)
				{
					f = CTFReplicationInfo(GameReplicationInfo).FlagList[zzi];
					if (f == None)
						break;
					if (F.HomeBase.Team == 0)
						Red_FB = F.HomeBase;
					else if (F.HomeBase.Team == 1)
						Blue_FB = F.HomeBase;
					if (F.Team == 0)
						Red_F = F;
					else if (F.Team == 1)
						Blue_F = F;
				}

				dRed_b = VSize(Location - Red_FB.Location);
				dBlue_b = VSize(Location - Blue_FB.Location);
				dRed_f = VSize(Location - Red_F.Position().Location);
				dBlue_f = VSize(Location - Blue_F.Position().Location);

				if (PlayerReplicationInfo.Team == 0)
				{
					if (dRed_f < 2048 && Red_F.Holder != None && (Blue_f.Holder == None || dRed_f < dBlue_f))
						zone = 0;
					else if (dBlue_f < 2048 && Blue_F.Holder != None && (Red_f.Holder == None || dRed_f > dBlue_f))
						zone = 1;
					else if (dBlue_b < 2049)
						zone = 2;
					else if (dRed_b < 2048)
						zone = 3;
					else
						zone = 4;
				}
				else if (PlayerReplicationInfo.Team == 1)
				{
					if (dBlue_f < 2048 && Blue_f.Holder != None && (Red_f.Holder == None || dRed_f >= dBlue_f))
						zone = 0;
					else if (dRed_f < 2048 && Red_f.Holder != None && (Blue_f.Holder == None || dRed_f < dBlue_f))
						zone = 1;
					else if (dRed_b < 2048)
						zone = 2;
					else if (dBlue_b < 2048)
						zone = 3;
					else
						zone = 4;
				}

				if ( (Blue_f.Holder == Self) || (Red_f.Holder == Self) )
					zone = 5;

				Switch(zone)
				{
					Case 0:	OutMsg = OutMsg$"Attacking Enemy Flag Carrier";
						break;
					Case 1: OutMsg = OutMsg$"Supporting Our Flag Carrier";
						break;
					Case 2: OutMsg = OutMsg$"Attacking";
						break;
					Case 3: OutMsg = OutMsg$"Defending";
						break;
					Case 4: OutMsg = OutMsg$"Floating";
						break;
					Case 5: OutMsg = OutMsg$"Carrying Flag";
						break;
				}
			}
			else if (cmd == "%%")
			{
				OutMsg = OutMsg$"%";
			}
			else
			{
				OutMsg = OutMsg$cmd;
			}

			Pos = InStr(Msg,"%");

			if (Pos == -1)
				break;
		}

		if (Len(Msg) > 0)
		OutMsg = OutMsg$Msg;
	}
	else
		OutMsg = Msg;

	Super.TeamSay(OutMsg);
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if (bTyping)
	{
		PlayChatting();
	}
}

////////////////////////////
// Tracebot stopper: By DB
////////////////////////////

function bool xxCanFire()
{
	return (Role==ROLE_Authority || (Role<ROLE_Authority && zzbValidFire));
}

function xxStopTracebot()
{
	if (!zzbValidFire)
	{
		zzbValidFire = zzTrue;
		bFire = zzbFire;
		bAltFire = zzbAltFire;
		bJustFired = zzFalse;
		bJustAltFired = zzFalse;
	}
	zzbStoppingTraceBot = !zzbValidFire;
}

function xxCleanAvars()
{
	aMouseX = zzNull;
	aMouseY = zzNull;
	aTurn = zzNull;
	aUp = zzNull;
}

defaultproperties
{
	bNewNetCode=False
	bNoRevert=False
	bForceModels=False
	bHitSounds=True
	bTeamInfo=True
	bDoDemo=False
	DemoMask="%l_[%y_%m_%d_%t]_[%c]_%e"
	DemoPath=""
	MaxPosError=3.0
}
