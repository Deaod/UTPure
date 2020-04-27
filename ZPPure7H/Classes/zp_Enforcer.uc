//================================================================================
// zp_Enforcer.
//================================================================================
class zp_Enforcer expands enforcer;

var zp_Interface zzS;
var zp_Interface zzC;
var bool zzbLongDistance;

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
	Super.Spawned();
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
	PlayOwnedSound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	bMuzzleFlash++;
	PlayAnim('Shoot', 0.81, 0.02);
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

function bool HandlePickupQuery (Inventory Item)
{
	return Super.HandlePickupQuery(Item);
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
	if ( IsInState('ClientActive') )
	{
		return False;
	}
	if ( zzC.HasZPDisabled() )
	{
		return Super.ClientFire(V);
	}
	zzC.xxFire(V);
	return False;
}

simulated function SetSwitchPriority (Pawn Other)
{
	zzS.SetSwitchPriority(Other);
}

function xx_ (int zzId, float zzTime)
{
	local Vector zzHitLocation;
	local Actor zzVictim;

	zzS.xxServerFire(zzId,zzTime,zzHitLocation,zzVictim);
	if ( zzVictim == None )
	{
		return;
	}
	zzVictim.TakeDamage(HitDamage,Pawn(Owner),zzHitLocation,30000.00 * Normal(zzHitLocation - Owner.Location),MyDamageType);
}

defaultproperties
{
    PickupMessage="You picked up another Zeroping Enforcer!"
}
