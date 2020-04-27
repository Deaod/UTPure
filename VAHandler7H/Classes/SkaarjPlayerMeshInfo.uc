//=============================================================================
// SkaarjPlayerMeshInfo.
//=============================================================================
class SkaarjPlayerMeshInfo extends UnrealIPlayerMeshInfo;


//-----------------------------------------------------------------------------
// Animation functions

static function PlayDodgeL(Alplayer Other)
{
  Other.PlayAnim('LeftDodge', 1.35, 0.06);
}
static function PlayDodgeR(Alplayer Other)
{
  Other.PlayAnim('RightDodge', 1.35, 0.06);
}
static function PlayDodgeF(Alplayer Other)
{
  Other.PlayAnim('Lunge', 1.2, 0.06);
}

static function PlayTurning(Alplayer Other)
{
  Other.PlayAnim('Turn', 0.3, 0.3);
}

static function TweenToWalking(Alplayer Other)
{
    Other.TweenAnim('Walk', 0.1);
}
static function TweenToWalkingPoint(Alplayer Other){
  Other.TweenAnim('WalkFire', 0.1);
}
static function PlayRunning(ALplayer Other,byte type,bool tween)   //quite important.  tweens always called at 0.1
{
local bool point;
local name sequence;
if (other.role==role_autonomousproxy&&other.weapon!=none)
  point=other.weapon.bpointing;
else if (type>1&&other.weapon!=none)
  point=GuessIfPointing(other.weapon);
if (type==2) //no skaarj backrun
  type=byte(point);
if (type==3){
  if (point)
    sequence='StrafeRightfr';
  else
    sequence='StrafeRight';
}
else if (type==4) {
  if (point)
    sequence='StrafeLeftfr';
  else
    sequence='StrafeLeft';
}
else if (type==1)
  sequence='JogFire';
else
  sequence='Jog';
if (tween){
  if (type>2)
    other.PlayAnim(sequence, 1.75, 0.1);
  else
    other.PlayAnim(sequence, 1, 0.1);
}
else {
  if (type>2)
    other.LoopAnim(sequence,-2.5/other.GroundSpeed,0.1, 1.0);
  else
    other.LoopAnim(sequence,1.1);
}
}
static function PlayWalking(Alplayer Other)
{
    Other.LoopAnim('Walk',1.1);
}
static function PlayWalkingPoint(Alplayer Other)
{
  Other.LoopAnim('WalkFire',1.1);
}
static function PlayRising(Alplayer Other)
{
  Other.PlayAnim('Getup', 0.7, 0.1);
}

static function PlayFeignDeath(Alplayer Other)
{
  Other.PlayAnim('Death2',0.7);
}

static function PlayDying(Alplayer Other, byte type)
{
  local carcass carc;
  if ( FRand() < 0.15 )
  {
    Other.PlayAnim('Death',0.7,0.1);
    return;
  }

  // check for big hit
  if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) )
  {
    Other.PlayAnim('Death2', 0.7, 0.1);
    if (!class'GameInfo'.Default.bVeryLowGore )
    carc = other.Spawn(class 'CreatureChunks',,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.remoterole=role_none;
      carc.Mesh = mesh'SkaarjHead';
      carc.Initfor(other);
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
    }
    return;
  }

  // check for head hit
  if ( (type==2) || (type==4) && !class'GameInfo'.Default.bVeryLowGore )
  {
    Other.PlayAnim('Death5', 0.7, 0.1);
    carc = other.Spawn(class 'CreatureChunks',,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.remoterole=role_none;
      carc.Mesh = mesh'SkaarjHead';
      carc.Initfor(other);
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
    }
    return;
  }

  if ( FRand() < 0.15)
  {
    Other.PlayAnim('Death3', 0.7, 0.1);
    return;
  }

  if (type==0) //then hit in front or back
    Other.PlayAnim('Death3', 0.7, 0.1);
  else
  {
    if (type==1)
      Other.PlayAnim('Death', 0.7, 0.1);
    else
      Other.PlayAnim('Death4', 0.7, 0.1);
  }
}

static function PlayGutHit(ALplayer Other)
{
  if ( Other.AnimSequence == 'GutHit' )
  {
    if (FRand() < 0.5)
      Other.TweenAnim('LeftHit', 0.1);
    else
      Other.TweenAnim('RightHit', 0.1);
  }
  else
    Other.TweenAnim('GutHit', 0.1);
}

static function PlayHeadHit(ALplayer Other)
{
  if ( Other.AnimSequence == 'HeadHit' )
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('HeadHit', 0.1);
}

static function PlayLeftHit(ALplayer Other)
{
  if ( Other.AnimSequence == 'LeftHit' )
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('LeftHit', 0.1);
}

static function PlayRightHit(ALplayer Other)
{
  if ( Other.AnimSequence == 'RightHit' )
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('RightHit', 0.1);
}

static function PlayLanded(ALplayer Other, float impactVel)
{
  impactVel = impactVel/Other.JumpZ;
  impactVel = 0.1 * impactVel * impactVel;
  if ( impactVel > 0.17 )
    Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
  if ( !Other.FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
    Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.Land, SLOT_Interact, FClamp(4.5 * impactVel,0.5,6), false, 1000, 1.0);

  if ( (GetMyAnimGroup(Other) == 'Dodge') && Other.IsAnimating() )
    return;
  if ( (impactVel > 0.06) || (GetMyAnimGroup(Other) == 'Jumping') )
    Other.TweenAnim('Land', 0.12);
  else if ( !Other.IsAnimating() )
  {
    if (GetMyAnimGroup(Other) == 'TakeHit' )
      Other.AnimEnd();
    else
      Other.TweenAnim('Land', 0.12);
  }
}

static function PlayInAir(Alplayer Other)
{
  Other.TweenAnim('InAir', 0.4);
}

static function PlayDuck(Alplayer Other)
{
  Other.TweenAnim('Duck', 0.25);
}

static function PlayCrawling(Alplayer Other)
{
  Other.LoopAnim('DuckWalk');
}

static function TweenToWaiting(Alplayer Other, float tweentime)
{
 if ( (Other.IsInState('PlayerSwimming')) || ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Swimming)||(other.role==role_simulatedproxy&&other.region.zone.bwaterzone)) )
  {
    Other.TweenAnim('Swim', tweentime);
  }
  else
  {
    Other.TweenAnim('Firing', tweentime);
  }
}
static function PlayRecoil(Alplayer other)    //normal tween stuff.
{
if ( Other.Weapon.bRapidFire )
  {
    if ( !Other.IsAnimating() && ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Walking)||(other.role==role_simulatedproxy&&other.mystate=='playerwalking'&&other.baseanim!=0)))
      Other.TweenAnim('Firing', 0.3);
  }
}
static function PlayDoubleRecoil(Alplayer other){
  PlayRecoil(other);
}
static function PlayWaiting(ALplayer Other,byte type)
{
  local name newAnim;

 if ( (Other.IsInState('PlayerSwimming')) || ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Swimming)||(other.role==role_simulatedproxy&&other.region.zone.bwaterzone)) )
  {
    Other.LoopAnim('Swim');
  }
  else
  {
    if (type>1&&other.weapon!=none)
      type=byte(GuessIfPointing(Other.weapon));
    if ( (Other.Weapon != None) && type==1 )
      Other.TweenAnim('Firing', 0.3);
    else
    {
      if ( FRand() < 0.2 )
        newAnim = 'Breath';
      else
        newAnim = 'Breath2';

      if ( Other.AnimSequence == newAnim )
        Other.LoopAnim(newAnim, 0.3 + 0.7 * FRand());
      else
        Other.PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
    }
  }
}

static function PlayFiring(ALplayer Other)
{
  // switch animation sequence mid-stream if needed
  if (Other.AnimSequence == 'Jog')
    Other.AnimSequence = 'JogFire';
  else if (Other.AnimSequence == 'Walk')
    Other.AnimSequence = 'WalkFire';
  else if ( Other.AnimSequence == 'InAir' )
    Other.TweenAnim('JogFire', 0.03);
  else if ( (GetMyAnimGroup(Other) != 'Attack')
      && (GetMyAnimGroup(Other) != 'MovingAttack')
      && (GetMyAnimGroup(Other) != 'Dodge')
      && (Other.AnimSequence != 'Swim') )
    Other.TweenAnim('Firing', 0.02);
}

static function PlayWeaponSwitch(ALplayer Other);
static function PlayBigWeaponSwitch(ALplayer Other);

static function PlaySwimming(ALplayer Other)
{
   Other.LoopAnim('Swim');
}

static function TweenToSwimming(ALplayer Other, float tweentime)
{
  Other.TweenAnim('Swim',tweentime);
}

static function SwimAnimUpdate(ALplayer Other, bool bNotForward)
{
  if ( !Other.bAnimTransition && (GetMyAnimGroup(Other) != 'Gesture') && (Other.AnimSequence != 'Swim') )
    Other.TweenToSwimming(0.1);
}

///////////////////////////////////////////////////////////////////////////////////
// Taunts: Skaarj were lacking in them.  big thanks to Psychic_313 for this system!
///////////////////////////////////////////////////////////////////////////////////
static function Taunt(AlPlayer Other,name Sequence){ //overloadable (skaarj) taunt player.
  if (Sequence == 'Wave')
    Sequence='Shield';
  else if (Sequence == 'Victory1')
    Sequence='Spin';
  else if (Sequence == 'Thrust')
    Sequence='Claw';
  else if (Sequence == 'Challenge')
    Sequence='ShldTest'; //heh
  Other.PlayAnim(Sequence, 0.7, 0.2);    //tweak?
}
static function name GetMyAnimGroup(ALplayer Other){
 if(Other.animsequence=='Claw' || Other.animsequence=='Shield' || Other.animsequence=='Spin' || Other.Animsequence=='ShldTest')
    return 'Gesture'; // potential taunts (Shield == Wave)
 else if(Other.animsequence=='GunFix')
    return 'Waiting'; //chatting
 return other.GetAnimGroup(other.animsequence);
}
static function Playchatting(Alplayer Other) //Psychic says this=cool
{
  if(Other.AnimSequence!='GunFix')
    Other.TweenAnim('GunFix',0.3);
  else
    Other.Loopanim ('GunFix');
}
defaultproperties
{
}
