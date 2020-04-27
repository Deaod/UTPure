//=============================================================================
// UnrealIPlayerMeshInfo.    Very simple base.
//=============================================================================
class UnrealIPlayerMeshInfo extends DPMSMeshInfo;

static function PlayDodgeL(Alplayer Other)    //no dodges (exception: trooper)
{
  PlayDuck(Other);
}
static function PlayDodgeR(Alplayer Other)
{
  PlayDuck(Other);
}
static function PlayDodgeF(Alplayer Other)
{
  PlayDuck(Other);
}
static function PlayDodgeB(Alplayer Other)
{
  PlayDuck(Other);
}
static function PlayChatting(Alplayer Other) //generally no chat, so route to base wait
{
  PlayWaiting(other,0);
}

defaultproperties
{
}
