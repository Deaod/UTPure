// ============================================================
// allmodel.ALcarcass: advanced carcass.
// Allows something of an animation swap as well as mesh/skin stuff.
// unreali players get a different one for animation stuff....
// also note that masterreplacement is spawned client-side.
// Bjerking MUST be set server-side, for no server-side animations :P
// ============================================================

class ALcarcass expands UTHumanCarcass;

var float LastHit, Oldlasthit;
var bool bJerking;
var name Jerks[4];
var ALPRI PRI; //PRI used for skins, among other thingz.
//Dying types:
//0 (type0):
//1 (type1):
//2 (type2): Various unreal loc tests
//3 (suicide): Suicide
//4 (decap): Decapitation
//5 (dead9r): Repeater Death
//6 (highdead): Upper body hit
var byte zzdeathanim;
var vector zzmyloc; //replicated on cylinder reduction
var bool zzinitialized;
//var bool zzbchunked;  //used to determine if client shall hide carcass.

replication
{
  // Things the server should send to the client.
  reliable if( Role==ROLE_Authority )
    LastHit, bJerking, PRI, zzMyLoc;
  reliable if (Role==ROLE_Authority && bNetInitial)      //only first rep
    zzDeathAnim;
}

//this function initializes the carcass based on the PRI.
simulated function xxInit()
{
  local int i;
  local float rand;
//  if (class'alplayer'.default.zzisbeta)
//    log (self@"received! zzdeathanim is"@zzdeathanim@"and PRI is "@PRI.playername);
  zzInitialized=true;
  PlayerOwner=PRI;     //gibz
  
  if (zzDeathAnim == 0)  //gibbed so hide
  {
    bHidden=true;
    return;
  }
  
  for ( i=0; i<8; i++ )
  {
    Multiskins[i] = PRI.MultiSkins[i];
  
    if (multiskins[i]!=none)
      multiskins[i].lodset=lodset_skin;
  }
  
  oldlasthit=lasthit + level.timeseconds;
  
  Mesh = PRI.zzmyclass.default.Mesh;
  Skin = PRI.Skin;
  
  if (skin!=none)
    skin.lodset=lodset_skin;
  
  Texture = PRI.Texture;
  DrawScale = PRI.DrawScale;
  
//  if (zzdeathanim==9) //prevent jerking on new rep carz
 //   bjerking=false;
 
  if (string(PRI.zzmyclass)~="unreali.skaarjplayer")  //go for some other death animation.
  {
    AnimSequence = 'Death2';
    AnimFrame = 0.92;
    SimAnim.X = 9200;
  }
  
  if (HasAnim('deathend'))
  {
    rand=frand();
    if (rand<0.33 || !HasAnim('deathend2'))
      PlayAnim('deathend');
    else if (rand<0.66||!HasAnim('deathend3'))
      PlayAnim('deathend2');
    else
      playAnim('deathend3');
  }
  else //retarded cowmesh!!!!!!
    PlayAnim('Dead2',60, 0.01);
  
  if ( class'Gameinfo'.default.bVeryLowGore )
    bGreenBlood = true;
}

//set by temp actor. Designed to ensure death anim only played when killed.
simulated function SetDeathAnim()
{ 
  if (PRI.Owner == None)
    return;
  
  //try reading from current animations..
  if (PRI.Owner.role == ROLE_SimulatedProxy) //simulated proxies need death anim forced like this.
    ALplayer(PRI.Owner).meshinfo.static.PlayDying(ALplayer(PRI.Owner), zzDeathAnim-1);
  
  AnimSequence = PRI.Owner.AnimSequence;
  AnimFrame = PRI.Owner.AnimFrame;
  AnimRate = PRI.Owner.AnimRate;
  TweenRate = PRI.Owner.TweenRate;
  AnimMinRate = PRI.Owner.AnimMinRate;
  AnimLast = PRI.Owner.AnimLast;
  bAnimLoop = PRI.Owner.bAnimLoop;
  SimAnim.X = 10000 * AnimFrame;
  SimAnim.Y = 5000 * AnimRate;
  SimAnim.Z = 1000 * TweenRate;
  SimAnim.W = 10000 * AnimLast;
  bAnimFinished = PRI.Owner.bAnimFinished;
}

//edited from uthumancarcass:
function Initfor(actor Other)  //custom to allow skins/meshes/anims/sounds of myclass.
{     //commented out=on client stuff.
  //local int i;
  local rotator carcRotation;
  
  PlayerOwner = Pawn(Other).PlayerReplicationInfo;
  PRI=ALPRI(PlayerOwner);  //the PRI replicated and limited to ALPRI
//  log ("Server init for"@PRI.playername@"on carcass:"@self);
  bReducedHeight = false;
  PrePivot = vect(0,0,3);
  
  if ( bDecorative )
  {
    DeathZone = Region.Zone;
    DeathZone.NumCarcasses++;
  }
  bDecorative = false;
  bMeshCurvy = Other.bMeshCurvy;  
  bMeshEnviroMap = Other.bMeshEnviroMap;  
  Fatness = Other.Fatness;
  
  SetCollisionSize(Other.CollisionRadius + 4, Other.CollisionHeight);
  
  if ( !SetLocation(Location) )
    SetCollisionSize(CollisionRadius - 4, CollisionHeight);

  DesiredRotation = other.Rotation;
  DesiredRotation.Roll = 0;
  DesiredRotation.Pitch = 0;
  Velocity = other.Velocity;
  Mass = Other.Mass;
  
  if ( Buoyancy < 0.8 * Mass )
    Buoyancy = 0.9 * Mass;
}


//from subclasses of uthumancarcass:
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, name DamageType)
{  
  local bool bRiddled;
  
  if ( bJerking)
  {
    bJerking = true;
    if ( Damage < 23 )
      LastHit = Level.TimeSeconds;
    else 
      bJerking = false;
  }
  Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

  if ( bJerking )
  {
    CumulativeDamage = 50;
    Velocity.Z = FMax(Velocity.Z, 40);
    if ( InstigatedBy == None )
      bJerking = false;
  }
  if ( bJerking && (VSize(InstigatedBy.Location - Location) < 150)
    && (InstigatedBy.Acceleration != vect(0,0,0))
    && ((Normal(InstigatedBy.Velocity) Dot Normal(Location - InstigatedBy.Location)) > 0.7) )
    bJerking = false;
}

//al-setup.
function xxsetanim(byte zzAnim)
{ 
  local vagibber zzgib;
  
  zzDeathAnim=zzAnim+1;
  bJerking=(zzAnim == 5);
  LastHit=Level.TimeSeconds;
  zzGib=Spawn(class'vagibber'); //client-animation setter.
  zzGib.zzMyCarc=self;
}

//simulated functions:
simulated function tick(float delta)  //this is the client-side masterchunk spawning
{
  if (Level.NetMode!=NM_Client)
  {
    Disable('tick');
//  bjerking=(zzdeathanim==6);    //set bool. (note anim is +1)
    return;
  }
  
  if (!zzinitialized && PRI != none) //better than postbeginplay
    xxInit();
  
  if (zzMyLoc != vect(0,0,0))  //exact location
  {
    setlocation(zzmyloc);
    zzmyloc=vect(0,0,0);
  }
}

simulated function ClientChunk() //called by gibber
{
local UTMasterCreatureChunk carc;
local MasterCreatureChunk oldCarc;
local class<MasterCreatureChunk> oldCarcClass;
local UT_BloodBurst b;

//  log (self@"chunking");
  GotoState('ClientGibbing'); //will goto here when done! (soundz)
  
  bhidden=true; //ensure owner can't see :D
  b = Spawn(class'UT_BigBloodHit',,,Location, rot(-16384,0,0));
  
  if ( bGreenBlood )
    b.GreenBlood();
      
  SetCollision(false,false,false); //just in case?
  Disable('tick');  //stops carcasses from being spawned again
  if (class'GameInfo'.Default.bLowGore ) //do not spawn in low gore mode.
    return;
  if (ClassIsChildOf(PRI.zzMyClass, class'unrealiplayer'))
  {
    if (String(PRI.zzMyClass) ~= "unreali.skaarjplayer") //skaarj check
      oldCarcClass=class'TrooperMasterChunk';
    else
      oldCarcClass=class<MasterCreatureChunk>(class<HumanCarcass>(PRI.zzMyClass.default.CarcassType).default.MasterReplacement);
    
    oldCarcClass.default.bMasterChunk=false; //else bad postbeginplay()
    oldCarc = Spawn(oldCarcClass,,, Location + CollisionHeight * vect(0,0,0.5));
    oldCarcClass.default.bMasterChunk=true; //reset
  
    if (oldCarc != None)
    {
      oldCarc.remoterole=role_none; //always on client.
      oldCarc.bMasterChunk = true;
      oldCarc.PlayerRep = PRI;
      oldCarc.bGreenBlood=bGreenBlood;
      oldCarc.Initfor(self);
      oldCarc.bMasterChunk=false; //stop timer.
    }
  }
  else   //normal kind.
  {
    Carc = Spawn(class<UTHumanCarcass>(PRI.zzmyclass.default.carcasstype).default.masterreplacement,,, Location + CollisionHeight * vect(0,0,0.5));
    if (Carc != None)
    {
      Carc.remoterole=role_none;
      Carc.PlayerRep = PRI;
      Carc.Initfor(self);
      Carc.disable('Tick'); //chunk immediately.
      Carc.ClientExtraChunks();
//      if (class'alplayer'.default.zzisbeta)
       // log ("gib carcass spawned!");
    }
  }
}

//now sets a var, rather than..
function ChunkUp(int Damage) 
{
  local VAGibber zzGib;
  
  if ( bPermanent )
    return;
  
  if ( Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
  {
    if ( Bugs != None )
      Bugs.Destroy();
  }
 // else                    now client's job!
 //   CreateReplacement();
 
  zzDeathAnim=0; //gib flag
//  SetPhysics(PHYS_None);
//  if (Physics==PHYS_None)
 
  setphysics(PHYS_Rotating); //HACK! HACK! HACK!
//  bHidden = true;
//  bOnlyOwnerSee=true; //we want it to still replicate.
//  zzbchunked=true;
  zzGib=spawn(class'vagibber');
  zzGib.zzMyCarc=self;
  zzGib.zzbGib=true;
  
  //drawtype=dt_none;
  SetCollision(false,false,false);
  bProjTarget = false;
  Disable('tick');
  GotoState('Gibbing');
}

//REWRITE JERK SYSTEM SO SERVER IS SOLE AUTHORITY ON JERK DECISIONS!
simulated function AnimEnd()   
{
  local name NewAnim;
  local bool checkjerk;
  local int zzi;
  
  if (role==role_authority) //never do this on server!
    return;
  
  if (!bjerking) //will undo....
  {
    CheckJerk=(AnimSequence=='dead9');
    if (!CheckJerk)
    {
      for(zzi=0; zzi < 4; zzi++)
    {
        if (AnimSequence == Jerks[zzi])
        {
          CheckJerk=true;
          break;
        }
      }
    }
  }
  
  if ( !bJerking && !CheckJerk )
  {
    if ( Physics == PHYS_None )   //super as sim
      LieStill();
    else if ( Region.Zone.bWaterZone )
    {
      bThumped = true;
      LieStill();
    }
  }
  else if ( CheckJerk && (LastHit + Level.TimeSeconds - OldLastHit < 0.25)/*(Level.TimeSeconds - LastHit+PRI.zzlocalplayer.playerreplicationinfo.starttime < 0.2)*/ && (FRand() > 0.02) ) //checks exact level.timeseconds for jerking.
  {
    OldLasthit=LastHit;
    NewAnim = Jerks[Rand(4)];
    if ( NewAnim == AnimSequence )
    {
      if ( NewAnim == Jerks[0] )
        NewAnim = Jerks[1];
      else
        NewAnim = Jerks[0];
    }
    TweenAnim(NewAnim, 0.15);
  }
  else
  {
    bJerking = false;
    if (hasanim('dead9b')) //some models had this problem :(
      PlayAnim('Dead9B', 1.1, 0.1);
  }
}

//Spawn head would go here, but never seems to be called
/*simulated */ function ReduceCylinder()   //hacked to fix prepivot. probably a VERY bad way to go, but oh well.....
{
  local float OldHeight;
  local Vector OldLocation;

  if (Role==ROLE_SimulatedProxy)
    return;
  
  //RemoteRole=ROLE_DumbProxy;
  bReducedHeight = true;
//  if (role==role_authority){ //collision is replicated so only affect server.
  SetCollision(bCollideActors,False,False);
  OldHeight = CollisionHeight;
  
  if ( ReducedHeightFactor < Default.ReducedHeightFactor )
    SetCollisionSize(CollisionRadius, CollisionHeight * ReducedHeightFactor);
  else
    SetCollisionSize(CollisionRadius + 4, CollisionHeight * ReducedHeightFactor);
  
  PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight);
//  }
  //loc is not replicated so this, so parse this.
  OldLocation = Location;
  if ( !SetLocation(OldLocation - PrePivot) )
  {
    SetCollisionSize(CollisionRadius - 4, CollisionHeight);
    if ( !SetLocation(OldLocation - PrePivot) )
    {
      SetCollisionSize(CollisionRadius, OldHeight);
      SetCollision(false, false, false);
      PrePivot = vect(0,0,0);
      if ( !SetLocation(OldLocation) )
        ChunkUp(200);
    }
  }
  zzMyLoc=Location; //will replicate to client.
  PrePivot = PrePivot + vect(0,0,3);
  Mass = Mass * 0.8;
  Buoyancy = Buoyancy * 0.8;
  //kill later:
  //log ("Alcarcass cylinder reduced at"@level.timeseconds@"Location="$location@"and prepivot="$prepivot);
}

simulated function LieStill()
{
  if (role!=role_authority)
  {
    SimAnim.X = 10000 * AnimFrame;
    SimAnim.Y = 5000 * AnimRate;
  }
  
  if ( !bThumped && !bDecorative )
    LandThump();
  
  if ( !bReducedHeight )
    ReduceCylinder();
}
/*
simulated function Landed(vector HitNormal)
{
super.landed(hitnormal);
if (role==role_authority)
  liestill();
}   */

state Gibbing       //allows more destruction time to ensure client has chunked. also no sound is played.
{
  ignores Landed, HitWall, AnimEnd, TakeDamage, ZoneChange;
  
  function tick(float delta) //view-target: destroy check
  {
    if (playerpawn(PRI.owner).viewtarget!=self)
      destroy(); //no longer needed at all
  }
  
  function BeginState()
  {
    disable('tick');
  }

Begin:
 Sleep (1.5);
 SetPhysics(phys_none); //undo hack
 Sleep(3.0);
 Enable('tick');
 if ( !bPlayerCarcass )
    Destroy();
}

Simulated State ClientGibbing   //sim state for sound client-side
{
  ignores Landed, HitWall, AnimEnd, TakeDamage, ZoneChange;
  
  simulated function GibSound() //full overload to do sim stuff.
  {
  local int r;
  
    r = Rand(4);
  
//  if (string(class<uthumancarcass>(PRI.zzmyclass.default.carcasstype)~="Botpack.Tbosscarcass") //swap if boss.
 //   GibSounds[1]=Sound'botpack.BNewGib';
 
    Gibsounds[r]=class<uthumancarcass>(PRI.zzmyclass.default.carcasstype).default.Gibsounds[r]; //1337 swap.
    PlaySound(GibSounds[r], SLOT_Interact, 16);
    PlaySound(GibSounds[r], SLOT_Misc, 12);
  }
  
Begin:
  if (classischildof(PRI.zzmyclass,class'unrealiplayer'))
  {
    Sleep(0.2);
    UIGibSound();
  }
  else
  {
    Sleep(0.25);
    GibSound();
  }
}

//gib soundz
simulated function UIGibSound()
{
  local float decision;

  decision = FRand();
  if (decision < 0.2)
  {
    PlaySound(sound'Gib1', SLOT_Interact, 0.06 * Mass);
    PlaySound(sound'Gib1', SLOT_Misc, 0.045 * Mass);
  }
  else if ( decision < 0.35 )
  {
    PlaySound(sound'Gib2', SLOT_Interact, 0.06 * Mass);
    PlaySound(sound'Gib2', SLOT_Misc, 0.045 * Mass);
  }
  else if ( decision < 0.5 )
  {
    PlaySound(sound'Gib3', SLOT_Interact, 0.06 * Mass);
    PlaySound(sound'Gib3', SLOT_Misc, 0.045 * Mass);
  }
  else if ( decision < 0.8 )
  {
    PlaySound(sound'Gib4', SLOT_Interact, 0.06 * Mass);
    PlaySound(sound'Gib4', SLOT_Misc, 0.045 * Mass);
  }
  else
  {
    PlaySound(sound'Gib5', SLOT_Interact, 0.06 * Mass);
    PlaySound(sound'Gib5', SLOT_Misc, 0.045 * Mass);
  }
}

defaultproperties
{
     Jerks(0)=GutHit
     Jerks(1)=HeadHit
     Jerks(2)=LeftHit
     Jerks(3)=RightHit
     MasterReplacement=Class'botpack.TMaleMasterChunk'
     AnimSequence=Dead1
     bBlockActors=True
     bBlockPlayers=True
     Mesh=LodMesh'botpack.Commando'
     Mass=100.000000
     AnimFrame=0.000000
     LifeSpan=0.000000
}
