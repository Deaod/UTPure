//=============================================================================
// HumanMeshInfo.
//=============================================================================
class HumanMeshInfo extends UnrealiPlayerMeshInfo;

//static animations specific to unreali player.

//recoil lacks some stuff
static function PlayRecoil(Alplayer other)
{
  if (other.weapon==none) return; //????
  else if ( Other.AnimSequence == 'StillSmFr')
    Other.PlayAnim('StillSmFr', other.weapon.FiringSpeed, 0.02);
  else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
    Other.PlayAnim('StillLgFr', other.weapon.FiringSpeed, 0.02);
}
static function PlayDoubleRecoil(Alplayer other) //enf
{
 if (other.weapon==none) return; //????
  else if ( Other.AnimSequence == 'StillSmFr')
    Other.PlayAnim('StillSmFr', 2*other.weapon.FiringSpeed, 0.02);
  else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
    Other.PlayAnim('StillLgFr', 2*other.weapon.FiringSpeed, 0.02);
}

static function PlayDying(Alplayer Other, byte type)
{
  local carcass carc;

  if ( type==3 )
  {
    Other.PlayAnim('Dead1', 0.7, 0.1);
    return;
  }

  if ( FRand() < 0.15 )
  {
    Other.PlayAnim('Dead3',0.7,0.1);
    return;
  }

  // check for big hit
  if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) )
  {
    Other.PlayAnim('Dead2', 0.7, 0.1);
    return;
  }

  // check for head hit
  if ( (type==4 || type==6) //second switch is based on hitloc> 0.7. here should be >0.6  no biggie though.
     && !class'GameInfo'.Default.bVeryLowGore )
  {
    carc = other.Spawn(class'FemaleHead',,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.remoterole=role_none;
      carc.Initfor(other);
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
  //    other.ViewTarget = carc; //a stupid idea :D
    }
    Other.PlayAnim('Dead6', 0.7, 0.1);
    return;
  }


  if ( FRand() < 0.15)
  {
    Other.PlayAnim('Dead1', 0.7, 0.1);
    return;
  }

  if (type==0) //then hit in front or back
    Other.PlayAnim('Dead4', 0.7, 0.1);
  else
  {
    if ( type==1 && !class'GameInfo'.Default.bVeryLowGore )
    {
      Other.PlayAnim('Dead7', 0.7, 0.1);
      carc=Other.Spawn(class'Arm1',,, Other.Location);
      if (carc != None)
      {
        carc.remoterole=role_none;
        carc.Initfor(Other);
        carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
        carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
      }
    }
    else
      Other.PlayAnim('Dead5', 0.7, 0.1);
  }
}

static function PlayRunning(ALplayer Other,byte type,bool tween)   //quite important.  tweens always called at 0.1
{
  local name sequence; //what will be played.
  if (Other.Weapon == None){
    sequence='RunSM';
    return;
  }
  if (type>1){ //hard to know if pointing, unless autonomous
    if (other.role==role_simulatedproxy)
      type=byte(GuessIfPointing(other.weapon));
    else
      type=byte(other.weapon.bpointing);
  }

  if (type==1)
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
//only difference is type 0 wait times and breath based on health, rather than rand. (cheat possibilities?)
static function PlayWaiting(Alplayer other,byte type)
{
  local name newanim;
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
    else
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
          if ( Other.Health > 50 )
            newAnim = 'Breath1';
          else
            newAnim = 'Breath2';
        }
        else
        {
          if ( Other.Health > 50 )
            newAnim = 'Breath1L';
          else
            newAnim = 'Breath2L';
        }

        if ( Other.AnimSequence == newAnim )
          Other.LoopAnim(newAnim, 0.3 + 0.7 * FRand());
        else
          Other.PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
      }
    }
  }
}

static function PlayInAir(Alplayer Other)
{
  if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.TweenAnim('JumpSMFR', 0.8);
  else
    Other.TweenAnim('JumpLGFR', 0.8);
}
//////////////////////////////////////////////////////////////////////
//TAUNT OVERLOADS. MIGHT AS WELL USE unused animationz!
//////////////////////////////////////////////////////////////////////
static function Taunt(AlPlayer Other,name Sequence){
  //seq swapper:
  if (sequence=='taunt1'&&other.weapon!=none&&other.weapon.mass>19)    //makes use of large weaponz.
    sequence='taunt1L';
  else if (Sequence=='challenge')
    Sequence='victory1';
  else if (sequence=='victory1'&&other.weapon!=none&&other.weapon.mass>19)
    sequence='victory1l';
  else if (sequence=='wave'&&other.weapon!=none&&other.weapon.mass>19)
    sequence='wavel';
  else if (sequence=='thrust'){ //no pelvic thrust so swap over to unused look anim.
    if (other.weapon==none||other.weapon.mass<20)
      sequence='Look';
    else
      sequence='Lookl';
  }
  if (sequence!='')
    Other.PlayAnim(Sequence, 0.7, 0.2);
}
static function name GetMyAnimGroup(ALplayer Other){  //allows look to be recognized as a gesture
if (other.animsequence=='look'||other.animsequence=='lookl')
  return 'Gesture';
return other.GetAnimGroup(other.animsequence);
}
defaultproperties
{
}
