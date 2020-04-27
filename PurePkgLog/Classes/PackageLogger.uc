// ===============================================================
// PurePkgChk.PPC_Info: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PackageLogger extends Info;

function PostBeginPlay()
{
	local PPL_Mutator Mut;

	// Make sure it wasn't added as a mutator
	foreach AllActors(class'PPL_Mutator',Mut)
		return;

	Mut = Level.Spawn(Class'PPL_Mutator');
	if (Mut != None)
	{
		Mut.NextMutator = Level.Game.BaseMutator;
		Level.Game.BaseMutator = Mut;
	}
	Destroy();
}


defaultproperties {
}
