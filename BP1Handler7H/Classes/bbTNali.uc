//=============================================================================
// TNali.
//=============================================================================
class bbTNali extends bbCustomPlayer;

// TNSe
// RC5c
// Added: PlayFeignDead(), since nali doesn't support all 3, only has 2.

// special animation functions
function PlayDying(name DamageType, vector HitLoc)
{
	if ( Mesh == FallBackMesh )
	{
		Super.PlayDying(DamageType, HitLoc);
		return;
	}
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();
			
	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead',, 0.1);
		return;
	}

	// check for head hit
	if ( DamageType == 'Decapitated' )
	{
		PlayNaliDecap();
		return;
	}

	// check for big hit
	if ( Velocity.Z > 200 )
	{
		if ( FRand() < 0.65 )
			PlayAnim('Dead4',,0.1);
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}

	if ( HitLoc.Z - Location.Z > 0.7 * CollisionHeight )
	{
		if ( FRand() < 0.35  )
			PlayNaliDecap();
		else
			PlayAnim('Dead2',, 0.1);
		return;
	}
	
	if ( FRand() < 0.6 ) //then hit in front or back
		PlayAnim('Dead',, 0.1);
	else
		PlayAnim('Dead2',, 0.1);
}

function PlayNaliDecap()
{
	local carcass carc;

	if ( class'GameInfo'.Default.bVeryLowGore )
	{
		PlayAnim('Dead2',, 0.1);
		return;
	}

	PlayAnim('Dead3',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'TNaliHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.RemoteRole = ROLE_SimulatedProxy;
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

function PlayFeignDeath()
{
	local float decision;

	BaseEyeHeight = 0;
	decision = frand();
	if ( decision < 0.50 )
		TweenAnim('DeathEnd', 0.5);
	else
		TweenAnim('DeathEnd2', 0.5);
}

defaultproperties
{
    DefaultFace="TNaliMeshSkins.nali-Face"
    TeamSkin="T_nali_"
    DefaultCustomPackage="TNaliMeshSkins."
    Deaths(0)=Sound'UnrealShare.death1n'
    Deaths(1)=Sound'UnrealShare.death1n'
    Deaths(2)=Sound'UnrealShare.death2n'
    Deaths(3)=Sound'UnrealShare.bowing1n'
    Deaths(4)=Sound'UnrealShare.injur1n'
    Deaths(5)=Sound'UnrealShare.injur2n'
    DefaultSkinName="TNaliMeshSkins.Ouboudah"
    drown=Sound'UnrealShare.MDrown1'
    breathagain=Sound'UnrealShare.cough1n'
    Footstep1=Sound'UnrealShare.walkC'
    Footstep2=Sound'UnrealShare.walkC'
    Footstep3=Sound'UnrealShare.walkC'
    HitSound3=Sound'UnrealShare.injur1n'
    HitSound4=Sound'UnrealShare.injur2n'
    GaspSound=Sound'UnrealShare.breath1n'
    UWHit1=Sound'UnrealShare.MUWHit1'
    UWHit2=Sound'UnrealShare.MUWHit2'
    LandGrunt=Sound'UnrealShare.lland01'
    JumpSound=Sound'UnrealShare.MJump1'
    bIsMultiSkinned=False
    SelectionMesh="EpicCustomModels.TNaliMesh"
    HitSound1=Sound'UnrealShare.fear1n'
    HitSound2=Sound'UnrealShare.cringe2n'
    MenuName="Nali"
    VoiceType="MultiMesh.NaliVoice"
    Mesh=LodMesh'EpicCustomModels.TNaliMesh'
	FakeClass="Multimesh.TNali"
}
