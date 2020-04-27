//================================================================================
// zp_RingExplosion.
//================================================================================
class zp_RingExplosion expands UT_RingExplosion5;

simulated function PostBeginPlay ()
{
	if ( Level.NetMode != 1 )
	{
		PlayAnim('Explo',0.35,0.00);
	}
	if ( Instigator != None )
	{
		MakeNoise(0.50);
	}
}

simulated function SpawnEffects ()
{
	local zp_ShockExplo E;

	if ( Instigator == None )
	{
		E=Spawn(Class'zp_ShockExplo',Owner);
	}
}

simulated function SpawnExtraEffects ()
{
/*	if (! Level.NetMode != 1 ) goto JL0017;
JL0017: */
	if ( (Owner == None) || (Owner.Role != 3) )
	{
		SpawnEffects();
		Super.SpawnExtraEffects();
	}
}

defaultproperties
{
    bOwnerNoSee=True
}
