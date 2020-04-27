//=============================================================================
// original DPMS notes:
// DPMSSoundInfo. (release 4 - UT)
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Client-Side Sound handler
// Don't use group names like "PackageName.(all).SoundName" when setting default
// sound properties. Only use the package name followed by the sound name.
// Otherwise the sound properties will not be set properly.
//
//  e.g. sound'PackageName.SoundName'
//
// External sound packages (*.uax) will need to be loaded before the properties
// are set. Use the OBJ LOAD FILE pre-processor command to do this.
//
// #exec OBJ LOAD FILE=<path to package> PACKAGE=<package name>
//
// Massively edited UsAar33:
// all sounds are now read from the ALPRI(other.playerreplicationinfo).zzmyclass
// only two subclasses: unreali and tournament, due to this fact.
// REMOVE FINALS WHEN CUSTOM MESH STUFF IS IMPLAMENTED!
//=============================================================================
class DPMSSoundInfo extends Info;

//=============================================================================
// Static Sound Playing functions

static function PlayDyingSound(ALplayer Other);
static function PlayFootStep(ALplayer Other);
static function FootStepping(ALplayer Other);
//hit sounds (sent more specific, as damage related which is unknown to clients)
static function drown(ALplayer other);
static function UWHit(ALplayer other);
static function Hit1(ALplayer other);
static function Hit23(ALplayer other);
static function Hit4(ALplayer other);

static function Gasp(ALplayer Other){
other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.GaspSound, SLOT_Talk, 2.0);
}
static function breathagain(ALplayer other){
other.PlaySound(class<tournamentplayer>(ALPRI(other.playerreplicationinfo).zzmyclass).default.BreathAgain, SLOT_Talk, 2.0);
}
// can used to play sounds or call other sound functions
static function PlaySpecial(ALplayer Other, name Type);
// from Engine.PlayerPawn (UT v4.02)
static final function PlayerLanded(ALplayer Other)
{
Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.Land, SLOT_Interact, 0.3, false, 800, 1.0);
}

static final function DoJump(ALplayer Other)
{
 Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
}
static final function DodgeSound(ALplayer Other)
{
 Other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
}
// From Engine.Pawn
static final function FootZoneChange(ALplayer Other)
{
//maybe poorly implemented but oh well:
other.PlaySound(ALPRI(other.playerreplicationinfo).zzmyclass.default.WaterStep, SLOT_Misc, 1.5 + 0.5 * FClamp(0.000025 * other.mass * (300 - 0.5 * FMax(-500, other.Velocity.Z)), 1.0, 4.0 ));
}


defaultproperties
{
}
