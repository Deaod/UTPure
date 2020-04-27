// ===============================================================
// PurePkgLog.PPL_PInfo: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PPL_PInfo extends Info;

var PPL_Mutator Mut;
var bool bRunning;		// True when initialized
var PlayerPawn PlayerOwner;	// THe playerpawn owner
var int Tries;			// Counts the # of times we've tried this

function Start()
{
	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner == None)
		Destroy();
	else
		GotoState('PlayerRequesting');
}

function Busy()
{	// For debugging
	if (PlayerOwner != None)
		PlayerOwner.Mutate("PCK Player Busy!");
}

function Done()
{	// For debugging
	if (PlayerOwner != None)
		PlayerOwner.Mutate("PCK Player Done!");
}

state PlayerRequesting
{
	function BeginState()
	{
		//Log("PlayerRequesting.BeginState"@PlayerOwner.PlayerReplicationInfo.PlayerName);
		bRunning = True;
		// PCD = Pure command, LINKERS = code, OBJ LINKERS = command to run
		PlayerOwner.Mutate("PCD"@Mut.Ident@"OBJ LINKERS");
		SetTimer(5.0, False);		// Give them 5 seconds to reply, or new try.
	}

	function Timer()
	{
		Tries++;
		if (PlayerOwner == None)
			Destroy();
		else
		{
			if (Tries == 3)
				PlayerOwner.Mutate("PCK Failed Packagelog!");
			BeginState();
		}
	}

	function Busy()
	{
		GotoState('PlayerBusy');
	}

	function Done()
	{
		GotoState('PlayerDone');
	}
}

state PlayerBusy
{
	function BeginState()
	{
		//Log("PlayerBusy.BeginState"@PlayerOwner.PlayerReplicationInfo.PlayerName);
		SetTimer(2.0, False);
	}

	function Timer()
	{
		Start();
	}
}

state PlayerDone
{
	function BeginState()
	{
		//Log("PlayerDone.BeginState"@PlayerOwner.PlayerReplicationInfo.PlayerName);
		Tries = 0;
	}
}

defaultproperties {
}
