// ============================================================
// VAbeta.CrashMeshInfo: For X3M's CRASH conversion
// exactly the same as visor but must be a touney female
// ============================================================

class CrashMeshInfo expands TournamentFemaleMeshInfo;

static function PlayDodgeB(Alplayer other)   //backflip!
{
  Other.PlayAnim('backFlip', 1.35 * FMax(0.35, other.Region.Zone.ZoneGravity.Z/other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}
//force flip!
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
    else /*if ( Dir dot X > 0 )
      Other.TweenAnim('DodgeF', 0.35);
    else
      Other.TweenAnim('DodgeB', 0.35);*/
    f=2.0;
    if (f!=2.0){
    Other.bLastJumpAlt = true;
    return;     }
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
  else if ( Other.AnimSequence == 'BackRun'|| other.AnimSequence == 'pBackRun')
    Other.PlayAnim('backFlip', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
  else   //force flip
    Other.PlayAnim('Flip', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}
//running to allow light weapon stuff:
static function PlayRunning(ALplayer Other,byte type,bool tween)   //quite important.  tweens always called at 0.1
{
  local name sequence; //what will be played.
  // determine facing direction
   if (type==2){  //Backrun for heavy or light
    if (other.Weapon==none||other.Weapon.Mass < 20)
      sequence='Pbackrun';
    else
      sequence='BackRun';
   }
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

defaultproperties {
}
