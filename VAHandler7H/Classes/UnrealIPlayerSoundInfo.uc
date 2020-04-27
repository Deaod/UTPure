//=============================================================================
// UnrealIPlayerSoundInfo.
//=============================================================================
class UnrealIPlayerSoundInfo extends DPMSsoundInfo;

// from UnrealShare.UnrealiPlayer (UT v4.02)
static function PlayDyingSound(Alplayer Other)
{
  local float rnd;

  if ( Other.HeadRegion.Zone.bWaterZone )
  {
    if ( FRand() < 0.5 )
      Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
    else
      Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
    return;
  }

  rnd = FRand();
  if (rnd < 0.25)
    Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.Die, SLOT_Talk);
  else if (rnd < 0.5)
    Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Die2, SLOT_Talk);
  else if (rnd < 0.75)
    Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Die3, SLOT_Talk);
  else
    Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Die4, SLOT_Talk);
}

//QUESTION: use tournament volumes or unrealiplayer?  Set at unrealiplayer.
static function drown(alplayer other){
other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.drown, SLOT_Pain, 1.5);
}
static function UWHit(alplayer other){
if ( FRand() < 0.5 )
      Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
    else
      Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}
static function hit1(alplayer other){
other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.hitsound1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}
static function Hit23(alplayer other){
if ( FRand() < 0.5 )
      Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.HitSound2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
    else
      Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.HitSound3, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}
static function hit4(alplayer other){
other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.HitSound4, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}

static function FootStepping(Alplayer Other)
{
  PlayFootStep(Other);
}

static function PlayFootStep(Alplayer Other)
{
  local sound step;
  local float decision;

  if ( Other.FootRegion.Zone.bWaterZone )
  {
    Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  decision = FRand();
  if ( decision < 0.34 )
    step = class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep1;
  else if (decision < 0.67 )
    step = class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep2;
  else
    step = class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep3;

if ( (other.role==role_autonomousproxy&&other.bIsWalking)||(other.role==role_simulatedproxy&&(other.baseanim==11||other.baseanim==12) ) )
    Other.PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
  else
    Other.PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

//SPECIAL:
static function PlaySpecial(Alplayer Other, name Type)
{
switch(Type)
  {
    case 'WalkStep':
      WalkStep(Other);
      break;
    case 'RunStep':
      RunStep(Other);
      break;
    case 'metalstep':
      PlayMetalStep(Other);
      break;
  }
}

static function PlayMetalStep(Alplayer Other)  //for male 1
{
  local sound step;
  local float decision;

  if ( other.FootRegion.Zone.bWaterZone )
  {
    other.PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  decision = FRand();
  if ( decision < 0.34 )
    step = sound'MetWalk1';
  else if (decision < 0.67 )
    step = sound'MetWalk2';
  else
    step = sound'MetWalk3';
  //check autonomous walk or sim walk.
  if ( (other.role==role_autonomousproxy&&other.bIsWalking)||(other.role==role_simulatedproxy&&(other.baseanim==11||other.baseanim==12) ) )
    other.PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
  else 
    other.PlaySound(step, SLOT_Interact, 1, false, 800.0, 1.0);
}
// sound functions for sktrooper
static function WalkStep(Alplayer Other)
{
  local sound step;
  local float decision;

   if ( Other.FootRegion.Zone.bWaterZone )
  {
    Other.PlaySound(sound'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep1, SLOT_Interact, 0.1, false, 800.0, 1.0);
}

static function RunStep(Alplayer Other)
{
  local sound step;
  local float decision;

  if ( Other.FootRegion.Zone.bWaterZone )
  {
    Other.PlaySound(sound'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  Other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep1, SLOT_Interact, 0.7, false, 800.0, 1.0);
}
static function Gasp(ALplayer Other){
other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.GaspSound, SLOT_Talk, 2.0);
}
static function breathagain(ALplayer other){
other.PlaySound(class<unrealiplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.BreathAgain, SLOT_Talk, 2.0);
}
defaultproperties
{

}
