//================================================================================
// zp_SuperShockRifle.
//================================================================================
class zp_SuperShockRifle expands SuperShockRifle;

var zp_Interface zzS;
var zp_Interface zzC;
var bool bUsesAmmo;
var int FiredShots;
var bool zzbLongDistance;

replication
{
	reliable if ( Role < 4 )
		xx_;
	reliable if ( Role == 4 )
		rSetOffset;
	reliable if ( ROLE == ROLE_Authority && bNetOwner)
		FiredShots, zzbLongDistance;
}

simulated event Spawned ()
{
	if ( zzC != None )
	{
		zzC.Destroy();
	}
	zzC=Spawn(Class'zp_Client');
	zzC.GotoState('zp_ShockRifle');
	zzC.zzW=self;
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
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.40, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.40 ,0.05);
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

function xx_ (int zzId, float zzTime)
{
	local Vector zzHitLocation;
	local Actor zzVictim;

	FiredShots++;
	zzS.xxServerFire(zzId,zzTime,zzHitLocation,zzVictim);
	if ( zzVictim == None )
	{
		return;
	}
	zzVictim.TakeDamage(HitDamage,Pawn(Owner),zzHitLocation,60000.00 * Normal(zzHitLocation - Owner.Location),MyDamageType);
}

defaultproperties
{
    PickupMessage="You got a Zeroping InstaGib Rifle."
}
