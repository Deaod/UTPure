//=============================================================================
// CustomPlayerMeshInfo. Subclass of BP1 models!
//=============================================================================
class CustomPlayerMeshInfo extends TournamentMaleMeshInfo;

static function PlayGutHit(Alplayer Other)
{
  if ( Other.AnimSequence == 'GutHit')
  {
    if (FRand() < 0.5)
      Other.TweenAnim('LeftHit', 0.1);
    else
      Other.TweenAnim('RightHit', 0.1);
  }
    Other.TweenAnim('GutHit', 0.1);

}

static function PlayHeadHit(Alplayer Other)
{
  if ( Other.AnimSequence == 'HeadHit')
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('HeadHit', 0.1);
}

static function PlayLeftHit(Alplayer Other)
{
  if ( Other.AnimSequence == 'LeftHit')
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('LeftHit', 0.1);
}

static function PlayRightHit(Alplayer Other)
{
  if ( Other.AnimSequence == 'RightHit')
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('RightHit', 0.1);
}

defaultproperties
{
}
