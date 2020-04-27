//=============================================================================
// MaleMeshInfo.
//=============================================================================
class MaleMeshInfo extends HumanMeshInfo;

// may need to override PlayDying here to use UnrealShare.Male function
static function PlayDying(Alplayer Other, byte type)
{
  local carcass carc;

  if (type==4)
  {
    Other.PlayAnim('Dead7', 0.7, 0.1);
    return;
  }

  if ( FRand() < 0.15 )
  {
    Other.PlayAnim('Dead2',0.7,0.1);
    return;
  }

  // check for big hit
  if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) && !class'GameInfo'.Default.bVeryLowGore)
  {
    if ( FRand() < 0.5)
    {
      Other.PlayAnim('Dead5',0.7,0.1);
      if ( Other.Level.NetMode != NM_Client )
      {
        carc = Other.Spawn(class'MaleHead',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384) );
        if (carc != None)
        {
          carc.remoterole=role_none;
          carc.Initfor(Other);
          carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
          //PlayerPawn(Other).ViewTarget = carc;
        }
        carc = Other.Spawn(class'CreatureChunks');
        if (carc != None)
        {
          carc.remoterole=role_none;
          carc.Mesh = mesh'CowBody1';
          carc.Initfor(Other);
          carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
        }
        carc = Other.Spawn(class'Arm1',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384) );
        if (carc != None)
        {
          carc.remoterole=role_none;
          carc.Initfor(Other);
          carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
        }
      }
    }
    else
      Other.PlayAnim('Dead1', 0.7, 0.1);
    return;
  }

  // check for head hit
  if ( (type==4 || type==6)
     && !class'GameInfo'.Default.bVeryLowGore )
  {
    Other.PlayAnim('Dead4', 0.7, 0.1);
    carc = other.Spawn(class'MaleHead',,, other.Location + other.CollisionHeight * vect(0,0,0.8), other.Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.remoterole=role_none;
      carc.Initfor(other);
      carc.Velocity = other.Velocity + VSize(other.Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, other.Velocity.Z);
    //  other.ViewTarget = carc; //ok this is a hella stupid idea.
    }
    return;
  }

  if (type==0) //then hit in front or back
    Other.PlayAnim('Dead3', 0.7, 0.1);
  else
  {
    if (type==1)
      Other.PlayAnim('Dead6', 0.7, 0.1);
    else
      Other.PlayAnim('Dead7', 0.7, 0.1);
  }
}

static function PlayGutHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'GutHit') || (Other.AnimSequence == 'Dead2') )
  {
    if (FRand() < 0.5)
      Other.TweenAnim('LeftHit', 0.1);
    else
      Other.TweenAnim('RightHit', 0.1);
  }
  else if ( FRand() < 0.6 )
    Other.TweenAnim('GutHit', 0.1);
  else
    Other.TweenAnim('Dead2', 0.1);

}

static function PlayHeadHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead3') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('HeadHit', 0.1);
  else
    Other.TweenAnim('Dead3', 0.1);
}

static function PlayLeftHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead6') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('LeftHit', 0.1);
  else
    Other.TweenAnim('Dead6', 0.1);
}

static function PlayRightHit(Alplayer Other)
{
  if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead1') )
    Other.TweenAnim('GutHit', 0.1);
  else if ( FRand() < 0.6 )
    Other.TweenAnim('RightHit', 0.1);
  else
    Other.TweenAnim('Dead1', 0.1);
}
/*
//called ONLY if mesh==male1
static function PlaySpecial(ALplayer Other, name Type)
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
  if ( (other.role==role_autonomousproxy&&bIsWalking)||(other.role==role_simulatedproxy&&(other.baseanim=='playwalking'||other.baseanim=='playwalkingpoint') ) )
    other.PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
  else 
    other.PlaySound(step, SLOT_Interact, 1, false, 800.0, 1.0);
}    */
defaultproperties
{
}
