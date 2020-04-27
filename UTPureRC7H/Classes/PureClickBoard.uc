// ====================================================================
//  Class:  UTPureRC4d.PureClickBoard
//  Parent: Engine.Mutator
//
//  <Enter a description here>
// ====================================================================

class PureClickBoard extends Mutator;

var PureFlag		zzFakeFlag;

function bool AlwaysKeep(Actor Other)
{
	if (Other.IsA('PureFlag'))
		return true;

	return Super.AlwaysKeep(Other);
}

event PreBeginPlay()
{
local class<scoreboard>		  ScoreBoardType;

	Super.PreBeginPlay();
	
	if (Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).bTournament)
	{
		// First, make sure the player uses a ScoreBoard that can show clicked status
		if (Level.Game.ScoreBoardType == class'Botpack.TournamentScoreBoard')
			ScoreBoardType = Class'PureScoreBoard';   
		else if (Level.Game.ScoreBoardType == Class'Botpack.TeamScoreBoard')
			ScoreBoardType = Class'PureTeamScoreBoard';
		else if (Level.Game.ScoreBoardType == Class'Botpack.AssaultScoreboard')
			ScoreBoardType = Class'PureAssaultScoreBoard';
		else if (Level.Game.ScoreBoardType == Class'Botpack.UnrealCTFScoreboard')
			ScoreBoardType = Class'PureCTFScoreBoard';
		else if (Level.Game.ScoreBoardType == Class'Botpack.DominationScoreboard')
			ScoreBoardType = Class'PureDOMScoreBoard';

		if (ScoreBoardType != None)
		{
			Level.Game.ScoreBoardType = ScoreBoardType;
			// Also create a fake flag to transmit clicked status
			CreateFakeFlag();
			if (zzFakeFlag != None)
			{
				Log("PureClickBoard Set", 'UTPure');
				zzFakeFlag.bHidden = true;		// See if it prevents it from replicating
				zzFakeFlag.SetTimer(0.0, false);	// Make sure it doesnt try to Send Home
				// Start a timer to check for Clicked status
				SetTimer(1.0, true);
			}
			else
				Log("Failed to Initialize PureClick Environment", 'UTPure');
		}
	}
}

function CreateFakeFlag()
{
local NavigationPoint zznav;
local Actor zza;

	// First, go thru all Navigation Points to find a valid spot
	for (zzNav = Level.NavigationPointList; zzNav != None; zzNav = zzNav.nextNavigationPoint)
	{
		zzFakeFlag = Spawn(class'PureFlag', None,,zzNav.Location);
		if (zzFakeFlag != None)
			return;
	}
	
	// Still havent found one ? .. Try AllActors
	foreach AllActors(class'Actor', zza)
	{
		zzFakeFlag = Spawn(class'PureFlag', None,, zza.Location);
		if (zzFakeFlag != None)
			return;
	}
	// Oh Well, forget it, we wont make it.
}

event Timer()
{
local Pawn zzP;
local DeathMatchPlus zzDMP;

	// If Game has started, cleanup all the flags assigned
	zzDMP = DeathMatchPlus(Level.Game);
	
	if (zzDMP.CountDown > 0)
	{
		if (zzFakeFlag == None)
			zzFakeFlag = spawn(class'PureFlag');
			
		if (zzFakeFlag == None)
			Log("Failed once more in Timer");
		else
		{
			// Check all player for their clicked status
			for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			{
				if (zzP.IsA('PlayerPawn') && !zzP.IsA('Spectator') && zzP.PlayerReplicationInfo != None)
				{
					if (PlayerPawn(zzP).bReadyToPlay && zzP.PlayerReplicationInfo.HasFlag == None)
						zzP.PlayerReplicationInfo.HasFlag = zzFakeFlag;
					else if (!PlayerPawn(zzP).bReadyToPlay && zzP.PlayerReplicationInfo.HasFlag == zzFakeFlag)
						zzP.PlayerReplicationInfo.HasFlag = None;
				}
			}
		}
	}
}

event Tick(Float delta)
{
local Pawn zzP;
local DeathMatchPlus zzDMP;

	// If Game has started, cleanup all the flags assigned
	zzDMP = DeathMatchPlus(Level.Game);
	
	if (zzDMP != None && zzDMP.CountDown <= 0)
	{
		for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
			if (zzP.PlayerReplicationInfo.HasFlag == zzFakeFlag)
				zzP.PlayerReplicationInfo.HasFlag = None;
		
		if (zzFakeFlag != None)
			zzFakeFlag.Destroy();
			
		zzFakeFlag = None;
		SetTimer(0.0, false);
		Disable('Tick');
	}
}

defaultproperties
{
}
