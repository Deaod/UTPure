// ===============================================================
// Stats.ST_UT_SeekingRocket: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_SeekingRocket extends UT_SeekingRocket;

var ST_Mutator STM;
var bool bDirect;

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) 
		{
			bDirect = Other.IsA('Pawn');
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function BlowUp(vector HitLocation)
	{
		STM.PlayerHit(Instigator, 16, bDirect);		// 16 = Rockets. No special for seeking, a seeker just means it has a larger chance of direct (yeah rite :P)
		HurtRadius(Damage,220.0, MyDamageType, MomentumTransfer, HitLocation );
		STM.PlayerClear();
		MakeNoise(1.0);
	}
}

defaultproperties {
}
