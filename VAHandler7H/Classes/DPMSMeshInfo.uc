//=============================================================================
// DPMSMeshInfo. (release 4 - UT)
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Client-side animation handler
// New version by UsAaR33
// changes: too many to list here.
// Basically, the entire system has been rewritten.
//=============================================================================
class DPMSMeshInfo extends Info;

// mesh variables
//=============================================================================
// Static Animation Functions

//=============================================================================
// Static Player Animation Functions (Implement in sub-classes)

static function PlayInAir(ALplayer Other);
static function PlayRecoil(ALplayer Other);    //a bit limited I suppose
static function PlayDoubleRecoil(ALplayer Other);
//Running types:
//0 (PlayRunning): normal
//1 (PlayRunningPoint): Pointing
//2 (BackRun): Backrun
//3 (StrafeR): Strafe right
//4 (StrafeL): Strafe Left
static function PlayRunning(ALplayer Other,byte type,bool tween);

//dying is actually called by carcass.
static function PlayDying(ALplayer Other, byte type);

// Some animation control and movement functions from the PlayerWalking state
// PlayerWalking.AnimEnd()
//0 (playwaiting): Normal wait
//1 (Aimup): Aiming up
//2 (AimDown): Aiming down
//3 (PlayRapid): Rapid fire wait (pulse/mini. recoil stuff as well?)
//4 (PlayWeapPoint): Weapon pointing (non-recoil firing)
static function PlayWaiting(ALplayer Other,byte type);
static function PlayChatting(ALplayer Other);

//dodge functions
static function PlayDodgeL(ALplayer Other);
static function PlayDodgeR(ALplayer Other);
static function PlayDodgeB(ALplayer Other);
static function PlayDodgeF(ALplayer Other);

// can used to play animation or call other animation functions
//static function PlaySpecial(ALplayer Other, name Type);
static function Taunt(AlPlayer Other,name Sequence){ //overloadable (skaarj) taunt player.
  if (sequence=='Wave'&&other.weapon!=none&&other.weapon.mass>19&&other.hasanim('WaveL')) //allow large weapon holding wave anim!
    sequence='WaveL';
  if (sequence=='challenge'&&!Other.hasanim(sequence)){
    if (other.HasAnim('fighter'))
       sequence='fighter';
    else if (other.HasAnim('look'))
       sequence='look';
    else
      sequence='victory1';
  }
  Other.PlayAnim(Sequence, 0.7, 0.2);
}
//overloadable getanimgroup(). allows other anims to be used.
//currently used under skaarj trooper. Thanks Psychic_313!
static function name GetMyAnimGroup(ALplayer Other){
  if (other.mesh!=none&&other.animsequence!='')
    return other.GetAnimGroup(other.animsequence);
}
// from Engine.PlayerPawn (UT v4.36)
                                                 //skaarj overloads me
static function SwimAnimUpdate(ALplayer Other, bool bNotForward)
{

  if ( !Other.bAnimTransition && (GetMyAnimGroup(Other) != 'Gesture') )
  {
    if ( bNotForward )
     {
        if ( GetMyAnimGroup(other) != 'Waiting' )
        TweenToWaiting(other,0.1);
    }
    else if ( GetMyAnimGroup(other) == 'Waiting' )
      TweenToSwimming(other,0.1);
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
// WalkingAnimEnd
// based on PlayerWalking.AnimEnd
// Called from simulated function animend() in state walking.
// Critical to anim system.
//////////////////////////////////////////////////////////////////////////////////////////////////
static final function xxWalkingAnimEnd(ALplayer Other)
{
  local name MyAnimGroup;
  local name Func;
local byte type;
local byte move, duck;
  if (other.mesh==none)
    return;
  if (other.role==role_simulatedproxy){
    xxBaseRead(other,func,type); //get type (in byte) and name to call from base anim.
    TypeRead(func,move,duck); //get info (moving/ducking)
//    if (other.zzisbeta)
 //     log("xxWalkinganimend with func '"$func$"' and type '"$type$"' baseanim is"@other.baseanim@"animseq is"@other.animsequence@"State is"@other.getstatename()@"state should be in is"@other.mystate);
  }
  Other.bAnimTransition = false;
  if ((other.role==role_simulatedproxy&&Other.baseanim!=/*'playinair'*/0)||(other.role==role_autonomousproxy&&other.Physics == PHYS_Walking))
  {
    if (duck==1||other.biscrouching) //last case is for auto proxies.
    {
      if ((other.role==role_simulatedproxy&&move==0)||(other.role==role_autonomousproxy&&!other.bIsTurning && (other.Velocity.X * other.Velocity.X + other.Velocity.Y * other.Velocity.Y) < 1000) )
        PlayDuck(Other);
      else
        PlayCrawling(Other);
    }
    else
    {
    MyAnimGroup = GetMyAnimGroup(other);
      if ((Other.Velocity.X * Other.Velocity.X + Other.Velocity.Y * Other.Velocity.Y) < 1000)  //Safe on client?  I guess...
      {
        if ( MyAnimGroup == 'Waiting' ){ //check type.
          if (other.role==role_autonomousproxy) //process type autonomously
            other.playwaiting();
          else {
            if (func=='playchatting')
              PlayChatting(other);
            else
              PlayWaiting(other,type); //use func processor.
          }
        }
        else
        {
          Other.bAnimTransition = true;
          TweenToWaiting(Other,0.2); //just a tween.
        }
      }
      else if (other.bIsWalking||(other.role==role_simulatedproxy&&(Other.baseanim==11||other.baseanim==12)))
      {
        if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
        {
          if (other.role==role_autonomousproxy)
            other.TweenToWalking(0.1);
          //else if (other.baseanim=='playwalkingpoint')
          else if (Other.baseanim==12)
            TweentoWalkingPoint(other);
          else
            TweentoWalking(other);
          Other.bAnimTransition = true;
        }
        else {
          if (other.role==role_autonomousproxy)
            other.PlayWalking();
//        else if (other.baseanim=='playwalkingpoint')
          else if (Other.baseanim==12)
            PlayWalkingPoint(other);
          else
            PlayWalking(other);
          }
      }
      else
      {
        if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
        {
          Other.bAnimTransition = true;
          if (other.role==role_autonomousproxy)
            other.TweenToRunning(0.1);
          else  //from baseread.
            PlayRunning(other,type,true);
        }
        else {
          if (other.role==role_autonomousproxy)
            other.TweenToRunning(0.1);
          else  //from baseread.
            PlayRunning(other,type,false);
        }
      }
    }
  }
  else
    PlayInAir(Other);
}

/////////////////////////////////////////////////////
//ANIMATION SYSTEM FUNCTIONS:
//These functions analyse and parse server anim calls
/////////////////////////////////////////////////////
//This important function returns the base rule group and extra byte (if needed)
static final function xxBaseRead(ALPlayer Other,out name func,out byte type){ //check group and read type.
local name outname[6];
outname[0]='playwalking';
outname[1]='playwalkingpoint';
outname[2]='PlayTurning';
outname[3]='PlayChatting';
outname[4]='playduck';
outname[5]='PlayCrawling';
  type=0;
  if (other.baseanim==0){
    func='playinair';
    return;
  }
  if (other.baseanim<6){
    func='PlayWaiting';
    type=other.baseanim-1;
    return;
  }
  if (other.baseanim<11){
    func='PlayRunning';
    type=other.baseanim-6;
    return;
  }
  if (other.baseanim<17){
    func=outname[other.baseanim-11];
    return;
  }
  func='SwimAnimUpdate';
  type=other.baseanim-17;
/*switch (other.baseanim){
case 'PlayWaiting':
type=1;
case 'aimup':
if (type==0)
type=2;
case 'aimdown':
if (type==0)
type=3;
case 'playrapid':
if (type==0)
type=4;
case 'PlayWeapPoint':
if (type==0)
type=5;
type--;
func='PlayWaiting';
return;
case 'PlayRunning':
type=1;
case 'PlayRunningPoint':
if (type==0)
type=2;
case 'BackRun':
if (type==0)
type=3;
case 'StrafeR':
if (type==0)
type=4;
case 'StrafeL':
if (type==0)
type=5;
type--;
func='PlayRunning';
return;
case 'PlayTurning':
case 'playwalkingpoint':
case 'playinair':   //physics name!
case 'playwalking':
case 'playduck':
case 'PlayCrawling':
Case 'PlayChatting':
func=other.baseanim;  //save space.
return;
case 'swimanimupdate':
type=1;
case 'swimanimupdatenotf':
if (type==0)
type=2;
type--;
func='SwimAnimUpdate';
return;
} */
}
//reads properties of type.   (doesn't check swim do to type determing motion)
static final function TypeRead(name func,out byte move,out byte duck){
move=0;
duck=0;
switch (func){
  case 'PlayChatting':
  case 'PlayWaiting':
  case 'PlayTurning': //does move, but based on 0 accel.
  return;
  case 'PlayInAir': //needed?
  case 'PlayRunning':
  case 'Playwalking':
  case 'PlaywalkingPoint':
  move=1;
  return;
}
if (func=='playduck'||func=='playcrawling'){
  duck=1;
  move=byte(func=='playcrawling');
  return;
}
}
//used for skaarj trooper/humans. Educated Guesses (which is why it is normally replicated) if weapon is pointing. priority is true.
//based on the concept that animsequences of weapons are always replicated.
static final function bool GuessIfPointing(weapon other)
{       //will occasionally screw up, especially on custom weapons.
  if (other==none)
    return false; //duh
  if (other.animsequence=='Idle'||other.animsequence=='Still'||other.animsequence=='Down'||other.animsequence=='Select'||other.animsequence=='Sway'||other.animsequence=='Spindown'||other.animsequence=='Boltend'||other.animsequence=='Idle2'||other.animsequence=='Walking')
    return false;
  if (other.isa('UT_Flakcannon')&&!other.IsAnimating()) //flak is wierd.
    return false;
  return true;
}
// PlayerSwimming.AnimEnd
static final function xxSwimAnimEnd(ALplayer Other)
{
  local vector X,Y,Z;

  GetAxes(Other.Rotation, X,Y,Z);
  //velocity approximation client-side.
  if ( (other.role==role_autonomousproxy&&Other.Acceleration Dot X <= 0 )||(other.role==role_simulatedproxy&&Other.baseanim==18))
  {
    if ( GetMyAnimGroup(other) == 'TakeHit' )
    {
      Other.bAnimTransition = true;
      if (other.role==role_autonomousproxy)
      Other.TweenToWaiting(0.2);
      else
      TweenToWaiting(other,0.2);
    }
    else{
      if (other.role==role_autonomousproxy)
      other.PlayWaiting();
      else
      playwaiting(other,0);
    }
  }
  else
  {
    if (GetMyAnimGroup(other) == 'TakeHit' )
    {
      Other.bAnimTransition = true;
      TweenToSwimming(other,0.2);
    }
    else
      //Other.PlaySwimming();
      PlaySwimming(Other);
  }
}
//////////////////////////////////////////////////////////////////////
// xxUpdateAnims
// Core animation updater.
// This function processes "special case anims" (tweens and plays) and then will run through a rip off of processmove for the base (loop) anims (this is basically run-time tweens)
//////////////////////////////////////////////////////////////////////
final static function xxUpdateAnims(alplayer other){
local name Func;
local byte type;
local byte move, duck;
local name zztaunt;
if (other.animsequence==''&&other.zznextanim==0){ //initial: force anim to play!
  other.animend();
  return;
}
if (other.zznextanim>128){ //landed
//   log ("Client land!");
   PlayLanded(other, (other.zznextanim&127)*20);  //remove flag and uncompress
   other.zznextanim=0; //no more.
   }
//if (other.nextanim=='taunt1'||other.nextanim=='thrust'||other.nextanim=='victory1'||other.nextanim=='wave'){
if ((other.zznextanim&31)>17){
//  if (other.zzisbeta)
//    log ("xxupdateanims. received gesture"@other.nextanim@"last gesture was at"@other.lastgesturetime);
  if (other.mystate=='gameended'||(class'VAsettings'.default.gesturetime!=0&&other.lastgesturetime+class'VAsettings'.default.gesturetime<=other.level.timeseconds))
  {
//    if (other.zzisbeta)
//      log ("xxupdateanims: doing gesture taunt!");
    switch (other.zznextanim){
      case 18:
        zztaunt='taunt1';
        break;
      case 19:
        zztaunt='thrust';
        break;
      case 20:
        zztaunt='victory1';
        break;
      case 21:
        zztaunt='wave';
        break;
      case 22:
        zztaunt='challenge';
        break;
     }
    if (zztaunt!=''){
      taunt (other,zztaunt);
      other.lastgesturetime=other.level.timeseconds; //update timer.
    }
  }
//  other.nextanim=''; //no more next
other.zznextanim=0;
}
//if (other.nextanim!=''){ //special anim is on
if (other.zznextanim!=0){
  if (((other.zznextanim&31)!=16)&&(other.zznextanim&31)>11)
    other.banimtransition=true;
  switch (other.zznextanim&31){ //1337 animation switcher!!!
   // case 'PlayDodgeL':
    case 1:
      PlayDodgeL(other);
      break;
//    case 'PlayDodgeR':
    case 2:
      PlayDodgeR(other);
      break;
//    case 'PlayDodgeB':
    case 3:
      PlayDodgeB(other);
      break;
    //case 'PlayDodgeF':
    case 4:
      PlayDodgeF(other);
      break;
    //case 'PlayRising':
    case 5:
      PlayRising(other);
      break;
    //case 'PlayFeignDeath':
    case 6:                    //obsolete, I suppose?
      PlayFeignDeath(other);
      break;
    //case 'PlayDoubleRecoil':
    case 7:
      PlayDoubleRecoil(other);
      break;
    case 8:
    //case 'playrecoil':
      playrecoil(other);
      break;
    case 9:
    //case 'playfiring':
      playfiring(other);
      break;
    case 10:
    //case 'PlayBigWeaponSwitch':
      PlayBigWeaponSwitch(other);
      break;
    //case 'PlayWeaponSwitch':
    case 11:
      PlayWeaponSwitch(other);
      break;
    //case 'playguthit':
    case 12:
      playguthit(other);
      break;
    case 13:
    //case 'PlayHeadHit':
      PlayHeadHit(other);
      break;
    //case 'PlayLeftHit':
    case 14:
      PlayLeftHit(other);
      break;
    //case 'PlayRightHit':
    case 15:
      PlayRightHit(other);
      break;
    case 16:
      PlayinAir(other);
      other.baseanim=0;
      break;
    case 17:  //swim duck
      Playduck(other);
      break;

    //case 'PlayinAir':
    //dying anims. kinda screwy :P
/*    case 'suicide':
      PlayDying(other,3);
      break;
    case 'decap':
      PlayDying(other,4);
      break;
    case 'dead9r':
      PlayDying(other,5);
      break;
    case 'highdead':
      PlayDying(other,6);
      break;
    case 'type0':
      PlayDying(other,0);
      break;
    case 'type1':
      PlayDying(other,1);
      break;
    case 'type2':
      PlayDying(other,2);
      break;            */
  }
//  if (other.zzisbeta)
 //     log("xxUpdateanims (nextanim) '"$other.nextanim$"' for"@other.playerreplicationinfo.playername@"baseanim is"@other.baseanim@"animseq is"@other.animsequence);

}
other.zznextanim=0; //will play a special when replicated again.
xxBaseRead(other,func,type); //get type (in byte) and name to call from base anim.
TypeRead(func,move,duck); //get info (moving/ducking)
//fake rip off of processmoves for various states!    Run time anim swapper=1337 1337 1337!
if (other.mystate=='playerwalking') //playerpawn.playerwalking.processmove
{
//I know if base is run, walk, wait, turn, crouch, stay duck, or inair.
  if ( (other.baseanim!=0) && (GetmyAnimGroup(other) != 'Dodge') )
    {
    if (getmyanimgroup(other)!='Ducking')    //duck/non duck swaps.
      {
        if (duck==1)
        {
          PlayDuck(other);
        }
      }
      else if (duck==0)
      {
        PlayRunning(other,type,true); //hopefully this'll work. :D
      }

     if (duck==0)     //non-duck moving/non moving swaps
      {
        if ( (!other.bAnimTransition || (other.AnimFrame > 0)) && (GetmyAnimGroup(other) != 'Landing') )
        {
          if ( move==1)
          {
            if ( (GetmyAnimGroup(other) == 'Waiting') || (GetmyAnimGroup(other) == 'Gesture') || (GetmyAnimGroup(other) == 'TakeHit') )
            {
              other.bAnimTransition = true;
              PlayRunning(other,type,true); //hehe, hopefully this works :D
            }
          }
           else if ( (other.Velocity.X * other.Velocity.X + other.Velocity.Y * other.Velocity.Y < 1000)
            && (GetmyAnimGroup(other) != 'Gesture') )
           {
             if ( GetmyAnimGroup(other) == 'Waiting' )
             {
               if ( func=='PlayTurning' && (other.AnimFrame >= 0) )
               {
                 other.bAnimTransition = true;
                 PlayTurning(other);
               }
             }
             else if ( func!='PlayTurning' )
             {
               other.bAnimTransition = true;
               TweenToWaiting(other,0.2);
             }
           }
        }
      }
      else    //duck move/no move swaps.     (animloop may not be best, but oh well...)
      {
        if ( move==1 &&!other.banimloop)
          PlayCrawling(other);
         else if ( move==0 && (other.AnimFrame > 0.1) ) //always tweens?
          PlayDuck(other);
      }
    }
 // else if (other.baseanim=='playinair') //not official, but
  }
//else if (other.mystate!='gameended'&&func=='SwimAnimUpdate')  //update swim!    (remove this?)
  else if (func=='SwimAnimUpdate'){
    swimanimupdate(other,bool(type));  //quite easy, I'll say?
  }
}
///////////////////////////////////////////////////////////////////////////
// Animations.
// These are similar for unreali and tourney.
// Reduces VA file size
///////////////////////////////////////////////////////////////////////////
static function PlayLanded(Alplayer Other, float impactVel)
{
 impactVel = impactVel/Other.JumpZ;
  impactVel = 0.1 * impactVel * impactVel;

  if ( impactVel > 0.17 ){ // may need to use passed sound var here
    if (classischildof(ALPRI(other.playerreplicationinfo).zzmyclass,class'unrealiplayer'))
      Other.PlayOwnedsound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
    else
      Other.PlayOwnedsound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
  }
  if ( !Other.FootRegion.Zone.bWaterZone && (impactVel > 0.01) ) // and here
    Other.PlayOwnedSound(ALPRI(other.playerreplicationinfo).zzmyclass.default.Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
  if ( (impactVel > 0.06) || (GetMyAnimGroup(Other) == 'Jumping') || (GetMyAnimGroup(Other) == 'Ducking') )
  {
    if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
      Other.TweenAnim('LandSMFR', 0.12);
    else
      Other.TweenAnim('LandLGFR', 0.12);
  }
  else if ( !Other.IsAnimating() )
  {
    if ( GetMyAnimGroup(Other) == 'TakeHit' )
    {
   //   if (other.role>role_simulatedproxy)
   //     Other.SetPhysics(PHYS_Walking);
      Other.AnimEnd();
    }
    else
    {
      if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
        Other.TweenAnim('LandSMFR', 0.12);
      else
        Other.TweenAnim('LandLGFR', 0.12);
    }
  }
}

static function PlayFiring(Alplayer other)
{
  // switch animation sequence mid-stream if needed
  if (Other.AnimSequence == 'RunLG')
    Other.AnimSequence = 'RunLGFR';
  else if (Other.AnimSequence == 'RunSM')
    Other.AnimSequence = 'RunSMFR';
  else if (Other.AnimSequence == 'WalkLG')
    Other.AnimSequence = 'WalkLGFR';
  else if (Other.AnimSequence == 'WalkSM')
    Other.AnimSequence = 'WalkSMFR';
  else if ( Other.AnimSequence == 'JumpSMFR')
    Other.TweenAnim('JumpSMFR', 0.03);
  else if ( Other.AnimSequence == 'JumpLGFR')
    Other.TweenAnim('JumpLGFR', 0.03);
  else if ( (GetMyAnimGroup(Other) == 'Waiting') || (GetMyAnimGroup(Other) == 'Gesture')
    && (Other.AnimSequence != 'TreadLG') && (Other.AnimSequence != 'TreadSM') )
  {
    if ( Other.Weapon==none||Other.Weapon.Mass < 20 )
      Other.TweenAnim('StillSMFR', 0.02);
    else
      Other.TweenAnim('StillFRRP', 0.02);
  }
}

static function PlayTurning(Alplayer Other)
{
  if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.PlayAnim('TurnSM', 0.3, 0.3);
  else
    Other.PlayAnim('TurnLG', 0.3, 0.3);
}
static function TweenToWalking(Alplayer Other)
{
  if (other.mesh==none)
    return;
  if (Other.Weapon == None)
    Other.TweenAnim('Walk', 0.1);
  else
  {
    if (Other.Weapon.Mass < 20)
      Other.TweenAnim('WalkSM', 0.1);
    else
      Other.TweenAnim('WalkLG', 0.1);
  }
}
static function TweenToWalkingPoint(Alplayer Other)
{
if (other.mesh==none)
    return;
  if (other.weapon==none||Other.Weapon.Mass < 20)   //first check=?
    Other.TweenAnim('WalkSMFR', 0.1);
  else
    Other.TweenAnim('WalkLGFR', 0.1);
}

static function PlayWalking(Alplayer Other)
{
if (other.mesh==none)
    return;
  if (Other.Weapon == None)
    Other.LoopAnim('Walk');
  else
  {
    if (Other.Weapon.Mass < 20)
      Other.LoopAnim('WalkSM');
    else
      Other.LoopAnim('WalkLG');
  }
}
static function PlayWalkingPoint(Alplayer Other)
{
  if (other.mesh==none)
    return;
    if (other.weapon==none||Other.Weapon.Mass < 20)
      Other.LoopAnim('WalkSMFR');
    else
      Other.LoopAnim('WalkLGFR');
}
static function PlayRising(Alplayer Other)
{
  Other.TweenAnim('DuckWlkS', 0.7);
}
static function PlayFeignDeath(Alplayer Other)
{
  local float decision;
  decision=frand();  //ob1 forgot this :D
  if ( decision < 0.33 )
    Other.TweenAnim('DeathEnd', 0.5);
  else if ( decision < 0.67 ||!other.hasanim('deathend3'))
    Other.TweenAnim('DeathEnd2', 0.5);
  else
    Other.TweenAnim('DeathEnd3', 0.5);
}

static function PlayDuck(Alplayer Other)
{
  if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.TweenAnim('DuckWlkS', 0.25);
  else
    Other.TweenAnim('DuckWlkL', 0.25);
}
static function PlayCrawling(Alplayer Other)
{
  if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.LoopAnim('DuckWlkS');
  else
    Other.LoopAnim('DuckWlkL');
}

static function TweenToWaiting(Alplayer Other, float tweentime)
{
if (other.mesh==none)
    return;
  if ( (Other.IsInState('PlayerSwimming')) || ((other.role==role_autonomousproxy&&Other.Physics == PHYS_Swimming)||(other.role==role_simulatedproxy&&other.region.zone.bwaterzone)) )
  {
    if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
      Other.TweenAnim('TreadSM', tweentime);
    else
      Other.TweenAnim('TreadLG', tweentime);
  }
  else
  {
    if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
      Other.TweenAnim('StillSMFR', tweentime);
    else
      Other.TweenAnim('StillFRRP', tweentime);
  }
}

static function PlayBigWeaponSwitch(Alplayer other){   //calculated by alplayer server-side.
  if ( (Other.AnimSequence == 'RunSM') || (Other.AnimSequence == 'RunSMFR') )
    Other.AnimSequence = 'RunLG';
  else if ( (Other.AnimSequence == 'WalkSM') || (Other.AnimSequence == 'WalkSMFR') )
    Other.AnimSequence = 'WalkLG';
  else if ( Other.AnimSequence == 'JumpSMFR')
    Other.AnimSequence = 'JumpLGFR';
  else if ( Other.AnimSequence == 'DuckWlkL')
    Other.AnimSequence = 'DuckWlkS';
  else if ( Other.AnimSequence == 'StillSMFR')
    Other.AnimSequence = 'StillFRRP';
  else if ( Other.AnimSequence == 'AimDnSm')
    Other.AnimSequence = 'AimDnLg';
  else if ( Other.AnimSequence == 'AimUpSm')
    Other.AnimSequence = 'AimUpLg';
}

static function PlayWeaponSwitch(Alplayer other)
{
    if ( (Other.AnimSequence == 'RunLG') || (Other.AnimSequence == 'RunLGFR') )
      Other.AnimSequence = 'RunSM';
    else if ( (Other.AnimSequence == 'WalkLG') || (Other.AnimSequence == 'WalkLGFR') )
      Other.AnimSequence = 'WalkSM';
     else if ( Other.AnimSequence == 'JumpLGFR')
       Other.AnimSequence = 'JumpSMFR';
    else if ( Other.AnimSequence == 'DuckWlkS')
      Other.AnimSequence = 'DuckWlkL';
     else if (Other.AnimSequence == 'StillFRRP')
       Other.AnimSequence = 'StillSMFR';
    else if ( Other.AnimSequence == 'AimDnLg')
      Other.AnimSequence = 'AimDnSm';
    else if ( Other.AnimSequence == 'AimUpLg')
      Other.AnimSequence = 'AimUpSm';
}

static function PlaySwimming(Alplayer other)
{
  if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.LoopAnim('SwimSM');
  else
    Other.LoopAnim('SwimLG');
}
static function TweenToSwimming(Alplayer other, float tweentime)
{
 if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
    Other.TweenAnim('SwimSM',tweentime);
  else
    Other.TweenAnim('SwimLG',tweentime);
}
//gut hits (all 0.1)
static function PlayGutHit(Alplayer other)
{
  if ( (other.AnimSequence == 'GutHit') || (other.AnimSequence == 'Dead2') )
  {
    if (FRand() < 0.5)
      other.TweenAnim('LeftHit', 0.1);
    else
      other.TweenAnim('RightHit', 0.1);
  }
  else if ( FRand() < 0.6 )
    other.TweenAnim('GutHit', 0.1);
  else
    other.TweenAnim('Dead2', 0.1);

}

static function PlayHeadHit(Alplayer other)
{
  if ( (other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead4') )
    other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    other.TweenAnim('HeadHit', 0.1);
  else
    other.TweenAnim('Dead4', 0.1);
}

static function PlayLeftHit(Alplayer other)
{
  if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead3') )
    other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    other.TweenAnim('LeftHit', 0.1);
  else 
    other.TweenAnim('Dead3', 0.1);
}

static function PlayRightHit(Alplayer other)
{
  if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead5') )
    other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    other.TweenAnim('RightHit', 0.1);
  else
    other.TweenAnim('Dead5', 0.1);
}

defaultproperties
{
}
