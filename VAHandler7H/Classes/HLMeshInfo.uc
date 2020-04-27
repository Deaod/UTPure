// ============================================================
// VAbeta.HLMeshInfo: for Half-Life conversions
// ============================================================

class HLMeshInfo expands TournamentMaleMeshInfo;
//ducking enhancements not fully used do to aim info that is not available on client.
static function PlayDuck(Alplayer other)
{
  if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) ){
    if (other.weapon==none||((other.role==role_autonomousproxy&&!other.weapon.bpointing)||(other.role==role_simulatedproxy&&!GuessIfPointing(other.weapon))))
      Other.TweenAnim('duckUpSmaim', 0.3);
    else
      Other.TweenAnim('duckUpSmfr', 0.3);
  }
  else{
    if (other.weapon==none||((other.role==role_autonomousproxy&&!other.weapon.bpointing)||(other.role==role_simulatedproxy&&!GuessIfPointing(other.weapon))))
      Other.TweenAnim('duckUpLgaim', 0.3);
    else
      Other.TweenAnim('duckUpLgfr', 0.3);
  }
}
//no recoil, just goto firing
static function PlayDoubleRecoil(ALplayer Other)
{
  PlayFiring(other);
}
static function PlayRecoil(ALplayer Other)
{
  PlayFiring(other);
}
//original was b0rked
static function PlayFiring(Alplayer other)
{
  // switch animation sequence mid-stream if needed
  if (Other.AnimSequence == 'RunLG')
    Other.AnimSequence = 'RunLGFR';
  else if (Other.AnimSequence == 'RunSM')
    Other.AnimSequence = 'RunSMFR';
  else if (Other.AnimSequence == 'WalkLG')
    Other.AnimSequence = 'WalkLGFR';
  else if (Other.AnimSequence == 'WalkSM')
    Other.AnimSequence = 'WalkSMFR';
  else if ( Other.AnimSequence == 'JumpSMFR')
    Other.TweenAnim('JumpSMFR', 0.03);
  else if ( Other.AnimSequence == 'JumpLGFR')
    Other.TweenAnim('JumpLGFR', 0.03);
  //extra anims (ducking):
  else if (Other.AnimSequence == 'duckUpSmaim')
    Other.AnimSequence = 'duckUpSmfr';
  else if (Other.AnimSequence == 'duckUpLgaim')
    Other.AnimSequence = 'duckUpLgfr';
  else if ( (GetMyAnimGroup(Other) == 'Waiting') || (GetMyAnimGroup(Other) == 'Gesture')
    && (Other.AnimSequence != 'TreadLG') && (Other.AnimSequence != 'TreadSM') )
  {
    if ( other.weapon==none||Other.Weapon.Mass < 20 )
      Other.TweenAnim('StillSMFR', 0.02);
    else
      Other.TweenAnim('StillFRRP', 0.02);
  }
}
//uses crouch death
static function PlayDying(Alplayer other, byte type)
{
  if (GetMyAnimGroup(Other) == 'Ducking')
    other.PlayAnim('Deadduck');
  else
    super.PlayDying(Other,Type);
}
static function PlayDecap(Alplayer Other)   //no head loss on HL models.
{
  Other.PlayAnim('Dead4',, 0.1);
}
static function PlayDodgeF(Alplayer other)   //no flip, but just dodgef
{
  Other.TweenAnim('DodgeF', 0.25);
}
defaultproperties {
}
