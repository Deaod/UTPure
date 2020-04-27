//=============================================================================
// TournamentPlayerMeshInfo. (from UT v4.36)
//
// Parent of all Unreal Tournament Mesh animation classes.
//=============================================================================
class TournamentPlayerMeshInfo extends DPMSMeshInfo;

// static player animation functions (specific to tourney player)

static function PlayRunning(ALplayer Other,byte type,bool tween)   //quite important.  tweens always called at 0.1
{
  local name sequence; //what will be played.
  // determine facing direction
   if (type==2)
    sequence='BackRun';
   else if (type==3)
    sequence='StrafeR';
   else if (type==4)
    sequence='StrafeL';
  else if (Other.Weapon == None)
    sequence='RunSM';
  else if ( type==1 )   //pointing
  {
    if (Other.Weapon.Mass < 20)
      sequence='RunSMFR';
    else
      sequence='RunLGFR';
  }
  else
  {
    if (Other.Weapon.Mass < 20)
      sequence='RunSM';
    else
      sequence='RunLG';
  }
  if (tween)
    other.PlayAnim(sequence, 0.9, 0.1);
  else
    other.LoopAnim(sequence);
}

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
  if ( GetmyAnimGroup(Other) == 'Jumping' )
  {
    if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
      Other.TweenAnim('DuckWlkS', 2);
    else
      Other.TweenAnim('DuckWlkL', 2);
    return;
  }
  else if ( GetMyAnimGroup(Other) == 'Ducking' )
    TweenTime = 2;
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

static function PlayRecoil(Alplayer other)
{
  if (other.weapon==none) return; //????
  if ( Other.Weapon.bRapidFire )
  {
    if ( !Other.IsAnimating() && ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Walking)||(other.role==role_simulatedproxy&&other.mystate=='playerwalking'&&other.baseanim!=0)))
      Other.LoopAnim('StillFRRP', 0.02);
  }
  else if ( Other.AnimSequence == 'StillSmFr')
    Other.PlayAnim('StillSmFr', other.weapon.FiringSpeed, 0.02);
  else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
    Other.PlayAnim('StillLgFr', other.weapon.FiringSpeed, 0.02);
}
static function PlayDoubleRecoil(Alplayer other) //enf
{
 if (other.weapon==none) return; //????
  if ( Other.Weapon.bRapidFire )
  {
    if ( !Other.IsAnimating() && ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Walking)||(other.role==role_simulatedproxy&&other.mystate=='playerwalking'&&other.baseanim!=0)))
      Other.LoopAnim('StillFRRP', 0.02);
  }
  else if ( Other.AnimSequence == 'StillSmFr')
    Other.PlayAnim('StillSmFr', 2*other.weapon.FiringSpeed, 0.02);
  else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
    Other.PlayAnim('StillLgFr', 2*other.weapon.FiringSpeed, 0.02);
}

static function PlayWaiting(Alplayer other,byte type)
{
  local name newAnim;

  if ( Other.Mesh == None )
    return;
   //Play chatting is called seperately
  if ( (Other.IsInState('PlayerSwimming')) || ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Swimming)||(other.role==role_simulatedproxy&&other.region.zone.bwaterzone)) )
  {
    if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
      Other.LoopAnim('TreadSM');
    else
      Other.LoopAnim('TreadLG');
  }
  else
  {
    if (type==1||type==2)
    {
      if (type==1)
      {
        if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
          Other.TweenAnim('AimUpSm', 0.3);
        else
          Other.TweenAnim('AimUpLg', 0.3);
      }
      else
      {
        if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
          Other.TweenAnim('AimDnSm', 0.3);
        else
          Other.TweenAnim('AimDnLg', 0.3);
      }
    }
    else if ( type==3||type==4 )
    {
      if ( type==3 )
        Other.LoopAnim('StillFRRP');
      else if ( other.weapon==none||Other.Weapon.Mass < 20 )
        Other.TweenAnim('StillSMFR', 0.3);
      else
        Other.TweenAnim('StillFRRP', 0.3);
    }
    else   //type 0!
    {
      if ( FRand() < 0.1 )
      {
        if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
          Other.PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
        else
          Other.PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
      }
      else
      {
        if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
        {
          if ( (FRand() < 0.75) && ((Other.AnimSequence == 'Breath1') || (Other.AnimSequence == 'Breath2')) )
            newAnim = Other.AnimSequence;
          else if ( FRand() < 0.5 )
            newAnim = 'Breath1';
          else
            newAnim = 'Breath2';
        }
        else
        {
          if ( (FRand() < 0.75) && ((Other.AnimSequence == 'Breath1L') || (Other.AnimSequence == 'Breath2L')) )
            newAnim = Other.AnimSequence;
          else if ( FRand() < 0.5 )
            newAnim = 'Breath1L';
          else
            newAnim = 'Breath2L';
        }

        if ( Other.AnimSequence == newAnim )
          Other.LoopAnim(newAnim, 0.4 + 0.4 * FRand());
        else
          Other.PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
      }
    }
  }
}

static function PlayChatting(Alplayer other)
{
//  if ( Other.mesh != None ){
    if (frand()<0.3&&other.hasanim('chat2'))
       Other.LoopAnim('Chat2', 0.7, 0.25);   //unused, but I feel like adding kewl stuff.
    else
      Other.LoopAnim('Chat1', 0.7, 0.25);
  // }
}
//dodge functions
static function PlayDodgeL(Alplayer other)
{
  Other.TweenAnim('DodgeL', 0.25);
}
static function PlayDodgeR(Alplayer other)
{
  Other.TweenAnim('DodgeR', 0.25);
}
static function PlayDodgeB(Alplayer other)
{
  Other.TweenAnim('DodgeB', 0.25);
}
static function PlayDodgeF(Alplayer other)   //flip!
{
  Other.PlayAnim('Flip', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}
defaultproperties
{
}
