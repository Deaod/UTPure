// ===============================================================
// Stats.ST_FlakSlug: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_FlakSlug extends flakslug;

var ST_Mutator STM;

function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Other != instigator ) 
		NewExplode(HitLocation,Normal(HitLocation-Other.Location), Other.IsA('Pawn'));
}

function NewExplode(vector HitLocation, vector HitNormal, bool bDirect)
{
	local vector start;
	local ST_UTChunkInfo CI;

	STM.PlayerHit(Instigator, 15, bDirect);		// 15 = Flak Slug
	HurtRadius(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);
	STM.PlayerClear();				// Damage is given now.
	start = Location + 10 * HitNormal;
 	Spawn( class'ut_FlameExplosion',,,Start);
	CI = Spawn(Class'ST_UTChunkInfo', Instigator);
	CI.STM = STM;
	CI.AddChunk(Spawn( class 'ST_UTChunk2',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk3',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk4',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk1',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk2',, '', Start));
 	Destroy();
}

function Explode(vector HitLocation, vector HitNormal)
{
	NewExplode(HitLocation, HitNormal, False);
}

defaultproperties {
}
