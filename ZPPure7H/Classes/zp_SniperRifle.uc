//================================================================================
// zp_SniperRifle.
//================================================================================
class zp_SniperRifle expands SniperRifle;

var zp_Interface zzS;
var zp_Interface zzC;
var bool zzbLongDistance;
var bool zp_Enabled;

replication
{
	reliable if ( Role < 4 )
		xx_;
	reliable if ( Role == 4 )
		rSetOffset;
	reliable if ( ROLE == ROLE_Authority && bNetOwner)
		zzbLongDistance;
}

simulated event Spawned ()
{
	if ( zzC == None )
	{
		zzC=Spawn(Class'zp_Client');
		zzC.GotoState('zp_Gun');
		zzC.zzW=self;
	}
}

simulated event Destroyed ()
{
	if ( zzC != None )
	{
		zzC.Destroy();
	}
	if ( zzS != None )
	{
		zzS.Destroy();
	}
	Super.Destroyed();
}

simulated function PlayFiring()
{
	local int r;

	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim(FireAnims[Rand(5)], 1.0, 0.05);

	if ( (PlayerPawn(Owner) != None) 
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}

function SetHand (float hand)
{
	Super.SetHand(hand);
	rSetOffset(FireOffset.Y);
}

simulated function rSetOffset (float Y)
{
	if ( (Owner != None) && Owner.IsA('PlayerPawn') )
	{
		zzC.AdjustKeyBindings(PlayerPawn(Owner));
	}
	FireOffset.Y=Y;
}

function Fire (float V)
{
	if ( zzS.HasZPDisabled() )
	{
		Super.Fire(V);
	}
}

simulated function bool ClientFire (float V)
{
	if ( zzC.HasZPDisabled() )
	{
		return Super.ClientFire(V);
	}
	zzC.xxFire(V);
	return False;
}

function SetSwitchPriority (Pawn Other)
{
	zzS.SetSwitchPriority(Other);
}

state Idle
{
	function Fire (float Value)
	{
		Global.Fire(Value);
	}
	
}

function xx_ (int zzId, float zzTime, bool zzHeadShot)
{
	local Vector zzMomentum;
	local Vector zzHitLocation;
	local Actor zzVictim;

	zzS.xxServerFire(zzId,zzTime,zzHitLocation,zzVictim);
	if ( zzVictim == None )
	{
		return;
	}
	zzMomentum=Normal(zzHitLocation - Owner.Location);
	if ( zzHeadShot )
	{
		zzHitLocation=zzVictim.Location;
		zzHitLocation.Z += 0.70 * zzVictim.CollisionHeight;
		zzVictim.TakeDamage(100,Pawn(Owner),zzHitLocation,35000 * zzMomentum,AltDamageType);
	}
	else
	{
		zzVictim.TakeDamage(45,Pawn(Owner),zzHitLocation,30000 * zzMomentum,MyDamageType);
	}
}

defaultproperties
{
    zp_Enabled=True
    PickupMessage="You got a Zeroping Sniper Rifle."
}
