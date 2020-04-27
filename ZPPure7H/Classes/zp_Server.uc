//================================================================================
// zp_Server.
//================================================================================
class zp_Server expands zp_Interface
	config(Zeroping);

var config int HitTimeout;

simulated function bool OnServer ()
{
	return zzW.Role == 4;
}

simulated function bool OnClient ()
{
	return zzW.Role < 4;
}

simulated function bool xxCanHurt (Actor zzOther)
{
	local Pawn zzp1;
	local Pawn zzp2;

	if (  !zzOther.bIsPawn )
	{
		return False;
	}
	zzp1=Pawn(zzW.Owner);
	zzp2=Pawn(zzOther);
	if ( (zzp1 != zzp2) && (zzp1.PlayerReplicationInfo.Team == zzp2.PlayerReplicationInfo.Team) )
	{
		return False;
	}
	return True;
}

function bool xxCanSeePoint (Vector zzP, Actor zzTarget)
{
	local Vector zzHitLocation;
	local Vector zzHitNormal;
	local Vector zzStartTrace;
	local Vector zzDir;
	local Vector zzAimPoint;
	local Actor zzOther;
	local Pawn zzPawnOwner;

	zzPawnOwner=Pawn(zzW.Owner);
	zzStartTrace=xxStartLocation();
	zzDir=Normal(zzP - zzStartTrace);
	zzAimPoint=zzStartTrace + zzDir * 1000000;
	zzOther=zzPawnOwner.TraceShot(zzHitLocation,zzHitNormal,zzAimPoint,zzStartTrace);
	if ( zzOther != zzTarget )
	{
		return False;
	}
	if ( zzOther.IsA('Pawn') )
	{
		return Pawn(zzOther).AdjustHitLocation(zzP,zzDir);
	}
	return True;
}

function bool xxScanBoxForMiss (out Vector zzP, Actor zzVictim)
{
	local float zzScale;

	zzP=zzVictim.Location;
	zzScale=0.00;
JL001F:
	if ( zzScale < 1.50 )
	{
		zzScale=zzScale + 0.25;
		zzP=zzVictim.Location;
		zzP.X=zzVictim.Location.X + zzScale * zzVictim.CollisionRadius;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		zzP=zzVictim.Location;
		zzP.X=zzVictim.Location.X - zzScale * zzVictim.CollisionRadius;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		zzP=zzVictim.Location;
		zzP.Y=zzVictim.Location.Y + zzScale * zzVictim.CollisionRadius;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		zzP=zzVictim.Location;
		zzP.Y=zzVictim.Location.Y - zzScale * zzVictim.CollisionRadius;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		zzP=zzVictim.Location;
		zzP.Z=zzVictim.Location.Z + zzScale * zzVictim.CollisionHeight;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		zzP=zzVictim.Location;
		zzP.Z=zzVictim.Location.Z - zzScale * zzVictim.CollisionHeight;
		if (  !xxCanSeePoint(zzP,zzVictim) )
		{
			return True;
		}
		goto JL001F;
	}
	return False;
}

function Rotator xxFindMiss ()
{
	local Vector zzHitLocation;
	local Vector zzHitNormal;
	local Vector zzStartTrace;
	local Vector zzEndTrace;
	local Vector X,Y,Z;
	local Actor zzOther;
	local Pawn zzPawnOwner;

	if ( (zzW == None) || (zzW.Owner == None) )
	{
		return rotator(vect(1.00,0.00,0.00));
	}
	zzPawnOwner=Pawn(zzW.Owner);
	zzW.GetAxes(zzPawnOwner.ViewRotation,X,Y,Z);
	zzStartTrace=xxStartLocation();
	zzEndTrace=zzStartTrace;
	X=vector(zzPawnOwner.ViewRotation);
	if ((zp_SniperRifle(zzW) != None && zp_SniperRifle(zzW).zzbLongDistance) ||
	    (zp_Enforcer(zzW) != None && zp_Enforcer(zzW).zzbLongDistance) ||
	    (zp_ShockRifle(zzW) != None && zp_ShockRifle(zzW).zzbLongDistance) ||
	    (zp_SuperShockRifle(zzW) != None && zp_SuperShockRifle(zzW).zzbLongDistance))
		zzEndTrace += 100000 * X;
	else
		zzEndTrace += 10000 * X;
	zzOther=zzPawnOwner.TraceShot(zzHitLocation,zzHitNormal,zzEndTrace,zzStartTrace);
	if ( (zzOther == None) ||  !zzOther.IsA('Pawn') )
	{
		return zzPawnOwner.ViewRotation;
	}
	else
	{
		if ( xxScanBoxForMiss(zzHitLocation,zzOther) )
		{
			return rotator(zzHitLocation - zzStartTrace);
		}
	}
	return zzPawnOwner.ViewRotation;
}

function bool xxScanBoxForHit (out Vector zzP, Actor zzVictim, int zzNumSteps)
{
	local int zzxstep;
	local int zzystep;
	local int zzzstep;

	zzP=zzVictim.Location;
	zzzstep=2 * zzVictim.CollisionHeight / zzNumSteps;
	zzxstep=2 * zzVictim.CollisionRadius / zzNumSteps;
	zzystep=zzxstep;
	zzP.Z=zzVictim.Location.Z - zzVictim.CollisionHeight;
JL008F:
	if ( zzP.Z <= zzVictim.Location.Z + zzVictim.CollisionHeight )
	{
		zzP.X=zzVictim.Location.X - zzVictim.CollisionRadius;
JL00EF:
		if ( zzP.X <= zzVictim.Location.X + zzVictim.CollisionRadius )
		{
			zzP.Y=zzVictim.Location.Y - zzVictim.CollisionRadius;
JL014F:
			if ( zzP.Y <= zzVictim.Location.Y + zzVictim.CollisionRadius )
			{
				if ( xxCanSeePoint(zzP,zzVictim) )
				{
					return True;
				}
				zzP.Y += zzystep;
				goto JL014F;
			}
			zzP.X += zzxstep;
			goto JL00EF;
		}
		zzP.Z += zzzstep;
		goto JL008F;
	}
	return False;
}

function bool xxCanHitVictim (out Vector zzP, Actor zzVictim)
{
	zzP=zzVictim.Location;
	if ( xxCanSeePoint(zzP,zzVictim) )
	{
		return True;
	}
	zzP=zzVictim.Location;
	if ( xxScanBoxForHit(zzP,zzVictim,2) )
	{
		return True;
	}
	zzP=zzVictim.Location;
	if ( xxScanBoxForHit(zzP,zzVictim,4) )
	{
		return True;
	}
	return False;
}

function xxAimAtActor (out Actor zzOther, out Vector zzHitLocation)
{
	local PlayerPawn zzpl;

	if ( zzOther == None )
	{
		return;
	}
	zzpl=PlayerPawn(zzW.Owner);
	if ( xxCanHitVictim(zzHitLocation,zzOther) )
	{
		zzpl.ViewRotation=rotator(zzHitLocation - xxStartLocation());
	}
	else
	{
		zzpl.ViewRotation=xxFindMiss();
		zzOther=None;
	}
}

function xxServerFire (int zzId, float zzTime, out Vector zzHitLocation, out Actor zzVictim)
{
	local bool zzbHitSomeone;
	local bool zzServerHitscan;
	local Pawn zzCandidate;
	local int zzTimeDiff;
	local PlayerPawn zzpl;
	local Vector zzStartTrace;
	local Vector zzEndTrace;
	local Vector zzHitNormal;

	if ( zzW == None )
	{
		return;
	}
	zzpl=PlayerPawn(zzW.Owner);
	if ( zzpl == None )
	{
		return;
	}
	if ( zzId != 0 )
	{
		foreach AllActors(Class'Pawn',zzCandidate)
		{
			if ( (zzCandidate != None) && (xxzpHash(zzCandidate) == zzId) )
			{
				zzVictim=zzCandidate;
			}
			else
			{
			}
		}
	}
	zzTimeDiff=zzpl.CurrentTimeStamp * 1000 - zzTime * 1000;
	if ( (zzTimeDiff <= HitTimeout) || (HitTimeout == 0) )
	{
		if ( zzVictim != None )
		{
			xxAimAtActor(zzVictim,zzHitLocation);
		}
		else
		{
			zzpl.ViewRotation=xxFindMiss();
		}
	}
	if ( (zzTimeDiff > HitTimeout) && (zzVictim != None) && (HitTimeout != 0) )
	{
		zzpl.ClientMessage("Timed out:  Took" @ string(zzTimeDiff) @ "ms (Limit is" @ string(HitTimeout) @ ").  Using normal hitscan...");
	}
	if ( (zzW.Owner != None) &&  !zzW.IsInState('DownWeapon') )
	{
		zzVictim=xxFire(0.00);
	}
	if ( zzVictim != None )
	{
		zzHitLocation=zzVictim.Location;
	}
}

simulated function bool xxClientFire (float zzValue)
{
	if ( zzW.bCanClientFire && ((zzW.Role == 4) || (zzW.AmmoType == None) || (zzW.AmmoType.AmmoAmount > 0)) )
	{
		if ( (PlayerPawn(zzW.Owner) != None) && ((zzW.Level.NetMode == 0) || PlayerPawn(zzW.Owner).Player.IsA('Viewport')) )
		{
			if ( zzW.InstFlash != 0.00 )
			{
				PlayerPawn(zzW.Owner).ClientInstantFlash(zzW.InstFlash,zzW.InstFog);
			}
			PlayerPawn(zzW.Owner).ShakeView(zzW.shaketime,zzW.shakemag,zzW.shakevert);
		}
		if ( zzW.Affector != None )
		{
			zzW.Affector.FireEffect();
		}
		zzW.PlayFiring();
		if ( zzW.Role < 4 )
		{
			zzW.GotoState('ClientFiring');
		}
		return True;
	}
	return False;
}

simulated function Actor xxFire (float zzValue)
{
	local Actor zzVictim;

	zzVictim=None;
	if ( (zzW.AmmoType != None) && (zzW.AmmoType.AmmoAmount <= 0) )
	{
		return None;
	}
	if ( OnServer() && ( !zzW.IsA('SuperShockRifle') || zp_SuperShockRifle(zzW).bUsesAmmo) )
	{
		if ( (zzW.AmmoType == None) && (zzW.AmmoName != None) )
		{
			zzW.GiveAmmo(Pawn(zzW.Owner));
		}
		if (  !zzW.AmmoType.UseAmmo(1) )
		{
			return None;
		}
	}
	zzW.GotoState('NormalFire');
	zzW.bCanClientFire=True;
	zzW.bPointing=True;
	xxClientFire(zzValue);
	if ( zzW.IsA('zp_Enforcer') && OnClient() )
	{
		if ( zp_Enforcer(zzW).SlaveEnforcer != None )
		{
			Pawn(zzW.Owner).PlayRecoil(2.00 * zzW.FiringSpeed);
		}
		else
		{
			if (  !zp_Enforcer(zzW).bIsSlave )
			{
				Pawn(zzW.Owner).PlayRecoil(zzW.FiringSpeed);
			}
		}
		zzVictim=xxTraceFire(0.20);
	}
	else
	{
		Pawn(zzW.Owner).PlayRecoil(zzW.FiringSpeed);
		zzVictim=xxTraceFire(0.00);
	}
	zzW.aimerror=zzW.Default.aimerror;
	return zzVictim;
}

simulated function Actor xxTraceFire (float zzAccuracy)
{
	local Vector zzHitLocation;
	local Vector zzHitNormal;
	local Vector zzStartTrace;
	local Vector zzEndTrace;
	local Vector X,Y,Z;
	local Actor zzOther;
	local Pawn zzPawnOwner;

	zzPawnOwner=Pawn(zzW.Owner);
	zzPawnOwner.MakeNoise(zzPawnOwner.SoundDampening);
	zzW.GetAxes(zzPawnOwner.ViewRotation,X,Y,Z);
	zzStartTrace=xxStartLocation();
	if ( zzW.IsA('SniperRifle') )
	{
		zzAccuracy=0.00;
	}
	zzEndTrace=zzStartTrace + zzAccuracy * (FRand() - 0.50) * Y * 1000 + zzAccuracy * (FRand() - 0.50) * Z * 1000;
	X=vector(zzPawnOwner.ViewRotation);
	if ((zp_SniperRifle(zzW) != None && zp_SniperRifle(zzW).zzbLongDistance) ||
	    (zp_Enforcer(zzW) != None && zp_Enforcer(zzW).zzbLongDistance) ||
	    (zp_ShockRifle(zzW) != None && zp_ShockRifle(zzW).zzbLongDistance) ||
	    (zp_SuperShockRifle(zzW) != None && zp_SuperShockRifle(zzW).zzbLongDistance))
		zzEndTrace += 100000 * X;
	else
		zzEndTrace += 10000 * X;
	zzOther=zzPawnOwner.TraceShot(zzHitLocation,zzHitNormal,zzEndTrace,zzStartTrace);
	return xxProcessTraceHit(zzOther,zzHitLocation,zzHitNormal,X,Y,Z);
}

simulated function Actor xxProcessTraceHit (Actor zzo, Vector zzL, Vector zzN, Vector X, Vector Y, Vector Z)
{
	return None;
}

function SetSwitchPriority (Pawn Other)
{
	local int i;
	local name temp;
	local name Carried;

	if ( PlayerPawn(Other) != None )
	{
		i=0;
JL0017:
		if ( i < 20 )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == OriginalName )
			{
				zzW.AutoSwitchPriority=i;
				return;
			}
			i++;
			goto JL0017;
		}
	}
}

state zp_ShockRifle
{
	simulated function Actor xxProcessTraceHit (Actor zzOther, Vector zzHitLocation, Vector zzHitNormal, Vector X, Vector Y, Vector Z)
	{
		local int zzHash;
		local float zzTime;
	
		if ( zzOther == None )
		{
			zzHitNormal= -X;
			zzHitLocation=zzW.Owner.Location + X * 10000.00;
		}
		xxSpawnEffect(zzHitLocation,zzHitNormal,xxStartLocation(),(zzOther != None) && zzOther.IsA('ShockProj'));
		if ( OnClient() )
		{
			if ( ShockProj(zzOther) != None && zzW.IsA('ShockRifle') )
			{
				zp_ShockRifle(zzW).xxCombo(ShockProj(zzOther));
			}
			else
			{
				zzHash=xxzpHash(Pawn(zzOther));
				zzTime=PlayerPawn(zzW.Owner).CurrentTimeStamp;
				if ( zzW.IsA('zp_SuperShockRifle') )
				{
					zp_SuperShockRifle(zzW).xx_(zzHash,zzTime);
				}
				else
				{
					zp_ShockRifle(zzW).xx_(zzHash,zzTime);
				}
			}
		}
		return zzOther;
	}
	
	simulated function xxSpawnEffect (Vector zzHitLocation, Vector zzHitNormal, Vector zzSmokeLocation, bool zzHitShockProj)
	{
		local ShockBeam zzSmoke;
		local supershockbeam zzSuperSmoke;
		local Vector zzDVector;
		local int zzNumPoints;
		local Rotator zzSmokeRotation;
		local Actor zzFXOwner;
		local Class<Actor> zzfx;
		local bool zzbIsSuper;
	
		if ( zp_SuperShockRifle(zzW) != None  )
		{
			if ( zp_SuperShockRifleTeam(zzW) != None && Pawn(zzW.Owner).PlayerReplicationInfo.Team != 0 )
			{
				zzfx=Class'zp_ShockBeam';
			}
			else
			{
				zzfx=Class'zp_SuperShockBeam';
				zzbIsSuper=True;
			}
		}
		else
		{
			zzfx=Class'zp_ShockBeam';
		}
		if ( OnClient() )
		{
			zzFXOwner=None;
		}
		else
		{
			zzFXOwner=zzW.Owner;
		}
		zzDVector=zzHitLocation - zzSmokeLocation;
		zzNumPoints=VSize(zzDVector) / 135.00;
		if ( zzNumPoints >= 1 )
		{
			zzSmokeRotation=rotator(zzDVector);
			zzSmokeRotation.Roll=Rand(65535);
			if ( zzbIsSuper )
			{
				zzSuperSmoke=supershockbeam(zzW.Spawn(zzfx,zzFXOwner,,zzSmokeLocation,zzSmokeRotation));
				zzSuperSmoke.MoveAmount=zzDVector / zzNumPoints;
				zzSuperSmoke.NumPuffs=zzNumPoints - 1;
			}
			else
			{
				zzSmoke=ShockBeam(zzW.Spawn(zzfx,zzFXOwner,,zzSmokeLocation,zzSmokeRotation));
				zzSmoke.MoveAmount=zzDVector / zzNumPoints;
				zzSmoke.NumPuffs=zzNumPoints - 1;
			}
		}
		if (  !zzHitShockProj )
		{
			if ( zzbIsSuper )
			{
				zzW.Spawn(Class'zp_SuperShockRing',zzFXOwner,,zzHitLocation + zzHitNormal * 8,rotator(zzHitNormal));
			}
			else
			{
				zzW.Spawn(Class'zp_RingExplosion',zzFXOwner,,zzHitLocation + zzHitNormal * 8,rotator(zzHitNormal));
			}
		}
	}
	
}

state zp_Gun
{
	simulated function Actor xxTraceFire (float zzAccuracy)
	{
		local Vector zzRealOffset;
		local zp_Enforcer zzE;
	
		if ( zzW.IsA('zp_Enforcer') && OnClient() )
		{
			zzE=zp_Enforcer(zzW);
			zzRealOffset=zzE.FireOffset;
			zzE.FireOffset *= 0.35;
			if ( (zzE.SlaveEnforcer != None) || zzE.bIsSlave )
			{
				zzAccuracy=FClamp(3.00 * zzAccuracy,0.75,3.00);
			}
			return Global.xxTraceFire(zzAccuracy);
			zzE.FireOffset=zzRealOffset;
		}
		else
		{
			return Global.xxTraceFire(zzAccuracy);
		}
	}
	
	simulated function Actor xxProcessTraceHit (Actor zzOther, Vector zzHitLocation, Vector zzHitNormal, Vector X, Vector Y, Vector Z)
	{
		local UT_ShellCase zzS;
		local zp_HeavyWallHitEffect zzfx;
		local Vector zzBloodOffset;
		local Actor zzFXOwner;
		local int zzHash;
		local float zzTime;
	
		zzTime=PlayerPawn(zzW.Owner).CurrentTimeStamp;
		if ( OnClient() )
		{
			zzFXOwner=None;
		}
		else
		{
			zzFXOwner=zzW.Owner;
		}
		if ( zzW.IsA('zp_SniperRifle') )
		{
			zzS=zzW.Spawn(Class'zp_ShellCase',zzFXOwner,'None',zzW.Owner.Location + zzW.CalcDrawOffset() + 30 * X + (2.80 * zzW.FireOffset.Y + 5.00) * Y - Z * 1);
			if ( zzS != None )
			{
				zzS.DrawScale=2.00;
			}
		}
		else
		{
			zzS=zzW.Spawn(Class'zp_ShellCase',zzFXOwner,'None',zzW.Owner.Location + zzW.CalcDrawOffset() + 20 * X + zzW.FireOffset.Y * Y + Z);
		}
		if ( zzS != None )
		{
			zzS.Eject(((FRand() * 0.30 + 0.40) * X + (FRand() * 0.20 + 0.20) * Y + (FRand() * 0.30 + 1.00) * Z) * 160);
		}
		if ( zzOther == zzW.Level )
		{
			zzfx=zzW.Spawn(Class'zp_HeavyWallHitEffect',zzFXOwner,,zzHitLocation + zzHitNormal,rotator(zzHitNormal));
		}
		if ( (zzOther == None) && OnClient() )
		{
			if ( zzW.IsA('zp_SniperRifle') )
			{
				zp_SniperRifle(zzW).xx_(0,zzTime,False);
			}
			else
			{
				zp_Enforcer(zzW).xx_(0,zzTime);
			}
			return None;
		}
		if ( OnClient() )
		{
			if ( OnClient() && zzOther.bIsPawn && xxCanHurt(zzOther) )
			{
				zzOther.PlaySound(Sound'ChunkHit',,4.00,,100.00);
				zzBloodOffset=0.20 * zzOther.CollisionRadius * Normal(Normal(zzHitLocation - zzOther.Location)); // wtf?
				zzBloodOffset.Z=zzBloodOffset.Z * 0.50;
				zzW.Spawn(Class'UT_BloodHit',None,,zzHitLocation + zzBloodOffset,rotator(zzHitNormal));
			}
			zzHash=xxzpHash(Pawn(zzOther));
			if ( OnClient() )
			{
				if ( zzW.IsA('zp_SniperRifle') )
				{
					if ( zzOther.bIsPawn && (zzHitLocation.Z - zzOther.Location.Z > 0.62 * zzOther.CollisionHeight) )
					{
						zp_SniperRifle(zzW).xx_(zzHash,zzTime,True);
					}
					else
					{
						zp_SniperRifle(zzW).xx_(zzHash,zzTime,False);
					}
				}
				else
				{
					zp_Enforcer(zzW).xx_(zzHash,zzTime);
				}
			}
			if (  !zzOther.bIsPawn &&  !zzOther.IsA('Carcass') )
			{
				zzW.Spawn(Class'UT_SpriteSmokePuff',,,zzHitLocation + zzHitNormal * 9);
			}
			else
			{
				zzOther.PlaySound(Sound'ChunkHit',,4.00,,100.00);
			}
		}
		return zzOther;
	}
	
}

defaultproperties
{
    HitTimeout=1500
}
