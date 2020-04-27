//=============================================================================
// TournamentFemaleMeshInfo.
//=============================================================================
class TournamentFemaleMeshInfo extends TournamentPlayerMeshInfo;

static function PlayRightHit(Alplayer Other)
{
  if ( Other.AnimSequence == 'RightHit')
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('RightHit', 0.1);
}

static function PlayDying(Alplayer Other, byte type)
{
  local carcass carc;

  if ( type==3 )     //suicide
  {
    Other.PlayAnim('Dead3',, 0.1);
    return;
  }

  // check for head hit
  if ( (type==4) && !class'GameInfo'.Default.bVeryLowGore )
  {
    PlayDecap(Other);
    return;
  }

  if ( FRand() < 0.15 )   //non-rep
  {
    Other.PlayAnim('Dead7',,0.1);
    return;
  }

  // check for big hit    (non-rep)
  if ( (Other.Velocity.Z > 250) && (FRand() < 0.75) )
  {           //can't really check if leg hit, but can verify if not head shot
    if ( (type!=6) && !class'GameInfo'.Default.bVeryLowGore && (FRand() < 0.6) )
    {
      Other.PlayAnim('Dead5',,0.05);   //spawned on client:
      carc = other.Spawn(class 'UT_FemaleFoot',,, other.Location - other.CollisionHeight * vect(0,0,0.5));
      if (carc != None)
      {
        carc.Initfor(Other);
        carc.remoterole=role_none;
        carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
        carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
      }
    }
    else
      Other.PlayAnim('Dead2',, 0.1);
    return;
  }

  // check for repeater death
  if ( type==5 )
  {
    Other.PlayAnim('Dead9',, 0.1);
    return;
  }

  if ( (type==6) && !class'GameInfo'.Default.bVeryLowGore )
  {
    if ( FRand() < 0.5 )
      PlayDecap(Other);
    else
      Other.PlayAnim('Dead3',, 0.1);
    return;
  }
           //add U1 loc checks?
  if ( FRand() < 0.5 ) //then hit in front or back
    Other.PlayAnim('Dead4',, 0.1);
  else
    Other.PlayAnim('Dead1',, 0.1);
}

static function PlayDecap(Alplayer Other)
{
  local carcass carc;

  Other.PlayAnim('Dead6',, 0.1);

  carc = other.Spawn(class 'UT_HeadFemale',,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
  if (carc != None)
  {
    carc.Initfor(other);
    carc.remoterole=role_none;
    carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
    carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
  }
}

defaultproperties
{
}
