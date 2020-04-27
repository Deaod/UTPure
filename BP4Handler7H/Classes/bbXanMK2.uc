// ====================================================================
//  Class:  BP4Handler.bbXanMK2
//  Parent: BP4Handler.bbSkeletal
//
//  <Enter a description here>
// ====================================================================

class bbXanMK2 extends bbSkeletal;

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local texture Face;

	if ( TeamNum == 1 )
	{
		SkinActor.Skin =  texture(DynamicLoadObject("SkeletalChars.XanRed",class'Texture'));
		Face =  texture(DynamicLoadObject("SkeletalChars.XanRedFace",class'Texture'));
	}
	else if ( TeamNum == 0 )
	{
		SkinActor.Skin =  texture(DynamicLoadObject("SkeletalChars.XanBlue",class'Texture'));
		Face =  texture(DynamicLoadObject("SkeletalChars.XanBlueFace",class'Texture'));
	}
	else if ( TeamNum == 3 )
	{
		SkinActor.Skin =  texture(DynamicLoadObject("SkeletalChars.XanBronze",class'Texture'));
		Face =  texture(DynamicLoadObject("SkeletalChars.BronzeFace",class'Texture'));
	}
	else if ( TeamNum == 2 )
	{
		SkinActor.Skin =  texture(DynamicLoadObject("SkeletalChars.SteveXan",class'Texture'));
		Face =  texture(DynamicLoadObject("SkeletalChars.XanFace",class'Texture'));
	}
	else
	{
		SkinActor.Skin =  texture(DynamicLoadObject("SkeletalChars.XanTitanium",class'Texture'));
		Face =  texture(DynamicLoadObject("SkeletalChars.TitanFace",class'Texture'));
	}
	if( Pawn(SkinActor) != None )	
		Pawn(SkinActor).PlayerReplicationInfo.TalkTexture =Face;
}

defaultproperties
{
    Deaths(0)=Sound'Botpack.BDeath1'
    Deaths(1)=Sound'Botpack.BDeath1'
    Deaths(2)=Sound'Botpack.BDeath3'
    Deaths(3)=Sound'Botpack.BDeath4'
    Deaths(4)=Sound'Botpack.BDeath3'
    Deaths(5)=Sound'Botpack.BDeath4'
    HitSound3=Sound'Botpack.BInjur3'
    HitSound4=Sound'Botpack.BInjur4'
    LandGrunt=Sound'Botpack.Bland01'
    StatusDoll=Texture'Botpack.Icons.BossDoll'
    StatusBelt=Texture'Botpack.Icons.BossBelt'
    VoicePackMetaClass="BotPack.VoiceBoss"
    CarcassType=Class'Botpack.TBossCarcass'
    JumpSound=Sound'Botpack.BJump1'
    SelectionMesh="SkeletalChars.NewXan"
    SpecialMesh="Botpack.TrophyMale1"
    HitSound1=Sound'Botpack.BInjur1'
    HitSound2=Sound'Botpack.BInjur2'
    Die=Sound'Botpack.BDeath1'
    MenuName="Xan Mark II"
    VoiceType="BotPack.VoiceBoss"
    Mesh=SkeletalMesh'SkeletalChars.NewXan'
	FakeClass="SkeletalChars.XanMK2"
}
