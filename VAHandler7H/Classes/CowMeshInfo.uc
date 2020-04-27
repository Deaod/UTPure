// ============================================================
// VAbeta.CowMeshInfo: for Tcow.
// fixx0rz feigning @$ well!
// ============================================================

class CowMeshInfo expands CustomPlayerMeshInfo;

static function PlayDying(Alplayer Other, byte type)
{
  if ( type==3 )
  {
    other.PlayAnim('Dead2',, 0.1);
    return;
  }

  // check for head hit
  if ( type==4 )
  {
    PlayDecap(Other);
    return;
  }

  // check for big hit
  if ( other.Velocity.Z > 200 )
  {
    other.PlayAnim('Dead3',,0.1);
    return;
  }

  if ( type==6 )
  {
    other.PlayAnim('Dead2',, 0.1);
    return;
  }
  
  other.PlayAnim('Dead1',, 0.1);
}

static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;

  if ( class'GameInfo'.Default.bVeryLowGore )
  {
    other.PlayAnim('Dead2',, 0.1);
    return;
  }

  other.PlayAnim('Dead4',, 0.1);
  carc = other.Spawn(class<UTHeads>(dynamicloadobject("multimesh.TCowHead",class'class')),,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.Initfor(other);
      carc.RemoteRole = ROLE_None;
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
  }
}
static function PlayFeignDeath(Alplayer Other){
  Other.tweenanim('dead9',0.1);
}
defaultproperties {
}
