//================================================================================
// zp_ShockRifle.
//================================================================================
class zp_ShockRifle expands ShockRifle;

var zp_Interface zzS;
var zp_Interface zzC;
var bool bUsesAmmo;
var bool zzbLongDistance;
var bool zp_Enabled;

var float zzFireAdjust;

replication
{
	reliable if ( Role < ROLE_Authority )
		xx_,xxCombo;
	reliable if ( Role == ROLE_Authority )
		rSetOffset;
	reliable if ( ROLE == ROLE_Authority && bNetOwner)
		zzbLongDistance;
}

simulated event Spawned ()
{
	if ( zzC == None )
	{
		zzC=Spawn(Class'zp_Client');
		zzC.GotoState('zp_ShockRifle');
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
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.60, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None,Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire2', 0.80, 0.05);
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

function xxCombo (ShockProj zzProj)
{
	local Vector zzHitLocation;
	local Actor zzVictim;

	if ( zzProj != None )
	{
		zzVictim=zzProj;
		zzS.xxAimAtActor(zzVictim,zzHitLocation);
		zzS.xxFire(0.00);
		AmmoType.UseAmmo(2);
		zzProj.SuperExplosion();
		return;
	}
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
	zzVictim.TakeDamage(HitDamage,Pawn(Owner),zzHitLocation,60000.00 * Normal(zzHitLocation - Owner.Location),MyDamageType);
}

defaultproperties
{
    zp_Enabled=True
    PickupMessage="You got a Zeroping Shock Rifle."
}
