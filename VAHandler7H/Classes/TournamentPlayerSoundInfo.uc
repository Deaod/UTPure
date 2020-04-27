//=============================================================================
// TournamentPlayerSoundInfo.
//=============================================================================
class TournamentPlayerSoundInfo extends DPMSsoundInfo;

static function PlayDyingSound(Alplayer Other)
{
  local int rnd;

  if ( Other.HeadRegion.Zone.bWaterZone )
  {
    if ( FRand() < 0.5 )
      Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit1, SLOT_Pain,16,,,Frand()*0.2+0.9);
    else
      Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit2, SLOT_Pain,16,,,Frand()*0.2+0.9);
    return;
  }

  rnd = Rand(6);
  Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Deaths[rnd], SLOT_Talk, 16);
  Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Deaths[rnd], SLOT_Pain, 16);
}

static function FootStepping(Alplayer Other)
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
    step = class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep1;
  else if (decision < 0.67 )
    step = class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep2;
  else
    step = class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.Footstep3;

  Other.PlaySound(step, SLOT_Interact, 2.2, false, 1000.0, 1.0);
}

static function drown(alplayer other){
other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.drown, SLOT_Pain, 12);
}
static function UWHit(alplayer other){
if ( FRand() < 0.5 )
  Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit1, SLOT_Pain,16,,,Frand()*0.15+0.9);
else
  Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.UWHit2, SLOT_Pain,16,,,Frand()*0.15+0.9);
}
static function hit1(alplayer other){
other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.hitsound1,SLOT_Pain,16,,,Frand()*0.15+0.9);
}
static function Hit23(alplayer other){
if ( FRand() < 0.5 )
      Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);
    else
      Other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);
}
static function hit4(alplayer other){
other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.HitSound4,SLOT_Pain,16,,,Frand()*0.15+0.9);
}

defaultproperties
{
}
