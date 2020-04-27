// ===============================================================
// PurePkgChk.PPC_Mutator: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PPL_Mutator extends Mutator;

var string Ident;

function PPL_PInfo FindPI(PlayerPawn P)
{	// Finds or creates the info associated to this player
	local PPL_PInfo Result;

	// Try to find existing:
	ForEach AllActors(Class'PPL_PInfo', Result)
		if (Result.Owner == P)
			return Result;

	// None found, so create:
	Result = Spawn(Class'PPL_PInfo', P);
	Result.Mut = Self;
	return Result;
}

function ModifyPlayer(Pawn Other)
{
	local PlayerPawn P;
	local PPL_PInfo PI;
	
	P = PlayerPawn(Other);
	if (P != None)
	{
		PI = FindPI(P);
		if (!PI.bRunning)
			PI.Start();
	}
		
	Super.ModifyPlayer(Other);
}

function Tick(float deltaTime)
{
	if (Level.Game.bGameEnded)
		DoEndStuff();
}

function DoEndStuff()
{	// Do an additional request for packages now!
	local PPL_PInfo PI;

	ForEach AllActors(Class'PPL_PInfo', PI)
		PI.Start();
	Disable('Tick');
}

function Mutate(string MutateString, PlayerPawn Sender)
{	// Wait for Pure replies here.
	local string s;
	local int i;
	local PPL_PInfo PI;

	if (Left(MutateString,4) ~= "PCR ")
	{
		if (Sender != None)
		{
			s = Mid(MutateString,4);
			i = InStr(s, " ");
			if (Left(s, i) ~= Ident)
			{
				PackageLog(Sender, Mid(s, i+1));
				PI = FindPI(Sender);
				PI.Done();
			}
		}
	}
	else if (Left(MutateString,4) ~= "PCF ")
	{
		if (Sender != None)
		{
			s = Mid(MutateString,4);
			i = InStr(s, " ");
			if (Left(s, i) ~= Ident)
			{
				PI = FindPI(Sender);
				PI.Busy();
			}
		}
	}

	Super.Mutate(MutateString, Sender);
}

function PackageLog(PlayerPawn P, string PL)
{	// Logs all the packages to file if found.
	local int i, i2, c;
	local string s, Logged, qs;

	qs = "PackID"$P.PlayerReplicationInfo.PlayerID$":";
	MyLog(qs@"********************************************************************");

	while (True)
	{
		i = InStr(PL, "(Package ");
		if (i < 0)				// No more packages, so abort
			break;
		i += 9;
		i2 = InStr(PL, "): ");

		s = Mid(PL, i, i2 - i);
		PL = Mid(PL, i2+3);
		c++;					// One more package found

		if ((Len(Logged) + Len(s)) > 70)	// If this package would make log overflow, don't add yet.
		{
			MyLog(qs@Logged);
			Logged = "";			// Flush out found packages
		}
		Logged = Logged$s$",";			// Add package to list
	}

	// Log remaining if any.
	i = Len(Logged) - 1;
	if (i > 0)
	{
		Logged = Left(Logged, i);
		MyLog(qs@Logged);
	}
	s = P.GetPlayerNetworkAddress();
	s = Left(s,InStr(s,":"));			// Remove the :port part of the ip
	LogDate(qs);
	MyLog(qs@P.PlayerReplicationInfo.PlayerName@s@"Package Count:"@c);
	MyLog(qs@"********************************************************************");
}

function MyLog(coerce string s)
{	// Simply logs to log
	Log(s, 'PPL');
}

function LogDate(coerce string s)
{	// Simply logs to log with date.
	local string Date, Time;

	Date = Level.Year$"-"$PrePad(Level.Month,"0",2)$"-"$PrePad(Level.Day,"0",2);
	Time = PrePad(Level.Hour,"0",2)$":"$PrePad(Level.Minute,"0",2)$"."$PrePad(Level.Second,"0",2);

	MyLog(s@Date@Time);
}

function string PrePad(coerce string s, string Pad, int Count)
{	// Pads a string in front with selected string.
	while (Len(s) < Count)
	{
		s = Pad$s;
	}
	return s;
}


defaultproperties {
	Ident="LINKERS"
}
