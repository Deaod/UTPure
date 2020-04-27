//=============================================================================
// TCow.
//=============================================================================
class bbTCow extends bbCustomPlayer;

// TNSe
// RC5c
// Added: PlayFeignDeath() to support cows feigning dead...

simulated function SetMesh()
{
	Super.SetMesh();
	bIsMultiSkinned = true;
}

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local string FullSkinName;
	FullSkinName  = String(SkinActor.MultiSkins[1]);
	SkinName = FullSkinName;
	Facename= "";
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string SkinItem, SkinPackage;

	if ( SkinActor.Mesh == Default.FallBackMesh )
	{
		Super.SetMultiSkin(SkinActor, "CommandoSkins.cmdo", "Blake", TeamNum);
		return;
	}

	// two skins

	if ( SkinName == "" )
		SkinName = default.DefaultSkinName;
	else
	{
		SkinItem = SkinActor.GetItemName(SkinName);
		SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
	
		if( SkinPackage == "" )
		{
			SkinPackage=default.DefaultCustomPackage;
			SkinName=SkinPackage$SkinName;
		}
	}
	if( !SetSkinElement(SkinActor, 1, SkinName, default.DefaultSkinName) )
		SkinName = default.DefaultSkinName;

	// Set the team elements
	if( TeamNum < 4 )
		SetSkinElement(SkinActor, 2, default.DefaultCustomPackage$default.TeamSkin$String(TeamNum), SkinName);
	else
		SkinActor.MultiSkins[2] = Default.MultiSkins[2];

	// Set the talktexture
	if( Pawn(SkinActor) != None )
	{
		if ( (SkinName != Default.DefaultSkinName) && (TeamNum == 255) )
		{
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(SkinName$"Face", class'Texture'));
			if ( Pawn(SkinActor).PlayerReplicationInfo.TalkTexture == None )
				Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(default.DefaultFace, class'Texture'));
		}
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(default.DefaultFace, class'Texture'));
	}
}

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
		PlayAnim('Dead2',, 0.1);
		return;
	}

	// check for head hit
	if ( DamageType == 'Decapitated' )
	{
		PlayCowDecap();
		return;
	}

	// check for big hit
	if ( Velocity.Z > 200 )
	{
		PlayAnim('Dead3',,0.1);
		return;
	}

	if ( HitLoc.Z - Location.Z > 0.7 * CollisionHeight )
	{
		PlayAnim('Dead2',, 0.1);
		return;
	}
	
	PlayAnim('Dead1',, 0.1);
}

function PlayCowDecap()
{
	local carcass carc;

	if ( class'GameInfo'.Default.bVeryLowGore )
	{
		PlayAnim('Dead2',, 0.1);
		return;
	}

	PlayAnim('Dead4',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'TCowHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
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
	BaseEyeHeight = 0;
	TweenAnim('dead9', 0.5);
}

defaultproperties
{
    DefaultFace="TCowMeshSkins.WarCowFace"
    TeamSkin="T_cow_"
    DefaultCustomPackage="TCowMeshSkins."
    Deaths(0)=Sound'UnrealShare.DeathC1c'
    Deaths(1)=Sound'UnrealShare.DeathC1c'
    Deaths(2)=Sound'UnrealShare.DeathC1c'
    Deaths(3)=Sound'UnrealShare.DeathC1c'
    Deaths(4)=Sound'UnrealShare.cMoo2c'
    Deaths(5)=Sound'UnrealShare.cMoo2c'
    DefaultSkinName="TCowMeshSkins.WarCow"
    drown=Sound'UnrealShare.MDrown1'
    breathagain=Sound'UnrealShare.cough1n'
    Footstep1=Sound'UnrealShare.walkC'
    Footstep2=Sound'UnrealShare.walkC'
    Footstep3=Sound'UnrealShare.walkC'
    HitSound3=Sound'UnrealShare.injurC1c'
    HitSound4=Sound'UnrealShare.cMoo2c'
    GaspSound=Sound'UnrealShare.breath1n'
    UWHit1=Sound'UnrealShare.MUWHit1'
    UWHit2=Sound'UnrealShare.MUWHit2'
    LandGrunt=Sound'UnrealShare.lland01'
    CarcassType=Class'tcowcarcass'
    JumpSound=Sound'UnrealShare.MJump1'
    bIsMultiSkinned=False
    SelectionMesh="EpicCustomModels.TCowMesh"
    HitSound1=Sound'UnrealShare.injurC1c'
    HitSound2=Sound'UnrealShare.injurC2c'
    MenuName="Nali Cow"
    VoiceType="MultiMesh.CowVoice"
    Mesh=LodMesh'EpicCustomModels.TCowMesh'
    MultiSkins(2)=Texture'EpicCustomModels.TCowMeshSkins.cowpack'
	FakeClass="Multimesh.TCow"
}
