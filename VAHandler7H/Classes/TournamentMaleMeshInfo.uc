//=============================================================================
// TournamentMaleMeshInfo.
//=============================================================================
class TournamentMaleMeshInfo extends TournamentPlayerMeshInfo;

// From BotPack.TournamentMale (UT v4.02)
// from BotPack.TournamentMale
static function PlayDying(Alplayer Other, byte type)
{
  if ( type==3 )   //suicide
  {
    Other.PlayAnim('Dead8',, 0.1);
    return;
  }

  // check for head hit
  if ( type==4 && !class'GameInfo'.Default.bLowGore )
  {
    PlayDecap(Other);
    return;
  }

  if ( FRand() < 0.15 )   //non-replicated info (so yes, different people have different anims)
  {
    Other.PlayAnim('Dead2',,0.1);
    return;
  }

  // check for big hit   //non-replicated info (so yes, different people have different anims)
  if ( (Other.Velocity.Z > 250) && (FRand() < 0.75) )
  {
    if ( FRand() < 0.5 )
      Other.PlayAnim('Dead1',,0.1);
    else
      Other.PlayAnim('Dead11',, 0.1);
    return;
  }

  // check for repeater death
  if ( type==5 )
  {
    Other.PlayAnim('Dead9',, 0.1);
    return;
  }

  if ( type==6 && !class'GameInfo'.Default.bLowGore )
  {
    if ( FRand() < 0.5 )
      PlayDecap(Other);
    else
      Other.PlayAnim('Dead7',, 0.1);
    return;
  }
           //implament unreali loc checks here??????
  if ( Other.Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
    Other.PlayAnim('Dead3',, 0.1);
  else
    Other.PlayAnim('Dead8',, 0.1);
}

static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;

  Other.PlayAnim('Dead4',, 0.1);

    carc = Other.Spawn(class'UT_HeadMale',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
    if (carc != None)
    {
      carc.remoterole=role_none;  //in case Epic fixes the head bug.
      carc.Initfor(Other);
      carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
    }
}


static function PlayGutHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'GutHit') || (Other.AnimSequence == 'Dead8') ) //old check was for dead2, but I assume that was a bug...
  {
    if (FRand() < 0.5)
      Other.TweenAnim('LeftHit', 0.1);
    else
      Other.TweenAnim('RightHit', 0.1);
  }
  else if ( FRand() < 0.6 )
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('Dead8', 0.1);

}

static function PlayHeadHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead7') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('HeadHit', 0.1);
  else
    Other.TweenAnim('Dead7', 0.1);
}

static function PlayLeftHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead9') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('LeftHit', 0.1);
  else
    Other.TweenAnim('Dead9', 0.1);
}

static function PlayRightHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead1') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('RightHit', 0.1);
  else
    Other.TweenAnim('Dead1', 0.1);
}

defaultproperties
{
}
