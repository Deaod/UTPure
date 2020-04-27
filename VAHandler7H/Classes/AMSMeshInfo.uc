// ============================================================
// VAbeta.AMSMeshInfo: allows AMS models to handle head spawn/no spawn.
// also used for Skeletal chars as it is EXACTLY the same
// ============================================================

class AMSMeshInfo expands TournamentMaleMeshInfo;

static function PlayDecap(Alplayer Other)   //always done on client :D
{
  local carcass carc;
  local class<UTHeads> carcclass;

  Other.PlayAnim('Dead4',, 0.1);
    if (!other.hasanim('HeadIsRemoved'))  //AMS head decap flag
      return;
    if (other.bisfemale)
      carcclass=class'ut_headfemale';
   // else if (ALPRI(other.playerreplicationinfo).zzmyclass.default.CarcassType==Class'botpack.TBossCarcass')
  //    carcclass=class'ut_bosshead';
    else
      carcclass=class'UT_HeadMale';
    carc = Other.Spawn(carcclass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
    if (carc != None)
    {
      if (ALPRI(other.playerreplicationinfo).zzmyclass.default.CarcassType==Class'botpack.TBossCarcass'){
        carc.Mesh=LodMesh'botpack.bossheadm';
        carc.DrawScale=0.158;
      }
      carc.remoterole=role_none;  //in case Epic fixes the head bug.
      carc.Initfor(Other);
      carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
    }
}

defaultproperties {
}
