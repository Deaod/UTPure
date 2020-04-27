// ====================================================================
//  Class:  UTPure.UTPure
//  Parent: Engine.Mutator
//
//  This mutator does it all
// ====================================================================
// (C) 2001, Midnight Interactive
// ====================================================================

// Added by TNSe

// RC5b2:
// Added: new config, bUseClickboard, set to True in .int

// RC5c:
// Added: MinClientRate, minimum Client Rate allowed
// Added: Mutate PureShowIPs (Admin only)
// Added: Mutate PureShowTickrate
// Added: Mutate PureShowNetSpeeds

// RC5p:
// Added: bUTPureEnabled, allows enabling/disabling of pure without messing with ini's.
// Added: A check to see if server admin wants UTPure enabled or disabled in SetupUTPure().
// Added: Mutate EnablePure and Mutate DisablePure to toggle this.
// Added: Mutate ShowIDs , shows the id of players on server, to be used with:
// Added: Mutate KickID <number>, kicks a player with the ID given by ShowIDs
// Added: Mutate BanID <number>, bans a player with the ID given by ShowIDs
// Added: Transform Commander, Spectator & CHSpectator into our own bbCHSpectator!

// RC5T:
// Added: Anti-Timer Code
// Added: bAdvancedTeamSay, Enable or disable the advanced teamsay.
// Added: MaxClientPosError, to specify how much error they may accumulate before server updates pos.

// RC5w:
// Added: UsAaR33's CRC routines and stuff.

// RC5z:
// Added: Some Pause code/Tick Code to handle timers & pausing better.

// RC53:
// Added: Option for Hit sounds. When you hit other players, you'll get a signal back that you did hit.
//        Mutate EnableHitSounds / Mutate DisableHitSounds

// RC54:
// Added: bAllowBehindView
// Fixed: bHitSounds=False by default.

// RC55:
// Added: Level.Game.SentText - 100 to avoid the "Pause Bug"
// Added: More than 10 netspeed changes in a match = kick. (NC)
// Added: ForceSettingsLevel, The level of which ini cheats & hacks/defaults, bHidden etcetc are enforced.
// Added: Fixed some troubles with hacking pure to ignore checking main paths first (it went straight for cache with hack)

// RC56:
// Added: All new huds for DM, TDM, CTF, DOM & Assault, to stop Weapon.uc.PostRender radars.

// RC57:
// Added: Complete UCRC... If this doesn't stop them, what will....

// RC6A:
// Changed: UCRC Code now finds the paths for the RealCRC.
// Fixed: Added code to work with Mac Cache (MAC cache cuts off first 5 chars of the GUID....)

// RC6B:
// Added: bLogClientPackages, when set to true, it will log the packages the clients have
// Changed: Made the Package Logging split up over several lines to avoid crashing server :x
// Added: An xxLogDate(), which will log things with name UTPure and add Date/Time.

// RC6C:
// Added: The package data is now stored in the .int file. Much associated structures & data added.
//	They are grouped, and each client must have minimum & maximum 1 from each group.
// Added: bNoLockdown, to avoid pulse/mini related lockdown effects
// Added: bTeamHitSounds, to give team related hit sounds
// Changed/Added: UWeb.u is now CRC'ed, but this doesn't really get used. It is only used to see that the crc routine is intact.

// RC6D:
// Added: ServerInfoClass, so we get that to clients....

// RC6E:
// Changed: zzOKOBJ from 16 to 37 (32+5)

// RC7A:
// Removed: Everything with regards to OBJ Linkers (UCRC)
// Removed: Everything with regards to CRC
// Added: Warmup!	config: bWarmup
// Added: Coaches!	config: bCoaches
// Added: AutoPause!	config: bAutoPause
// --- Added: No Overtime!	config: bNoOvertime <-- DAMN EPIC SUCKS... They didn't do this "good"
// Added: ForceModels, 0 = Not allowed, 1 = Allowed, 2 = Forced
// Added: Improved HUD!	config: ImprovedHUD
// Added: bDelayedPickupSpawn

// RC7D:
// Fixed: AutoPause countdown speed
// Fixed: Flags & Warmup, no more sillystuff there.
// Fixed: Endgame sends a screenshot warning.
// Added: MT ... Mutator Pure Kick Method.
// Added: PCD/PCF/PCR - Pure Console Do/Fail/Reply - Performs remote console commands
// Added: PID/PIF/PIR - Pure INT Do/Fail/Reply - Performs reading of remote INT files
// Added: PKD/PKF/PKR - Pure Key Do/Fail/Reply - Performs reading of remote Alias/Keys
// Added: bTellSpectators - When true, it will message all MessagingSpectators that someone was dropped

// RC7F:
// Added: bNoWeaponThrow - Disables usage of Weapon Throw.
// Fixed: Warmup for Domination
// Added: AutoDemoRec forcing (bForceDemo)

// RC7H:
// Added: ComputerName to PureShowIPs.
// Fixed: FirstBlood is now reset after Warmup.

class UTPure extends Mutator;

var ModifyLoginHandler NextMLH;			// Link list of handlers

// Enable or disable.
var localized config bool bUTPureEnabled;	// Possible to enable/disable UTPure without changing ini's
// Advertising
var localized config byte Advertise;		// Adds [CSHP] to the Server Name
var localized config byte AdvertiseMsg;		// Decides if [CSHP] or [PURE] will be added to server name
// CenterView
var localized config bool bAllowCenterView;	// Allow use of CenterView
var localized config float CenterViewDelay;	// How long before allowing use of CenterView again
// BehindView
var localized config bool bAllowBehindView;	// Allow use of BehindView
// Others
var localized config byte TrackFOV;		// Track the FOV cheats [0 = no, 1 = strict, 2 = loose]
var localized config bool bAllowMultiWeapon;	// if true allows the multiweapon bug to be used on server.
var localized config bool bFastTeams;		// Allow quick teams changes
var localized config bool bUseClickboard;	// Use clickboard in Tournament Mode or not
var localized config int MinClientRate;		// Minimum allowed client rate.
var localized config bool bAdvancedTeamSay;	// Enable or disable Advanced TeamSay.
var localized config bool bHitSounds;		// Enable or disable Hit Sounds.
var localized config bool bTeamHitSounds;	// Enable or disable HitSounds when you hit team.
var localized config byte ForceSettingsLevel;	// 0 = off, 1 = PostNetBeginPlay, 2 = SpawnNotify, 3 = Intervalled
var localized config bool bNoLockdown;		// Enable or disable to have Lockdown when players get hit by mini/pulse
var localized config bool bWarmup;		// Enable or disable warmup. (bTournament only)
var localized config bool bCoaches;		// Enable or disable coaching. (bTournament only)
var localized config bool bAutoPause;		// Enable or disable autopause. (bTournament only)
//var localized config byte ForceModels;		// 0 = Disallow, 1 = Client Selectable, 2 = Forced
var localized config byte ImprovedHUD;		// 0 = Disabled, 1 = Boots/Clock, 2 = Enhanced Team Info
var localized config bool bDelayedPickupSpawn;	// Enable or disable delayed first pickup spawn.
//var localized config bool bNoOvertime;		// Set to True to disable overtime.
var localized config bool bTellSpectators;	// Enable or disable telling spectators of reason for kicks.
var localized config bool bNoWeaponThrow;	// Enable or disable Weapon Throwing
var localized config bool bForceDemo;		// Forces clients to do demos.
//var localized config bool bPureBans;		// Set to true if to use Pure Banning System (tm)
var localized config string PlayerPacks[8];	// Config list of supported player packs


// Nice variables.
var float zzTeamChangeTime;			// This would be to Prevent Team Change Spamming
var bool zzbWarmupPlayers;			// Do we have any players warming up?
var DeathMatchPlus zzDMP;			// A place to store the Game Object.
var string VersionStr;				// Holds the version code from VUC++
var string LongVersion;				// Holds the version code from VUC++
var string ThisVer;				// Holds the version letters
var string BADminText;				// Text to give players that want admin commands without being admin.
var bool bDidEndWarn;				// True if screenshot warning has been sent to players.

// Anti-Timer
var Inventory zzAntiTimerList[32];		// This holds the inventory on the map that should be protected
var int zzAntiTimerListCount;			// How many in the list
var int zzAntiTimerListState;			// The state of the pickups, calculated each tick

// Pause control (for Event PlayerCalcView)
var bool	zzbPaused;			// Game has been paused at one time.
var float	zzPauseCountdown;		// Give 120 seconds of "ignore FT"

// Auto Pause Handler
var PureAutoPause	zzAutoPauser;

// Ban Handler
//var PureBanHandler	zzPureBanHandler;

// What server info is used
var Class<ServerInfo> zzSI;

// MD5 Stuff
var string zzPurePackageName;
var string zzMD5KeyInit;
var string zzPureMD5;

function PreBeginPlay()
{
	zzDMP = DeathMatchPlus(Level.Game);
	if (zzDMP == None)
		return;

	if (zzDMP.HUDType == Class'ChallengeDominationHUD')
		zzDMP.HUDType = Class'PureDOMHUD';
	else if (zzDMP.HUDType == Class'ChallengeCTFHUD')
		zzDMP.HUDType = Class'PureCTFHUD';
	else if (zzDMP.HUDType == Class'AssaultHUD')
		zzDMP.HUDType = Class'PureAssaultHUD';
	else if (zzDMP.HUDType == Class'ChallengeTeamHUD')
		zzDMP.HUDType = Class'PureTDMHUD';
	else if (zzDMP.HUDType == Class'ChallengeHUD')
		zzDMP.HUDType = Class'PureDMHUD';

	zzSI = Class<ChallengeHUD>(zzDMP.HUDType).Default.ServerInfoClass;	
}

function PostBeginPlay()
{
	local int i;
	local class<ModifyLoginHandler> MLHClass;
	local ModifyLoginHandler        MLH;
	local int	ppCnt;
	local string	ServPacks, curMLHPack, sTag, fullpack;
	local string zzMD5Values;

	Super.PostBeginPlay();

	xxLog("###############################");
	xxLog("#          UTPure             #");
	if (zzDMP == None)
	{
		xxLog("#          ERROR!             #");
		xxLog("#    Game is not based on     #");
		xxLog("#      DeathMatchPlus!        #");
		xxLog("###############################");
		bUTPureEnabled = False;
		Disable('Tick');
		return;
	}
	else
	{
		xxLog("#       ver 1.0.RC"$ThisVer$"          #");
		xxLog("###############################");
	}
	xxLog("");

	if (AdvertiseMsg == 0)
		sTag = "[CSHP]";
	else if (AdvertiseMsg == 1)
		sTag = "[PURE]";
	else
		sTag = "[PWND]";
	
	// Setup name advertising
	if ( (Advertise>0)  && (Level.NetMode != NM_Standalone) && (instr(zzDMP.GameReplicationInfo.ServerName,sTag)==-1) )
	{
		if (Advertise==1)
			zzDMP.GameReplicationInfo.ServerName = sTag@zzDMP.GameReplicationInfo.ServerName;
		else if (Advertise==2)
			zzDMP.GameReplicationInfo.ServerName = zzDMP.GameReplicationInfo.ServerName@sTag;
	}
	
	for (i = 0; PlayerPacks[i] != ""; i++);
	ppCnt = i;
		
	ServPacks = Caps(ConsoleCommand("get engine.gameengine serverpackages"));
	// Create the ModifyLoginHandler chain list
	for (i = 0; PlayerPacks[i] != ""; i++)
	{
		
		// Verify that the PlayerPack Package is in ServerPackages
		curMLHPack = PlayerPacks[i]$"Handler"$ThisVer;
		fullpack = curMLHPack$"."$PlayerPacks[i]$"LoginHandler";
		if (Instr(CAPS(ServPacks), Caps(Chr(34)$curMLHPack$Chr(34))) != -1)
		{
			MLHClass = class<ModifyLoginHandler>(DynamicLoadObject(fullpack, class'Class'));
			if (MLHClass != None)
			{
				MLH = Spawn(MLHClass, self);
				if (MLH != None && MLH.CanAdd(ServPacks, ppCnt))
				{
					xxLog(" "$MLH.LogLine);
					if (NextMLH == None)
					{
						NextMLH = MLH;
						MLH.NextMLH = None;
					}
					else
						NextMLH.Add(MLH);
				}
			}
			else
				xxLog("Unable to load PlayerPack '"$fullpack$"' (File not found ?)");
		}
		else
			xxLog("You need to add 'ServerPackages="$curMLHPack$"' for PlayerPack["$i$"] to load");
	}
	zzDMP.RegisterMessageMutator(self);
	xxlog("");
	xxlog(" Protection is Active!");	
	xxlog("");
	xxlog("###############################");
	
	// Tell each ModifyLoginHandler They've been accepted
	for (MLH = NextMLH; MLH != None; MLH = MLH.NextMLH)
		MLH.Accepted();

	xxBuildAntiTimerList();

	zzMD5Values = "0123456789abcdef";
	for (i = 0; i < 32; i++)
	{
//		zzMD5KeyInit $= mid(zzMD5Values, rand(16), 1);
	}
	zzPurePackageName = Default.VersionStr$Default.ThisVer;
//	Log("Trying to get MD5 of"@zzPurePackageName@"with key"@zzMD5KeyInit);
//	zzPureMD5 = PackageMD5(zzPurePackageName, zzMD5KeyInit);
//	Log("MD5 Result"@zzPureMD5);

//	if (bPureBans)
//		zzPureBanHandler = Spawn(Class'PureBanHandlerServer');

	if (bAutoPause && zzDMP.bTeamGame && zzDMP.bTournament)
		zzAutoPauser = Spawn(Class'PureAutoPause');
	
	if (bUseClickboard && zzDMP.bTournament) 
		SetupClickBoard();
	
	if (ImprovedHUD == 2 && zzDMP.bTeamGame)
		xxReplaceTeamInfo();						// Do really nasty replacement of TeamInfo with Pures own.

	if (bDelayedPickupSpawn)
		Spawn(Class'PureDPS');

	SaveConfig();
}

function SetupClickBoard()
{
	local PureClickBoard PCB;

	foreach AllActors(class'PureClickBoard', PCB)
		return;
		
	PCB = Level.Spawn(Class'PureClickBoard');
	if (PCB != None)
	{
		PCB.NextMutator = Level.Game.BaseMutator;
		Level.Game.BaseMutator = PCB;
	}
}

function xxReplaceTeamInfo()
{
	local TeamGamePlus zzTGP;
	local int zzi;

	zzTGP = TeamGamePlus(zzDMP);
	if (zzTGP == None)
		return;
	
	// Copied directly from TeamGamePlus.PostBeginPlay.
	for (zzi = 0; zzi < 4; zzi++)
	{
		if (zzTGP.Teams[zzi] != None)		// Remove old and replace with Pures
			zzTGP.Teams[zzi].Destroy();
		zzTGP.Teams[zzi] = Spawn(class'PureTeamInfo');
		zzTGP.Teams[zzi].Size = 0;
		zzTGP.Teams[zzi].Score = 0;
		zzTGP.Teams[zzi].TeamName = zzTGP.TeamColor[zzi];
		zzTGP.Teams[zzi].TeamIndex = zzi;
		TournamentGameReplicationInfo(zzTGP.GameReplicationInfo).Teams[zzi] = zzTGP.Teams[zzi];
	}
}

// Helpfunction
static final function string xxGetPackage(string str)
{
	local int pos;

	pos = Instr(str, ".");
	if (pos == -1)
		return str;
	return Left(str, pos);
}

// TICK!!! And it's not the bug kind. Sorta :/
event Tick(float zzdelta)
{
	local int zzx;
	local bool zzb, zzbDoShot;
	local Pawn zzP;
	local bbPlayer zzbP;

	// Build visible/hidden list for pickups.
	zzAntiTimerListState = 0;
	for (zzx = 0; zzx < zzAntiTimerListCount; zzx++)
	{
		if (zzAntiTimerList[zzx] != None && zzAntiTimerList[zzx].bHidden)
			zzAntiTimerListState = zzAntiTimerListState | (1 << zzx);
	}

	if (Level.Pauser != "")		// This code is to avoid players being kicked when paused.
	{
		zzbPaused = True;
		zzPauseCountDown = 45.0; // Give it 45 seconds to wear off
		zzDMP.SentText = Max(zzDMP.SentText - 100, 0);	// Fix to avoid the "Pause text freeze bug"
	}
	else
	{
		if (zzPauseCountDown > 0.0)
			zzPauseCountDown -= zzdelta;
		else
			zzbPaused = False;
	}

	// Prepare players that are warming up for a game that is about to start.
	if (zzbWarmupPlayers)
	{
		if (Level.Game.IsA('CTFGame'))
			xxHideFlags();
		if (zzDMP.CountDown < 10)
			xxResetGame();
	}

	// Cause clients to force an actor check.
	if (ForceSettingsLevel > 2 && rand(5000) == 0)
		zzb = True;

	if (!bDidEndWarn && zzDMP.bGameEnded)
	{
		bDidEndWarn = True;
		zzbDoShot = True;
	}

	for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
	{
		zzbP = bbPlayer(zzP);
		if (zzbP != None)
		{
			zzbP.zzAntiTimerListState = zzAntiTimerListState;	// Copy the visible/hidden list for pickups.
			if (zzbP.zzOldNetspeed != zzbP.zzNetspeed)
			{
				zzbP.zzNetspeedChanges++;			// Detect changed netspeed
				zzbP.zzOldNetspeed = zzbP.zzNetspeed;
				if (zzbP.zzNetspeedChanges > 5)			// Netspeed change protection
					zzbP.xxServerCheater("NC");
			}
			if (zzb)
				zzbP.zzForceSettingsLevel++;
			if (zzbP.zzKickReady > 100)				// Spam protection
				zzbP.xxServerCheater("SK");
			if (zzbDoShot)
				zzbP.xxClientDoEndShot();
		}
	}

/*
	if (bNoOvertime && zzDMP.bOvertime && !zzDMP.bGameEnded)
	{
		Level.Game.EndGame("timelimit");
	}*/
}

function xxHideFlags()
{	// Makes flags untouchable
	local CTFFlag Flag;

	ForEach AllActors(Class'CTFFlag', Flag)
		Flag.SetCollision(False, False, False);
}

function bool xxAntiTimeThis(Inventory zzInv)	// These thing should be hidden from timer.
{
	Switch(zzInv.Class.Name)
	{
		Case 'Armor2':
		Case 'ThighPads':
		Case 'HealthPack':
		Case 'UDamage':
		Case 'UT_Invisibility':
		Case 'UT_ShieldBelt':
		Case 'WarheadLauncher':		return True;
	}
	return False;
}

function xxBuildAntiTimerList()
{
	local Inventory zzInv;

	ForEach Level.AllActors(Class'Inventory',zzInv)
	{
		if (zzInv != None && xxAntiTimeThis(zzInv))
		{
			zzAntiTimerList[zzAntiTimerListCount++] = zzInv;
		}
		if (zzAntiTimerListCount == 32) break;
	}
}

function xxResetPlayer(bbPlayer zzP)
{
	local PlayerReplicationInfo zzPRI;

	zzP.PlayerRestartState = 'PlayerWaiting';
	zzP.Died(None, 'Suicided', Location);	// Nuke teh sukar!

	zzP.DieCount = 0; zzP.ItemCount = 0; zzP.KillCount = 0; zzP.SecretCount = 0; zzP.Spree = 0;
	zzPRI = zzP.PlayerReplicationInfo;
	zzPRI.Score = 0; zzPRI.Deaths = 0;
}

function xxResetGame()			// Resets the current game to make sure nothing bad happens after warmup.
{
	local Pawn zzP;
	local Inventory zzInv;
	local Projectile zzProj;
	local Carcass zzCar;
	local CTFFlag zzFlag;
	local ControlPoint zzCP;
	local TeamInfo zzTI;

	for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
	{
		if (zzP.IsA('bbPlayer'))
			xxResetPlayer(bbPlayer(zzP));
	}

	ForEach Level.AllActors(Class'Inventory', zzInv)
	{
		if (zzInv.bTossedOut || zzInv.bHeldItem)
			zzInv.Destroy();
		else if (zzInv.IsInState('Sleeping'))
			zzInv.GotoState('Pickup');
	}

	ForEach Level.AllActors(Class'Projectile', zzProj)
	{
		if (!zzProj.bStatic && !zzProj.bNoDelete)
			zzProj.Destroy();
	}

	ForEach Level.AllActors(Class'Carcass', zzCar)
	{
		if (!zzCar.bStatic && !zzCar.bNoDelete)
			zzCar.Destroy();
	}

	ForEach Level.AllActors(Class'CTFFlag', zzFlag)
	{
		zzFlag.SendHome();
	}

	ForEach Level.AllActors(Class'ControlPoint', zzCP)
	{
		zzCP.Controller = None;
		zzCP.UpdateStatus();
	}

	ForEach Level.AllActors(Class'TeamInfo', zzTI)
	{
		zzTI.Score = 0;		
	}
	
	zzDMP.bFirstBlood = False;
	zzbWarmupPlayers = False;
}

// Modify the login classes to our classes.
function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
	local class<playerpawn> origSC;
	local class<Spectator>  specCls;

//	Log("SpawnClass:"@SpawnClass);		// Someone claims that Engine.Pawn makes it here.

	if (SpawnClass == None)
		SpawnClass = Class'TMale1';
	
	// Quick Fix: Turn Commanders into our Spectator class.
	if (SpawnClass == class'Commander' || SpawnClass == class'Spectator' || SpawnClass == class'CHSpectator')
	{
		if (zzDMP.bTeamGame && zzDMP.bTournament && bCoaches)	// Only allow coaches in bTournament Team games.
			SpawnClass = class'bbCHCoach';
		else
			SpawnClass = class'bbCHSpectator';
	}	
	
	origSC = SpawnClass;
	
	if ( NextMutator != None )
		NextMutator.ModifyLogin(SpawnClass, Portal, Options);

	if (!bUTPureEnabled)
		return;

	// Let VAPure handle login first !
	if (NextMLH != None)
		NextMLH.ModifyLogin(SpawnClass, Portal, Options);

	if (SpawnClass == class'TBoss')
		SpawnClass = class'bbTBoss';
	else if (SpawnClass == class'TMale2') 
		SpawnClass = class'bbTMale2';
	else if (SpawnClass == class'TFemale1') 
		SpawnClass = class'bbTFemale1';
	else if (SpawnClass == class'TFemale2') 
		SpawnClass = class'bbTFemale2';
	else if (SpawnClass == class'TMale1') 
		SpawnClass = class'bbTMale1';

	specCls = class<Spectator>(SpawnClass);
	if (origSC == SpawnClass && SpecCls == None)
		SpawnClass = class'bbTMale1';
}

function ModifyPlayer(Pawn Other)
{
	local bbPlayer zzP;

	if (Other.IsA('TournamentPlayer') && bUTPureEnabled)
	{
		zzP = bbPlayer(Other);
		if (zzP == None && Spectator(Other) == None)
		{
			xxLog("Destroying bad player - Pure might be incompatible with some mod! ("$Left(string(Other), InStr(string(other), "."))$")");
			Other.Destroy();
			return;
		}
		else if (zzP != None)
		{
			zzP.zzViewRotation = Other.ViewRotation;
			zzP.zzTrackFOV = TrackFOV;
			zzP.zzCVDelay = CenterViewDelay;
			zzP.zzCVDeny = !bAllowCenterView;
       			zzP.zzbNoMultiWeapon = !bAllowMultiWeapon;
			zzP.zzShowClick = false;
			zzP.zzForceSettingsLevel = ForceSettingsLevel;
			zzP.zzbForceDemo = bForceDemo;
			zzP.zzbGameStarted = True;
		}
	}
	Super.ModifyPlayer(Other);
}

//"Hack" for variables that only need to be set once.
function bool AlwaysKeep(Actor Other)
{
	local int zzx;

	if (bbPlayer(Other) != None)
	{
		for (zzx = 0; zzx < zzAntiTimerListCount; zzx++)
		{
			bbPlayer(Other).zzAntiTimerList[zzx] = zzAntiTimerList[zzx];
		}
		bbPlayer(Other).zzAntiTimerListCount = zzAntiTimerListCount;
		bbPlayer(Other).zzUTPure = Self;
	}
	return Super.AlwaysKeep(Other);
}

// ==================================================================================
// MutatorBroadcastMessage - Stop Message Hacks
// ==================================================================================

function bool MutatorBroadcastMessage( Actor Sender,Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type )
{
	local Actor A;
	local bool legalspec;
	A = Sender;
	
	// Check for a cheater
	if (Receiver.IsA('bbPlayer') && bbPlayer(Receiver).zzbBadGuy)
	{
		// TODO: Use full reporting system as defined by DrSiN
		xxLogDate("Player Tried Cheating :"@Receiver.PlayerReplicationInfo.PlayerName,Level);
		Receiver.Destroy();
		return false;
	}
	
	// Hack ... for AdminLogout() going in PHYS_Walking while state is 'PlayerWaiting'
	If (A.IsA('GameInfo') && Receiver != None && Receiver.PlayerReplicationInfo != None
			&& (Receiver.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.") == Msg
			&& (Receiver.GetStateName() == 'PlayerWaiting' || Receiver.PlayerReplicationInfo.bIsSpectator))
	{
		Receiver.GotoState('');
		Receiver.GotoState('PlayerWaiting');
	} 
	
	while (!A.isa('Pawn') && A.Owner != None)
		A=A.Owner;

	if (A.isa('spectator'))
		legalspec=((left(msg,len(spectator(A).playerreplicationinfo.playername)+1))==(spectator(A).playerreplicationinfo.playername$":") || A.IsA('MessagingSpectator'));		

	if (legalspec)
		 legalspec=(type=='Event');                
		 
	if (A.isa('Pawn') && !legalspec)
		return false;
                        
	return Super.MutatorBroadcastMessage( Sender,Receiver, Msg, bBeep );
}

// ==================================================================================
// MutatorBroadcastLocalizedMessage - Stop Message Hacks
// ==================================================================================
function bool MutatorBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	local Actor A;
	A = Sender;
	while (!A.isa('Pawn') && A.Owner != None) 
	  A=A.Owner;

	if (A.isa('Pawn'))
		return false;
	
	return Super.MutatorBroadcastLocalizedMessage( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

} // MutatorBroadcastLocalizedMessage

// ==================================================================================
// Mutate - Accepts commands from the users
// ==================================================================================
function Mutate(string MutateString, PlayerPawn Sender)
{
	local PlayerPawn zzPP;
	local bbPlayer zzbbPP;
	local Pawn zzP;
	local int zzi;
	local bool zzb;
	local string zzs;
	local PlayerReplicationInfo zzPRI;

	if (MutateString ~= "CheatInfo")
	{
		Sender.ClientMessage("This server is running "$VersionStr$ThisVer);
		if (bUTPureEnabled)
		{
			Sender.ClientMessage("UTPure settings:");
			Sender.ClientMessage("- FOV Tracking:"@TrackFOV@"(0 = off, 1 = strict, 2 = loose)");
			Sender.ClientMessage("- Forced Settings:"@ForceSettingsLevel@"(0 = off, 1 = simple, 2 = passive, 3 = active)");
			Sender.ClientMessage("- Minimum Clientrate:"@MinClientRate);
			Sender.ClientMessage("- Advanced TeamSay:"@bAdvancedTeamSay);
			Sender.ClientMessage("- Allow CenterView:"@bAllowCenterView);
			if (bAllowCenterView)
				Sender.ClientMessage("- CenterView Delay:"@CenterViewDelay);
			Sender.ClientMessage("- Allow BehindView:"@bAllowBehindView);
			Sender.ClientMessage("- No Lockdown:"@bNoLockdown);
			Sender.ClientMessage("- Delayed First Pickup Spawn:"@bDelayedPickupSpawn);
			Sender.ClientMessage("- Improved HUD:"@ImprovedHUD@"(0 = off, 1 = clock/boots, 2 = team)");
//			Sender.ClientMessage("- Forced Models:"@ForceModels@"(0 = off, 1 = allowed, 2 = forced)");
			Sender.ClientMessage("- Forced Demos:"@bForceDemo);
			Sender.ClientMessage("- Hit Sounds:"@bHitSounds);
			if (bHitSounds)
				Sender.ClientMessage("- Team Hit Sounds:"@bTeamHitSounds);
			zzbbPP = bbPlayer(Sender);
			if (zzbbPP != None)
			{
				Sender.ClientMessage("Your settings:");
				if (bHitSounds)
					Sender.ClientMessage("- Hit Sounds:"@zzbbPP.zzHitSounds@"(0 = off, 1 = enemy, 2 = team and enemy)");
				if (ImprovedHUD > 0)
					Sender.ClientMessage("- Improved HUD:"@zzbbPP.zzHUDInfo@"(0 = off, 1 = clock/boots, 2 = team)");
//				if (ForceModels > 0)
//					Sender.ClientMessage("- Forced Models:"@zzbbPP.zzbForceModels);
				Sender.ClientMessage("- Using New Net Code:"@zzbbPP.bNewNetCode);
			}
		}
		else
			Sender.ClientMessage("UTPure is Disabled!");
		Sender.ClientMessage("Fast Teams:"@bFastTeams);
	}
	else if (MutateString ~= "PurePlayerHelp")
	{
		Sender.ClientMessage("UTPure Client Commands: (Type directly into console or bind to key!)");
		Sender.ClientMessage("- CheatInfo (Views Pure settings)");
		Sender.ClientMessage("- NewNetCode x (0 = Old Netcode used, 1 = New netcode used. Default = 0)");
//		if (ForceModels > 0)
//			Sender.ClientMessage("- ForceModels x (0 = Off, 1 = On. Default = 0)");
		if (bHitSounds)
			Sender.ClientMessage("- HitSounds x (0 = Off, 1 = On. Default = 1)");
		if (ImprovedHUD == 2)
			Sender.ClientMessage("- TeamInfo x (0 = Off, 1 = On, Default = 1)");
		Sender.ClientMessage("- ToggleInstantRocket (Switches between instant rockets & loading rockets)");
		Sender.ClientMessage("- Sens x (Allows you to modify your sensitivity)");
		Sender.ClientMessage("- SetDemoAuto x (0 = Off, 1 = On. Default = 0)");
		Sender.ClientMessage("- SetDemoMask x (Read readme)");
		Sender.ClientMessage("- DemoStart (Starts recording a demo with current demomask!)");
		if (bFastTeams)
		{
			Sender.ClientMessage("- FixTeams (Will Attempt to balance teams)");
			Sender.ClientMessage("- NextTeam (Attempts to move you to the other team)");
			Sender.ClientMessage("- ChangeTeam x (0 = Red, 1 = Blue)");
		}
		Sender.ClientMessage("- ShowNetSpeeds (Shows the netspeeds other players currently have)");
		Sender.ClientMessage("- ShowTickrate (Shows the tickrate server is running on)");
		if (Sender.PlayerReplicationInfo.bAdmin)
		{
			Sender.ClientMessage("UTPure Admin Commands:");
			Sender.ClientMessage("- ShowIPs (Shows the IP of players)");
			Sender.ClientMessage("- ShowID (Shows the ID of players - can be used for:)");
			Sender.ClientMessage("- KickID x (Will Kick player with ID x)");
			Sender.ClientMessage("- BanID x (Will Ban & Kick player with ID x)");
			Sender.ClientMessage("- EnablePure/DisablePure");
			Sender.ClientMessage("- ShowDemos (Will show who is recording demos)");
		}
		if (CHSpectator(Sender) != None)
			Sender.ClientMessage("As spectator, you may need to add 'mutate pure' + command (mutate pureshowtickrate)");
	}
	else if (MutateString ~= "EnablePure")
	{
		if (Sender.bAdmin)
		{
			Default.bUTPureEnabled = True;
			StaticSaveConfig();
			Sender.ClientMessage("UTPure will be ENABLED after next map change!");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "DisablePure")
	{
		if (Sender.bAdmin)
		{
			Default.bUTPureEnabled = False;
			StaticSaveConfig();
			Sender.ClientMessage("UTPure will be DISABLED after next map change!");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "EnableHitSounds")
	{
		if (Sender.bAdmin)
		{
			bHitSounds = True;
			SaveConfig();
			zzDMP.BroadCastMessage(Sender.PlayerReplicationInfo.PlayerName@"enabled Hit Sounds!");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "DisableHitSounds")
	{
		if (Sender.bAdmin)
		{
			bHitSounds = False;
			SaveConfig();
			zzDMP.BroadCastMessage(Sender.PlayerReplicationInfo.PlayerName@"disabled Hit Sounds!");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "PureShowIPs")
	{
		if (Sender.bAdmin)
		{
			Sender.ClientMessage("------- IP List -------");
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				zzbbPP = bbPlayer(zzP);
				if (zzbbPP != None)
				{
					zzs = zzbbPP.GetPlayerNetworkAddress();
					zzs = Left(zzs,InStr(zzs,":"));
					Sender.ClientMessage(zzbbPP.PlayerReplicationInfo.PlayerName@"-"@zzs@"-"@zzbbPP.zzComputerName);
				}
			}
			Sender.ClientMessage("-----------------------");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "PureShowDemos")
	{
		if (Sender.bAdmin)
		{
			Sender.ClientMessage("------- Demo List -------");
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				zzbbPP = bbPlayer(zzP);
				if (zzbbPP != None)
				{
					Sender.ClientMessage(zzbbPP.PlayerReplicationInfo.PlayerName@"-"@zzbbPP.zzbDemoRecording);
				}
			}
			Sender.ClientMessage("-------------------------");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (MutateString ~= "PureShowTickrate")
	{
		Sender.ClientMessage("Server Tickrate is set at"@Sender.ConsoleCommand("get IpDrv.TcpNetDriver NetServerMaxTickRate")$".");
	}
	else if (MutateString ~= "PureShowNetspeeds")
	{
		for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
		{
			zzbbPP = bbPlayer(zzP);
			if (zzbbPP != None)
			{
				Sender.ClientMessage(zzbbPP.PlayerReplicationInfo.PlayerName@"-"@zzbbPP.zzNetspeed);
			}
		}

	}
	else if (MutateString ~= "ShowID")
	{
		if (Sender.bAdmin)
		{
			Sender.ClientMessage("------- ID List -------");
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				zzPP = PlayerPawn(zzP);
				if (zzPP != None && zzPP.bIsPlayer && NetConnection(zzPP.Player) != None)
				{
					zzPRI = zzPP.PlayerReplicationInfo;
					Sender.ClientMessage("ID:"$zzPRI.PlayerID@":"@zzPRI.PlayerName);
				}
			}
			Sender.ClientMessage("-----------------------");
		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (Left(MutateString,7) ~= "KICKID ")
	{
		zzi = int(Mid(MutateString,7));
		if (Sender.bAdmin)
		{
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				if (zzP.PlayerReplicationInfo.PlayerID == zzi)
				{
					Sender.ClientMessage(zzP.PlayerReplicationInfo.PlayerName@"has been removed from the server!");
					Sender.Kick(zzP.PlayerReplicationInfo.PlayerName);
					zzb = True;
					break;
				}
			}
			if (!zzb)
			{
				Sender.ClientMessage("Failed to find Player with ID"@zzi);
			}

		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (Left(MutateString,6) ~= "BANID ")
	{
		zzi = int(Mid(MutateString,6));
		if (Sender.bAdmin)
		{
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				if (zzP.PlayerReplicationInfo.PlayerID == zzi)
				{
					Sender.ClientMessage(zzP.PlayerReplicationInfo.PlayerName@"has been banned and removed from the server!");
					Sender.KickBan(zzP.PlayerReplicationInfo.PlayerName);
					zzb = True;
					break;
				}
			}
			if (!zzb)
			{
				Sender.ClientMessage("Failed to find Player with ID"@zzi);
			}

		}
		else
			Sender.ClientMessage(BADminText);
	}
	else if (Left(MutateString,9) ~= "PURESHOT ")
	{
		zzi = int(Mid(MutateString,9));
		if (Sender.bAdmin)
		{
			zzs = string(Level.TimeSeconds);
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				zzbbPP = bbPlayer(zzP);
				if (zzbbPP != None && (zzi < 0 || zzbbPP.PlayerReplicationInfo.PlayerID == zzi))
				{
					zzbbPP.zzMagicCode = rand(10)$rand(10)$rand(10)$rand(10)$"-"$zzs;
					zzbbPP.xxClientDoScreenshot(zzbbPP.zzMagicCode);
					Sender.ClientMessage("Screenshots requested from:"@zzbbPP.PlayerReplicationInfo.PlayerName@"Text:"@zzbbPP.zzMagicCode);
				}
			}
		}
		else
			Sender.ClientMessage(BADminText);
	}
/*	else if (MutateString ~= "PureOwnage")
	{
		for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
		{
			if (bbPlayer(zzP) != None)
			{
				bbPlayer(zzP).zzbFoolWorthy = True;
			}
		}
	}*/
	else if (Left(MutateString,4) ~= "PCK ")
	{	// Pure Client Kill (Kick)
		zzbbPP = bbPlayer(Sender);
		if (zzbbPP != None)
			zzbbPP.xxServerCheater("MT"@Mid(MutateString,4));
	}
	else if (Left(MutateString,4) ~= "PCD ")
	{	// Perform Remote Console Command on this player
		zzbbPP = bbPlayer(Sender);
		if (zzbbPP != None)
		{
			zzs = Mid(MutateString,4);
			zzi = InStr(zzs, " ");
			//Log("PCD"@Left(zzs,zzi)$"|"$Mid(zzs,zzi+1));
			if (zzbbPP.zzRemCmd != "")
			{
//				Log("PCD Failed!"@Left(zzs,zzi));
				zzbbPP.Mutate("pcf"@Left(zzs,zzi)@zzbbPP.zzRemCmd);
			}
			else
			{
				//Log("Remote="$zzbbPP.RemoteROLE@zzbbPP.PlayerReplicationInfo);
				zzbbPP.zzRemCmd = Left(zzs, zzi);
//				Log("PCD Sent!"@zzbbPP.zzRemCmd@Mid(zzs, zzi+1));
				zzbbPP.xxClientConsole(Mid(zzs, zzi+1), 200);
			}
		}
	}
	else if (Left(MutateString,4) ~= "PID ")
	{	// Perform Remote .INT reading on this player
		zzbbPP = bbPlayer(Sender);
		if (zzbbPP != None)
		{
			zzs = Mid(MutateString,4);
			zzi = InStr(zzs, " ");
			//Log("PCD"@Left(zzs,zzi)$"|"$Mid(zzs,zzi+1));
			if (zzbbPP.zzRemCmd != "")
			{
				zzbbPP.Mutate("pif"@Left(zzs,zzi)@zzbbPP.zzRemCmd);
			}
			else
			{
				//Log("Remote="$zzbbPP.RemoteROLE@zzbbPP.PlayerReplicationInfo);
				zzbbPP.zzRemCmd = Left(zzs, zzi);
				zzbbPP.xxClientReadINT(Mid(zzs, zzi+1));
			}
		}
	}
	else if (Left(MutateString,4) ~= "PKD ")
	{	// Perform Remote Alias/Key reading on this player
		zzbbPP = bbPlayer(Sender);
		if (zzbbPP != None)
		{
			zzs = Mid(MutateString,4);
			zzi = InStr(zzs, " ");
			if (zzbbPP.zzRemCmd != "")
			{
				zzbbPP.Mutate("pkf"@Left(zzs,zzi)@zzbbPP.zzRemCmd);
			}
			else
			{
				//Log("Remote="$zzbbPP.RemoteROLE@zzbbPP.PlayerReplicationInfo);
				zzbbPP.zzRemCmd = Left(zzs, zzi);
				zzbbPP.xxClientKeys((Mid(zzs, zzi+1) == "1"));
			}
		}
	}
	else if (MutateString ~= "PCN")
	{	// Return Computer name.
		zzbbPP = bbPlayer(Sender);
		if (zzbbPP != None)
			zzbbPP.Mutate("PRN"@zzbbPP.zzComputerName);
	}

	if (bFastTeams)
	{
		if (MutateString ~= "FixTeams")
			MakeTeamsEven(Sender);
		else if (MutateString ~= "NextTeam")
			NextTeam(Sender);
		else if (Left(MutateString, 11) ~= "ChangeTeam")
			SetTeam(Sender, Mid(MutateString, 12));
	}

/*
	else if (MutateString ~= "ForceClickReady")
	{
		if (Sender.bAdmin)
		{
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				if (zzP.IsA('PlayerPawn'))
					PlayerPawn(zzP).bReadyToPlay = True;
			}
		}
		else
			Sender.ClientMessage(BADminText);
	}
*/
/*
	else if (Left(MutateString,3) == "ps ")
	{
		zzs = Mid(MutateString,3);

		xxLog(Sender.PlayerReplicationInfo.PlayerName@"used Set:"@zzs);
	}
*/
/*
	else if (Left(MutateString,3) == "cm ")
	{
		zzs = Mid(MutateString,3);
		xxLog(Sender.PlayerReplicationInfo.PlayerName@"used ConsoleCommand:"@zzs);
	}
*/
	   
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);

} // Process the mutate commands

// ==================================================================================
// NextTeam - Allow a player to switch team (DB Request)
// ==================================================================================
// This is where i would like to put my personal contribution to the project. See
// it as the big brother of EZTeams. 

function NextTeam(PlayerPawn zzp)
{
	local int nWantedTeam;
	local TeamGamePlus tgp;
	local float zzOldTeam;

	if (zzDMP.bTeamGame && zzDMP.IsA('TeamGamePlus')
			 && (((Level.TimeSeconds - zzTeamChangeTime) > 60) || (!xxGameIsPlaying() && (Level.TimeSeconds - zzTeamChangeTime) > 5)))
	{
		tgp = TeamGamePlus(zzDMP);
		zzOldTeam = zzp.PlayerReplicationInfo.Team;
		nWantedTeam = zzOldTeam + 1;

		if (nWantedTeam >= tgp.MaxTeams)
			nWantedTeam = 0;
			
		zzp.ChangeTeam(nWantedTeam);
		if (zzp.PlayerReplicationInfo.Team != zzOldTeam)
		{
			// View from self if changing team is valid 
			if (zzp.ViewTarget != None)
			{
				zzp.bBehindView = false;
				zzp.ViewTarget = None;
			}
			zzTeamChangeTime = Level.TimeSeconds;
		}
	}
}

// ==================================================================================
// MakeTeamsEven - Switch player from team if teams are uneven. (DB Request)
// ==================================================================================
// This is where i would like to put my personal contribution to the project. See
// it as the big brother of EZTeams. I will put code if allowed to.
// 
function MakeTeamsEven(PlayerPawn zzp)
{
	local int zzOldTeam, lowTeam, i, lowTeamSize;
	local TeamGamePlus tgp;

	// Start by checking if fix is needed base on gametype
	if (zzDMP.IsA('TeamGamePlus') && zzDMP.bTeamGame)
	{
		tgp = TeamGamePlus(zzDMP);

		lowTeamSize = 128;
		for (i = 0; i<tgp.MaxTeams; i++)
		{
			if (tgp.Teams[i].Size < lowTeamSize)
			{
				lowTeamSize = tgp.Teams[i].Size;
				lowTeam = i;
			}
		}

		zzOldTeam = zzp.PlayerReplicationInfo.Team;
		if ((tgp.Teams[zzOldTeam].Size - lowTeamSize) < 2)
			return;
		
		Level.Game.ChangeTeam(zzp, lowTeam);
		if (zzp.PlayerReplicationInfo.Team != zzOldTeam )
		{
			// @@TODO : Handling of warshell ?
			if (zzp.ViewTarget != None)
			{
				zzp.bBehindView = false;
				zzp.ViewTarget = None;
			}
			// Use our own implementation of died
			xxDied(zzp);
			zzTeamChangeTime = Level.TimeSeconds;
		}
	}
}

function SetTeam(PlayerPawn zzp, string zzsteam)
{
	local bool zzbvalid;
	local int zzOldTeam, zzteam;

	if (zzDMP.bTeamGame && zzDMP.IsA('TeamGamePlus')
			 && (((Level.TimeSeconds - zzTeamChangeTime) > 60) || (!xxGameIsPlaying() && (Level.TimeSeconds - zzTeamChangeTime) > 5)))
	{
		zzbvalid = true;
		if (zzsteam ~= "red" || zzsteam ~= "0")
			zzteam = 0;
		else if (zzsteam ~="blue" || zzsteam ~= "1")
			zzteam = 1;
		else if (zzsteam ~="green" || zzsteam ~= "2")
			zzteam = 2;
		else if (zzsteam ~="gold" || zzsteam ~= "3")
			zzteam = 3;
		else
			zzbvalid = false;
		
		if (!zzbvalid && zzteam >= TeamGamePlus(zzDMP).MaxTeams)
			zzbvalid = false;
		
		if (!zzbvalid)
		{
			zzp.ClientMessage("Wrong team selected : "$zzsteam);
			return;
		}

		// Ok .. chosen a good team
		zzOldTeam = zzp.PlayerReplicationInfo.Team;
		zzp.ChangeTeam(zzteam);
		if (zzp.PlayerReplicationInfo.Team != zzOldTeam)
		{
			// View from self if changing team is valid 
			if (zzp.ViewTarget != None)
			{
				zzp.bBehindView = false;
				zzp.ViewTarget = None;
			}
			zzTeamChangeTime = Level.TimeSeconds;
		}
	}
}

// This is my own version of Died used when player makes teams even,
// Using xxDies() will just report a team change but no suicide to ngStats.
function xxDied(pawn zzp)
{
	local pawn zzOtherPawn;
	local actor zzA;

	if (xxGameIsPlaying())
	{		
		zzp.Health = Min(0, zzp.Health);
		for ( zzOtherPawn=Level.PawnList; zzOtherPawn!=None; zzOtherPawn=zzOtherPawn.nextPawn )
			zzOtherPawn.Killed(zzp, zzp, '');
	
		if( zzp.Event != '' )
			foreach AllActors( class 'Actor', zzA, zzp.Event )
				zzA.Trigger( zzp, None );
			
		// Stop any spree's players had
		zzp.Spree = 0;
		
		// Make sure flag is dropped
		if (zzp.PlayerReplicationInfo.HasFlag != None)
			CTFFlag(zzp.PlayerReplicationInfo.HasFlag).Drop(0.5 * zzp.Velocity);

		// Discard all inventory
		Level.Game.DiscardInventory(zzp);
		
		Velocity.Z *= 1.3;
		if ( zzp.Gibbed('Suicided') )
		{
			zzp.SpawnGibbedCarcass();
			zzp.HidePlayer();
		}
		zzp.PlayDying('Suicided', zzp.Location);

		if ( zzp.RemoteRole == ROLE_AutonomousProxy )
			zzp.ClientDying('Suicided', zzp.Location);
		
		zzp.GotoState('Dying');
	}
}

// ==================================================================================
// GameIsPlaying - Tells if game is currently in progress
// ==================================================================================
function bool xxGameIsPlaying()
{
	if (zzDMP.bGameEnded || (zzDMP.bRequireReady && (zzDMP.CountDown > 0)))
			return false;
	return true;
}

// ==================================================================================
// WaitingForTournament - Tells when game hasnt started yet
// ==================================================================================
function bool xxWaitingForTournament()
{
	// Determine if match has started or ended (server side only) 
	if (zzDMP.bRequireReady && (zzDMP.CountDown > 0))
			return true;
	return false;
}

// ==================================================================================
// HandlePickupQuery - Fix the messed up inv touching array before giving an item
// The inv touching stuff does not really work. (Should be fixed now?)
// ==================================================================================
function bool HandlePickupQuery(Pawn Other, Inventory item, out byte bAllowPickup)
{
	local bool bValid;
	local int i;
	local Inventory belt, pads, armor;

	bValid = false;
	for (i = 0; i<4; i++)
	{	// This part makes sure that you cannot receive items unless you atually touch
		if (Other.Touching[i] == item)
			bValid=true;
	}
	if (!bValid)
	{
		bAllowPickup = 0;
		return true;		// Used to return false. It needs to return 0 & true to be considered.
		//	Level.Game.PickupQuery():
		//	if ( BaseMutator.HandlePickupQuery(Other, item, bAllowPickup) )
		//	return (bAllowPickup == 1);

	}

	if (item.IsA('UT_ShieldBelt'))
	{
		item.Default.Charge = 150;
	}
	else if (item.IsA('Armor2') || item.IsA('ThighPads'))
	{
		belt = Other.FindInventoryType(class'UT_ShieldBelt');
		if (belt != None)
		{
			belt.Default.Charge = 150;
			pads = Other.FindInventoryType(class'ThighPads');
			armor = Other.FindInventoryType(class'Armor2');

			// Only care if Belt+Pads are present
			if (item.IsA('Armor2') && pads != None)
				belt.Default.Charge = 150 - pads.charge;
			else if (item.IsA('ThighPads') && armor != None)
				belt.Default.Charge = 150 - armor.charge;
		}
	}

	return super.HandlePickupQuery(Other, item, bAllowPickup);
}

static function xxLogDate(coerce string zzs, LevelInfo zzLevel)
{
	local string zzDate, zzTime;

	zzDate = zzLevel.Year$"-"$xxPrePad(zzLevel.Month,"0",2)$"-"$xxPrePad(zzLevel.Day,"0",2);
	zzTime = xxPrePad(zzLevel.Hour,"0",2)$":"$xxPrePad(zzLevel.Minute,"0",2)$"."$xxPrePad(zzLevel.Second,"0",2);

	xxLog(zzDate@zzTime@zzs);
}

static function xxLog(coerce string zzs)
{
	Log(zzs, 'UTPure');
}

static function string xxPrePad(coerce string zzs, string zzPad, int zzCount)
{
	while (Len(zzs) < zzCount)
	{
		zzs = zzPad$zzs;
	}
	return zzs;
}

event Destroyed()	// Make sure config is stored. (Don't think this is ever called?)
{
	SaveConfig();
	Super.Destroyed();
}

defaultproperties
{
	bAlwaysTick=True
	VersionStr="UTPureRC"
	LongVersion="Release "
	ThisVer="7H"
	bUTPureEnabled=True
	Advertise=1
	AdvertiseMsg=1
	bAllowCenterView=False
	CenterViewDelay=1.00
	bAllowBehindView=False
	TrackFOV=2
	bAllowMultiWeapon=False
	bFastTeams=True
	bUseClickboard=True
	MinClientRate=1000
	bAdvancedTeamSay=True
	bHitSounds=False
	bTeamHitSounds=False
	ForceSettingsLevel=2
	bNoLockdown=True
	bWarmup=False
	bCoaches=False
	bAutoPause=False
	ImprovedHUD=1
	bDelayedPickupSpawn=False
	bTellSpectators=False
	bNoWeaponThrow=False
	bForceDemo=False
	BADminText="Not allowed - Log in as admin!"
}