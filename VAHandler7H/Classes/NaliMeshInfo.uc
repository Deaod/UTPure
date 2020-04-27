// ============================================================
// VAbeta.NaliMeshInfo: for teh naliz
// ============================================================

class NaliMeshInfo expands CustomPlayerMeshInfo;
static function PlayDying(Alplayer Other, byte type)
{
  if ( type==3 )
  {
    other.PlayAnim('Dead',, 0.1);
    return;
  }

  // check for head hit
  if ( type==4)
  {
    PlayDecap(other);
    return;
  }

  // check for big hit
  if ( other.Velocity.Z > 200 )
  {
    if ( FRand() < 0.65 )
      other.PlayAnim('Dead4',,0.1);
    else
      other.PlayAnim('Dead2',, 0.1);
    return;
  }

  if (type==6 )
  {
    if ( FRand() < 0.35  )
      PlayDecap(other);
    else
      other.PlayAnim('Dead2',, 0.1);
    return;
  }
  
  if ( FRand() < 0.6 ) //then hit in front or back
    other.PlayAnim('Dead',, 0.1);
  else
    other.PlayAnim('Dead2',, 0.1);
}

static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;

  if ( class'GameInfo'.Default.bVeryLowGore )
  {
    other.PlayAnim('Dead2',, 0.1);
    return;
  }

  other.PlayAnim('Dead3',, 0.1);
    carc = other.Spawn(class<UTHeads>(dynamicloadobject("multimesh.TNaliHead",class'class')),,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.RemoteRole = ROLE_None;
      carc.Initfor(other);
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
  }
}

defaultproperties {
}
