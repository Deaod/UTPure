// ============================================================
// ZPPure5u.zp_SuperShockRifleTeam: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class zp_SuperShockRifleTeam expands zp_SuperShockRifle;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if (Pawn(Owner) != None)
	{
		Switch(Pawn(Owner).PlayerReplicationInfo.Team)
		{
			Case 0:	// RED
				break;
			Case 1:	// BLUE
				PlayerViewMesh=LodMesh'Botpack.ASMD2M';
				ThirdPersonMesh = LodMesh'Botpack.ASMD2hand';
				if (Owner.ROLE == ROLE_AutonomousProxy)
					Mesh = PlayerViewMesh;
				break;
			Default:
				break;
		}
	}
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	if (Pawn(Owner).PlayerReplicationInfo.Team != 0)
		Spawn(class'UT_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));
	else
		Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) ) 
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}


function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke;
	local SuperShockBeam SuperSmoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	if (Pawn(Owner).PlayerReplicationInfo.Team != 0)
	{
		Smoke = Spawn(class'ShockBeam',,,SmokeLocation,SmokeRotation);
		Smoke.MoveAmount = DVector/NumPoints;
		Smoke.NumPuffs = NumPoints - 1;	
	}
	else
	{
		SuperSmoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
		SuperSmoke.MoveAmount = DVector/NumPoints;
		SuperSmoke.NumPuffs = NumPoints - 1;	
	}
}

defaultproperties {
}
