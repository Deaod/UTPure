// ===============================================================
// Stats.ST_enforcer: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_enforcer extends enforcer;

var ST_Mutator STM;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'ST_Mutator', STM)
		break;		// Find master :D
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local vector realLoc;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	STM.PlayerFire(PawnOwner, 3);			// 3 = Enforcer
	if (SlaveEnforcer != None)
		STM.PlayerSpecial(PawnOwner, 3);	// 3 = Enforcer, Slave enforcer is special.

	realLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'UT_ShellCase',, '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
	if (Other == Level) 
	{
		if ( bIsSlave || (SlaveEnforcer != None) )
			Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		else
			Spawn(class'UT_WallHit',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ((Other != self) && (Other != Owner) && (Other != None) ) 
	{
		if ( FRand() < 0.2 )
			X *= 5;
		STM.PlayerHit(PawnOwner, 3, False);	// 3 = Enforcer
		Other.TakeDamage(HitDamage, PawnOwner, HitLocation, 3000.0*X, MyDamageType);
		STM.PlayerClear();
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
	}		
}

function SetSwitchPriority(pawn Other)
{	// Make sure "old" priorities are kept.
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		// also set double switch priority

		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( PlayerPawn(Other).WeaponPriority[i] == 'doubleenforcer' )
			{
				DoubleSwitchPriority = i;
				break;
			}

		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( IsA(PlayerPawn(Other).WeaponPriority[i]) )		// <- The fix...
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = 'enforcer';
		for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}

	
	}
}

simulated function TweenDown()
{
	PlayAnim('Down', 100.0, 0.0);
}

defaultproperties {
}
