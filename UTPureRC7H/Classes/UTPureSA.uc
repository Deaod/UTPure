// ====================================================================
//  Class:  UTPure.UTPureSA
//  Parent: Engine.Info
//
//  <Enter a description here>
// ====================================================================

// Additions by TNSe:
//
// RC5b:
// Added: PostBeginPlay(): Added a check in UTPure defaults to see if the server admin wants clickboards.

class UTPureSA extends Info;

function PostBeginPlay()
{
	local UTPure UTP;

	super.PostBeginPlay();

	// Make sure it wasn't added as a mutator
	foreach AllActors(class'UTPure',UTP)
		return;

	UTP = Level.Spawn(Class'UTPure');
	if (UTP != None)
	{
		UTP.NextMutator = Level.Game.BaseMutator;
		Level.Game.BaseMutator = UTP;
	}
	// Fix the MaxTimeMargin for Epic
	
	class'playerpawn'.default.maxtimemargin = 1;
	class'playerpawn'.staticsaveconfig();	
		
	Destroy();
}

defaultproperties
{

}
