// ============================================================
// VAbeta.TSkaarjMeshInfo: skaarj hybrid
// ============================================================

class TSkaarjMeshInfo expands CustomPlayerMeshInfo;
static function PlayDuck(Alplayer Other)
{
  Other.PlayAnim('Duck',1, 0.25);
}
static function PlayDodgeL(Alplayer other)
{
  Other.PlayAnim('RollLeft', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}
static function PlayDodgeR(Alplayer other)
{
  Other.PlayAnim('RollRight', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}
//edited here and there:
static function PlayInAir(Alplayer Other)
{
  local vector X,Y,Z, Dir;
  local float f, TweenTime;

  if ( (GetMyAnimGroup(Other) == 'Landing') && !Other.bLastJumpAlt )
  {
    GetAxes(Other.Rotation, X,Y,Z);
    if (other.role==role_simulatedproxy)
      Dir = Normal(Other.Velocity); //approximation
    else
      Dir = Normal(Other.Acceleration);
    f = Dir dot Y;
    if ( f > 0.7 )
      Other.TweenAnim('DodgeL', 0.35);
    else if ( f < -0.7 )
      Other.TweenAnim('DodgeR', 0.35);
    else if ( Dir dot X > 0 )
      Other.TweenAnim('DodgeF', 0.35);
    else
      Other.TweenAnim('DodgeB', 0.35);
    Other.bLastJumpAlt = true;
    return;
  }
  Other.bLastJumpAlt = false;
  if ( other.AnimSequence == 'DodgeF' )
    TweenTime = 2;
  else if ( GetMyAnimGroup(Other) == 'Jumping' )
  {
    Other.TweenAnim('DodgeF', 2);
    return;
  }
  else
    TweenTime = 0.7;

  if ( Other.AnimSequence == 'StrafeL')
    Other.TweenAnim('DodgeR', TweenTime);
  else if ( Other.AnimSequence == 'StrafeR')
    Other.TweenAnim('DodgeL', TweenTime);
  else if ( Other.AnimSequence == 'BackRun')
    Other.TweenAnim('DodgeB', TweenTime);
  else if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.TweenAnim('JumpSMFR', TweenTime);
  else
    Other.TweenAnim('JumpLGFR', TweenTime);
}

static function PlayDying(Alplayer Other, byte type)
{
  if ( type==3 )
  {
    other.PlayAnim('Dead1',, 0.1);
    return;
  }

  // check for head hit
  if (type==4 )
  {
    PlayDecap(other);
    return;
  }

  // check for big hit
  if ( other.Velocity.Z > 200 )
  {
    if ( FRand() < 0.65 )
      other.PlayAnim('Dead4',,0.1);
    else if ( FRand() < 0.5 )
      other.PlayAnim('Dead2',, 0.1);
    else
      other.PlayAnim('Dead3',, 0.1);
    return;
  }

  // check for repeater death
  if (type==5)
  {
    other.PlayAnim('Dead9',, 0.1);
    return;
  }

  if (type==6)
  {
    if ( FRand() < 0.35  )
      PlayDecap(other);
    else
      other.PlayAnim('Dead2',, 0.1);
    return;
  }
  
  if ( FRand() < 0.6 ) //then hit in front or back
    other.PlayAnim('Dead1',, 0.1);
  else
    other.PlayAnim('Dead3',, 0.1);
}

static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;

  if ( class'GameInfo'.Default.bVeryLowGore )
  {
    other.PlayAnim('Dead2',, 0.1);
    return;
  }

  other.PlayAnim('Dead5',, 0.1);
  carc = other.Spawn(class<UTHeads>(dynamicloadobject("multimesh.TSkaarjHead",class'class')),,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.Initfor(other);
      carc.RemoteRole = ROLE_None;
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
  }
}
defaultproperties {
}
