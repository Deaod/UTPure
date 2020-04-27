//================================================================================
// zp_Client.
//================================================================================
class zp_Client expands zp_Interface;

simulated function bool xxCh (Actor zzo)
{
	local Pawn zzp1;
	local Pawn zzp2;

	if (  !zzo.bIsPawn )
	{
		return False;
	}
	zzp1=Pawn(zzW.Owner);
	zzp2=Pawn(zzo);
	if ( (zzp1 != zzp2) && (zzp1.PlayerReplicationInfo.Team == zzp2.PlayerReplicationInfo.Team) ) // == or != ???, was ~=
	{
		return False;
	}
	return True;
}

simulated function bool xxClientFire (float zzV)
{
	if ( zzW.bCanClientFire && ((zzW.AmmoType == None) || (zzW.AmmoType.AmmoAmount > 0)) )
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
		zzW.GotoState('ClientFiring');
		return True;
	}
	return False;
}

simulated function Actor xxFire (float zzV)
{
	local Actor zzVictim;

	zzVictim=None;
	if ( (zzW.AmmoType != None) && (zzW.AmmoType.AmmoAmount <= 0) )
	{
		return None;
	}
	zzW.GotoState('NormalFire');
	zzW.bCanClientFire=True;
	zzW.bPointing=True;
	xxClientFire(zzV);
	if ( zzW.IsA('zp_Enforcer') )
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

simulated function Actor xxTraceFire (float zzacc)
{
	local Vector zzhl;
	local Vector zzhn;
	local Vector zzST;
	local Vector zzet;
	local Vector X,Y,Z;
	local Actor zzo;
	local bbPlayer zzbbP;

	zzbbP=bbPlayer(zzW.Owner);
	zzbbP.MakeNoise(zzbbP.SoundDampening);
	zzW.GetAxes(zzbbP.GR(),X,Y,Z);
	zzST=xxStartLocation();
	if ( zzW.IsA('SniperRifle') )
	{
		zzacc=0.00;
	}
	zzet=zzST + zzacc * (FRand() - 0.50) * Y * 1000 + zzacc * (FRand() - 0.50) * Z * 1000;
	X=vector(zzbbP.GR());
	if ((zp_SniperRifle(zzW) != None && zp_SniperRifle(zzW).zzbLongDistance) ||
	    (zp_Enforcer(zzW) != None && zp_Enforcer(zzW).zzbLongDistance) ||
	    (zp_ShockRifle(zzW) != None && zp_ShockRifle(zzW).zzbLongDistance) ||
	    (zp_SuperShockRifle(zzW) != None && zp_SuperShockRifle(zzW).zzbLongDistance))
		zzet += 100000 * X;
	else
		zzet += 10000 * X;
	zzo=zzbbP.TraceShot(zzhl,zzhn,zzet,zzST);
	return xxProcessTraceHit(zzo,zzhl,zzhn,X,Y,Z);
}

simulated function Actor xxProcessTraceHit (Actor o, Vector L, Vector N, Vector X, Vector Y, Vector Z)
{
	return None;
}

state zp_ShockRifle
{
	simulated function Actor xxProcessTraceHit (Actor zzo, Vector zzhl, Vector zzhn, Vector X, Vector Y, Vector Z)
	{
		local int zzHash;
		local float zzTime;
	
		if ( zzo == None )
		{
			zzhn= -X;
			zzhl=zzW.Owner.Location + X * 10000.00;
		}
		xxfx(zzhl,zzhn,xxStartLocation(),(zzo != None) && zzo.IsA('ShockProj'));
		if ( ShockProj(zzo) != None && zzW.IsA('ShockRifle') )
		{
			zp_ShockRifle(zzW).xxCombo(ShockProj(zzo));
		}
		else
		{
			zzHash=xxzpHash(Pawn(zzo));
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
		return zzo;
	}
	
	simulated function xxfx (Vector zzhl, Vector zzhn, Vector zzsl, bool zzprj)
	{
		local ShockBeam zzsm;
		local supershockbeam zzssm;
		local Vector zzdv;
		local int zznp;
		local Rotator zzsr;
		local Actor zzfxo;
		local Class<Actor> zzfx;
		local bool zzsu;
	
//		Log("SSRT:"@zp_SuperShockRifleTeam(zzW));
//		Log("Team:"@Pawn(zzW.Owner).PlayerReplicationInfo.Team);

		if ( zp_SuperShockRifle(zzW) != None  )
		{
			if ( zp_SuperShockRifleTeam(zzW) != None && Pawn(zzW.Owner).PlayerReplicationInfo.Team != 0 )
			{
				zzfx=Class'zp_ShockBeam';
			}
			else
			{
				zzfx=Class'zp_SuperShockBeam';
				zzsu=True;
			}
		}
		else
		{
			zzfx=Class'zp_ShockBeam';
		}
		zzfxo=None;
		zzdv=zzhl - zzsl;
		zznp=VSize(zzdv) / 135.00;
		if ( zznp >= 1 )
		{
			zzsr=rotator(zzdv);
			zzsr.Roll=Rand(65535);
			if ( zzsu )
			{
				zzssm=SuperShockBeam(zzW.Spawn(zzfx,zzfxo,,zzsl,zzsr));
				zzssm.MoveAmount=zzdv / zznp;
				zzssm.NumPuffs=zznp - 1;
			}
			else
			{
				zzsm=ShockBeam(zzW.Spawn(zzfx,zzfxo,,zzsl,zzsr));
				zzsm.MoveAmount=zzdv / zznp;
				zzsm.NumPuffs=zznp - 1;
			}
		}
		if (  !zzprj )
		{
			if ( zzsu )
			{
				zzW.Spawn(Class'zp_SuperShockRing',zzfxo,,zzhl + zzhn * 8,rotator(zzhn));
			}
			else
			{
				zzW.Spawn(Class'zp_RingExplosion',zzfxo,,zzhl + zzhn * 8,rotator(zzhn));
			}
		}
	}
	
}

state zp_Gun
{
	simulated function Actor xxTraceFire (float zzacc)
	{
		local Vector zzro;
		local zp_Enforcer zzE;
	
		if ( zzW.IsA('zp_Enforcer') )
		{
			zzE=zp_Enforcer(zzW);
			zzro=zzE.FireOffset;
			zzE.FireOffset *= 0.35;
			if ( (zzE.SlaveEnforcer != None) || zzE.bIsSlave )
			{
				zzacc=FClamp(3.00 * zzacc,0.75,3.00);
			}
			return Global.xxTraceFire(zzacc);
			zzE.FireOffset=zzro;
		}
		else
		{
			return Global.xxTraceFire(zzacc);
		}
	}
	
	simulated function Actor xxProcessTraceHit (Actor zzo, Vector zzhl, Vector zzhn, Vector X, Vector Y, Vector Z)
	{
		local UT_ShellCase zzS;
		local zp_HeavyWallHitEffect zzfx;
		local Vector zzbo;
		local Actor zzfxo;
		local int zzHash;
		local float zzTime;
	
		zzTime=PlayerPawn(zzW.Owner).CurrentTimeStamp;
		zzfxo=None;
		if ( zzW.IsA('zp_SniperRifle') )
		{
			zzS=zzW.Spawn(Class'zp_ShellCase',zzfxo,'None',zzW.Owner.Location + zzW.CalcDrawOffset() + 30 * X + (2.80 * zzW.FireOffset.Y + 5.00) * Y - Z * 1);
			if ( zzS != None )
			{
				zzS.DrawScale=2.00;
			}
		}
		else
		{
			zzS=zzW.Spawn(Class'zp_ShellCase',zzfxo,'None',zzW.Owner.Location + zzW.CalcDrawOffset() + 20 * X + zzW.FireOffset.Y * Y + Z);
		}
		if ( zzS != None )
		{
			zzS.Eject(((FRand() * 0.30 + 0.40) * X + (FRand() * 0.20 + 0.20) * Y + (FRand() * 0.30 + 1.00) * Z) * 160);
		}
		if ( zzo == zzW.Level )
		{
			zzfx=zzW.Spawn(Class'zp_HeavyWallHitEffect',zzfxo,,zzhl + zzhn,rotator(zzhn));
		}
		if ( zzo == None )
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
		if ( zzo.bIsPawn && xxCh(zzo) )
		{
			zzo.PlaySound(Sound'ChunkHit',,4.00,,100.00);
			zzbo=0.20 * zzo.CollisionRadius * Normal(Normal(zzhl - zzo.Location));
			zzbo.Z=zzbo.Z * 0.50;
			zzW.Spawn(Class'UT_BloodHit',None,,zzhl + zzbo,rotator(zzhn));
		}
		zzHash=xxzpHash(Pawn(zzo));
		if ( zzW.IsA('zp_SniperRifle') )
		{
			if ( zzo.bIsPawn && (zzhl.Z - zzo.Location.Z > 0.62 * zzo.CollisionHeight) )
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
		if (  !zzo.bIsPawn &&  !zzo.IsA('Carcass') )
		{
			zzW.Spawn(Class'UT_SpriteSmokePuff',,,zzhl + zzhn * 9);
		}
		else
		{
			zzo.PlaySound(Sound'ChunkHit',,4.00,,100.00);
		}
		return zzo;
	}
	
}

function Vector xxStartLocation ()
{
	local Vector zzHitLocation;
	local Vector zzHitNormal;
	local Vector zzStartTrace;
	local Vector X,Y,Z;
	local bbPlayer zzbbP;

	zzbbP=bbPlayer(zzW.Owner);
	zzW.GetAxes(zzbbP.GR(),X,Y,Z);
	zzStartTrace=zzbbP.Location + zzW.CalcDrawOffset() + zzW.FireOffset.X * X + zzW.FireOffset.Y * Y + zzW.FireOffset.Z * Z;
	if ( zzW.IsA('SniperRifle') )
	{
		zzStartTrace=zzbbP.Location;
		zzStartTrace.Z += zzbbP.EyeHeight;
	}
	return zzStartTrace;
}

