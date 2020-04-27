//=============================================================================
// TBossMeshInfo.   Only used to allow bosshead to be spawned (instead of normal male one :D)  actually uses head class, but boss mesh/modified drawscale
//=============================================================================
class TBossMeshInfo extends TournamentMaleMeshInfo;
// use boss head
static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;

  Other.PlayAnim('Dead4',, 0.1);

    carc = Other.Spawn(class'UT_HeadMale',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
    if (carc != None)
    {
      carc.Mesh=LodMesh'botpack.bossheadm';
      carc.DrawScale=0.158;
      carc.remoterole=role_none;  //in case Epic fixes the head bug.
      carc.Initfor(Other);
      carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
    }
}

