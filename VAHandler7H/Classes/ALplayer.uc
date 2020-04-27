// ============================================================
// allmodel.ALplayer: The main player.  VERY important and complex
// UsAaR33 whines.  soooo many lines of code....
// ============================================================

// 5w
// Changed: Commented out the VAPure Teleport code for PlayerWaiting/PlayerSpectating States.

class ALplayer expands bbPlayer;

//SKIN MODEL RELATED
/* //moved this data into the custom PRI, in order for talktexture to load as well a working carcass.
var string skinstring; //REPLICATED: this is skin occording to URL
var string facestring; //REPLICATED: this is the face occording to URL
var string lastskin, lastface; //checks if the other two have changed.
var string ClassString; //REPLICATED: this is the class.
var class<playerpawn> myclass; //loaded on each client.  This is the class that we "want" to use.  static functions (skin) are called and defaults read from it.*/
//var float lastsoundtimer, lastanimtimer; //server sets nextsound/next anim to null next tick.  I'm too lazy to figure out every event order, so I use this hack

var float lastgesturetime; //for gesture timerz.

//Animation specials. These are non-looping anims, such as deaths, taunts and hits:
//var name nextanim; //REPLICATED: the next animation function that will be called.   only for specials.

var byte zzNextAnim; //see above

//var name lastanim; //new anim check

//var name BaseAnim; //the base looping animation. Special's revert to these at client animend. Ex: walk, run, crouch
//Baseanims:
// 0=playinair
// Waiting:
// 1=PlayWaiting
// 2=aimup
// 3=aimdown
// 4=playrapid
// 5=PlayWeapPoint
// Running:
// 6=PlayRunning
// 7=PlayRunningPoint
// 8=BackRun
// 9=StrafeR
// 10=StrafeL
// Simple ones:
// 11=playwalking
// 12=playwalkingpoint
// 13=PlayTurning
// 14=PlayChatting
// 15=playduck
// 16=PlayCrawling
// Swimming updates:
// 17=SwimAnimUpdate (moving)
// 18=SwimAnimUpdateNotF (tread)

var byte BaseAnim; //used as a byte because s3 does not like names :P
//var byte lastteam;  //see if new team and need to set to skin
var bool bAnimOn; //hack for isanimating() server-side.
var name myState; //REPLICATED: this is the state that is on server. used for animation purposes.
//var bool zzisbeta;  //beta flag
//var float logtimer;
//DPMS stuff:  Unlike in normal DPMS, this stuff is loaded by clients.
var class<DPMSMeshInfo> MeshInfo;  //we use this for animation types.
var class<DPMSSoundInfo> SoundInfo; //the only ones that exist are unreali or tournamentplayer. all sounds read by defaults of myclass.
var byte zzPendingDeath; //deathanim to give carcass

//animend hacking (it is not called on simpawns)
var name LastAnim;
var float LastAFrame;
var Teleporter zzLastTP;        // Used to allow teleportation in spectator mode

//changing playersetup window:
var() class<UWindowWindow> PlayerSetupWindowClass;
var bool bMenuClassSetup, bmsg; //swapped menu set?
var bool zzNoOverride;     //prevent over-rides.
var bool Initialized;

/*var enum ESoundFunction   //enumeration for sounds. the next sound the pawn will play.
{
  Sound_None,  //no sound to play right now.
  Sound_Gasp,
  Sound_Breathagain,
  Sound_DoJump,
  Sound_PlayDyingSound,
  Sound_FootZoneChange,
  Sound_PlayerLanded,
  Sound_Drown,
  Sound_UWHit,
  Sound_Hit1,
  Sound_Hit23,
  Sound_Hit4,
  Sound_DodgeSound
} NextSound;
*/

var byte zzNextSound; //5 bits actual sound info. 3 bits a counter.  see above for sound order.

//looks kinda scary, but most are rarely updated.  except for nextsound and nextanim.  in the long run,
//it may result in bandwith saved, as no clienthearsound replicated function or 4 anim related vars exist.
replication
{
 // reliable if (role==role_authority)
   // skinstring,facestring,classstring;
//anims and sounds are played locally for autonomous (local player)
//they must be replicated for server-side demos on auto proxies, but not on local client demos (anims are sent, which sux in some ways)
  reliable if (remoterole==ROLE_simulatedproxy||(bdemorecording&&!bclientdemorecording))
    zzNextSound, zzNextAnim, myState, BaseAnim;
  
  reliable if (bNetOwner && Role==ROLE_Authority &&!bdemorecording) //Only for local player. not in demos either.
    zzNoOverride;
  
  reliable if (role < ROLE_Authority)   //functions client can call to server.
    xxServerSetVPString, xxSetMeshClass, xxServerTaunt;    //set VP as string.
}

//////////////////////////////////////////////////////////
// xxServerSound and xxServerAnim
// Critical animation and sound encoders
//////////////////////////////////////////////////////////
//important serversound compressor.
//if counter byte==7, then the rest is approximate veloc.
function xxServerSound(byte zzid)
{
local byte zzCurTime;

  zzCurTime=(zzNextSound >> 5);
  
  if (zzCurTime == 7)
    zzCurTime = -1;
  
  zzNextSound = zzid;
  zzNextSound += (zzCurTime + 1) << 5; //compressed this way.
}

//slightly different. counter is only 2 bytes, while ID's allow 5.
// 7th byte is used for landing, where velocity is needed. Set outside of this function.
function xxServerAnim(byte zzid)
{
local byte zzCurTime;

  zzCurTime=(zzNextAnim >> 5) & 3;  //ensure no extra info.
  
  if (zzCurTime == 3)
    zzCurTime=-1;
  
  zzNextAnim = zzid;
  zzNextAnim += (zzCurTime + 1) << 5; //compressed this way.
}

//not so DPPMS :D
//this function takes a name in next sound and plays it via the sound info
simulated function xxSetSounds()
{
//if (zzisbeta)
//  log("Sound processor:"@getenum(enum'ESoundFunction',nextsound));
//if (zzNextSound >>> 7==7){ //landed

  zzNextSound=zzNextSound&31; //read only 5 bits
  
  switch (zzNextSound)
  {
  //case Sound_gasp:
  case 1:
    SoundInfo.static.gasp(self);
    break;
  //case Sound_breathagain:
  case 2:
    SoundInfo.static.breathagain(self);
    break;
  //case Sound_dojump:
  case 3:
    SoundInfo.static.dojump(self);
    break;
  //case Sound_playdyingsound:
  case 4:
    SoundInfo.static.playdyingsound(self);
    break;
  //case Sound_footzonechange:
  case 5:
    SoundInfo.static.footzonechange(self);
    break;
  //case Sound_playerlanded:
  case 6:
    SoundInfo.static.playerlanded(self);
    break;
  //case Sound_drown:
  case 7:
    SoundInfo.static.drown(self);
    break;
  //case Sound_uwhit:
  case 8:
    SoundInfo.static.UWHit(self);
    break;
  //case Sound_hit1:
  case 9:
    SoundInfo.static.Hit1(self);
    break;
  //case Sound_hit23:
  case 10:
    SoundInfo.static.hit23(self);
    break;
  //case Sound_hit4:
  case 11:
    SoundInfo.static.hit4(self);
    break;
  //case Sound_dodgesound:
  case 12:
    soundinfo.static.dodgesound(self);
    break;
  }
//nextsound=Sound_None; //so a new sound entering can be detected
  zzNextSound=0;
}

exec function ChangeMyTeam( int N ) //now executable.  :D
{
  changeteam(n);
}

/////////////////////////////////////////
// xxGetMeshinfo
// Get the mesh info for the mesh we use
////////////////////////////////////////
simulated final function class<DPMSMeshInfo> xxGetMeshInfo()
{
local class<playerpawn> zzMyClass;

  if (left(mesh,14)~="SkeletalChars.")    //BP 4
    return class'AMSMeshInfo';
  
  if (string(mesh)~="unreali.sktrooper")
    return class'skaarjplayermeshinfo';

  zzMyClass=ALPRI(playerreplicationinfo).zzmyclass;
  
  if (classischildof(zzmyclass,class'unrealiplayer'))
  {
    if (bisfemale)
      return class'HumanMeshInfo';
    
    return class'MaleMeshInfo';
  }
  
  if (class<tournamentplayer>(zzmyclass).default.FixedSkin==213) //AMS
    return class'AMSMeshInfo';
  
  if (string(mesh)~="visor.visor")
    return class'VisorMeshInfo';
  
  if (string(mesh)~="crash.crash")
    return class'CrashMeshInfo';
  
  if (string(mesh)~="EpicCustomModels.TCowMesh")
    return class'CowMeshInfo';
  
  if (string(mesh)~="EpicCustomModels.tnalimesh")
    return class'NaliMeshInfo';
  
  if (string(mesh)~="EpicCustomModels.TSkM")
    return class'TSkaarjMeshInfo';
  
  if (hasanim('Duckuplgfr')) //HL flag :D
    return class'HLMeshInfo';
  
//MOVE AMS STUFF HERE AND IMPLAMENT DYNAMICALLY LOADING VAPLAYERS FOR FULL
  if (zzmyclass.default.CarcassType==Class'botpack.TBossCarcass')
    return class'TBossMeshInfo';
  
  if (bisFemale)
    return class'TournamentFemaleMeshInfo';
  
  return class'TournamentMaleMeshInfo';
}

/*
//oldskool semi-HOOK:
function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
  if (player!=none&&windowconsole(player.console).root!=none&&(windowconsole(player.console).root.isa('oldskoolrootwindow')||windowconsole(player.console).root.isa('EnhancedUT_RootWindow'))&&windowconsole(player.console).root.getpropertytext("force")~="true")
  return;  //this way song will not be changed if forced!
  Song        = NewSong;
  SongSection = NewSection;
  CdTrack     = NewCdTrack;
  Transition  = NewTransition;
}     */

event UpdateEyeHeight(float DeltaTime) //lets local playerpawns still tick   why not playertick? too lazy to overwrite every tick()...
{
  super.UpdateEyeHeight(deltatime);
  tick(deltatime);
}

// called when playerreplicationinfo!=none first time
simulated event Init()
{
  local int i;
  /*if ( bIsMultiSkinned )
  {
    if ( MultiSkins[1] == None )
    {
      if ( bIsPlayer )
        SetMultiSkin(self, "","", PlayerReplicationInfo.team);
      else
        SetMultiSkin(self, "","", 0);
    }
  }
  else if ( Skin == None )
    Skin = Default.Skin;
              */
  Initialized=true; //flag
  //in case server is replicating this, switch off:
  zzNextSound=0;
  
  if ( PlayerReplicationInfo != None)
  {
    if (PlayerReplicationInfo.Owner == None)
      PlayerReplicationInfo.SetOwner(self);
    
    bIsFemale = PlayerReplicationInfo.bIsFemale;
    SkelAnim=None;
  
  //  if (mesh!=none) //requires a mesh before setting!
    Mesh = ALpri(PlayerReplicationInfo).zzMyClass.default.Mesh;
   // meshinfo=class'dpmsmeshinfo';
   
    for (i=0;i<8;i++)
  {
      MultiSkins[i] = PlayerReplicationInfo.MultiSkins[i];
      if (MultiSkins[i] != None)
        MultiSkins[i].LodSet = LodSet_Skin;
    }
  
    Skin = PlayerReplicationInfo.Skin;
    if (Skin != None)
      Skin.LodSet = LodSet_Skin;
    
    DrawScale = PlayerReplicationInfo.DrawScale;
    PrePivot=PlayerReplicationInfo.PrePivot;
  
    if (ClassIsChildOf(ALpri(PlayerReplicationInfo).zzMyClass, class'TournamentPlayer'))
  {
      StatusDoll = class<tournamentplayer>(alpri(PlayerReplicationInfo).zzmyclass).default.statusdoll;
      StatusBelt = class<tournamentplayer>(alpri(PlayerReplicationInfo).zzmyclass).default.statusbelt;
    }
    else if (ALpri(PlayerReplicationInfo).zzMyClass.default.bIsFemale) //get the female doll
  {
      StatusDoll=Texture'botpack.Icons.Woman';
      StatusBelt=Texture'botpack.Icons.WomanBelt';
    }
  }
}

//master tick.  called by engine on sim proxies.  updateeyeheight routes to this.
simulated function tick(float delta)
{
//  logtimer+=delta;
//  if (zzisbeta&&logtimer>5){
//    logtimer=0;
//    log(self@"with"@string(mesh)@"and meshinfo is:"@string(meshinfo)@"Calling player tick on:"@string(role)@"deltatime is:"@string(delta)@"baseanim:"@string(baseanim)@"nextanim:"@string(nextanim)@"animseq:"@animsequence@"state:"@getstatename());
//  }
  if (Role == ROLE_Authority)  //ONLY SERVER CHECK
  {
//    if (myState!=getstatename())
 //     log ("old state is"@myState@"new state is"@getstatename());
    myState=GetStateName(); //state stuff
    return;
  }
  
  if (Role == ROLE_AutonomousProxy && (isInState('PlayerWaiting') || isInState('playerspectating')))  //do not want a mesh in this case
    return;
  
  if (myState == 'PlayerWaiting' || myState=='playerspectating')  //sim
  {
    Mesh = None;
    return;
  }
  
  if (!Initialized)
  {
    if (ALpri(PlayerReplicationInfo) != None && ALpri(PlayerReplicationInfo).zzMyClass != none)
      Init();
    else
      return;
  }
  
/*  if (myclass==none)      ///now in PRI
    myclass=class<playerpawn>(dynamicloadobject(classtring,class'class',true)); //mayfail=no warning?
  if (myclass==none||myclass.mesh==none){ //I seem to not have this or non-meshed class
    myclass=Class'botpack.TMale1'; //use tmale1.
    skinstring="";  //wipe this stuff
    facestring="";
  }  */
 /*  if (mesh!=myclass.default.mesh){
    SkelAnim=none; //skeletal anim support.  Suggested by psychic_313
    mesh=myclass.default.mesh;
  }    */
  //bisfemale=myclass.default.bisfemale;  //gender check
/*  if (mesh==none&&playerreplicationinfo!=none&&AlPRI(playerreplicationinfo).zzmyclass!=none) //read the damn mesh!
    mesh=alpri(playerreplicationinfo).zzmyclass.default.mesh;
  else if (playerreplicationinfo==none||alpri(playerreplicationinfo).zzmyclass==none) //set mesh to none to prevent tourneymale info.
    mesh=none;
  if (mesh==none) return; //do not do anything with no mesh!
  */
  
  if (SoundInfo == None) //set up soundinfo
  {
    if (ClassIsChildOf(ALpri(PlayerReplicationInfo).zzMyClass,class'unreali.unrealiplayer'))
      SoundInfo=class'UnrealIPlayerSoundInfo';
    else
      Soundinfo=class'TournamentPlayerSoundInfo';
  }
  
  if (MeshInfo == class'DPMSmeshinfo')
    MeshInfo = xxGetMeshInfo();
  
  if (role != ROLE_SimulatedProxy || delta==0)
    return;
  
  if (zzNextSound!=0) //server changed it.
    xxSetSounds();
  
  if (myState!='' && myState != getstatename()) //state stuff
    GotoState(myState);
  else if (myState=='' && !isInState('playerwalking'))
    GotoState('playerwalking');
  
  //////////////////////////////////////////////////////////
  // Update anims fakes the anim switching of processmove()
  //////////////////////////////////////////////////////////
  if (MeshInfo != None)
    MeshInfo.static.xxUpdateAnims(self);
  
  //////////////////////////////////////////////////////////
  // Animend is not called on sim pawns, so we h4x0r it here
  // Thanks Mongo!
  //////////////////////////////////////////////////////////
  //if ((animrate==0&&(animframe==animlast || animframe==0))||(banimloop&&animframe==animlast)) //always would not be animating: animlast if played, 0 if tweened
  if (bAnimfinished||(bAnimLoop && LastAnim == AnimSequence && (AnimFrame == AnimLast || AnimFrame < LastaFrame))) //complex but works
    AnimEnd();
  
  LastAFrame = AnimFrame;   //to check next tick
  LastAnim = AnimSequence;
}

//some DPMS stuff (new menus):
event PreRender(canvas Canvas)
{
  super.PreRender(Canvas);
  
  if (!bMenuClassSetup)
    InitMenu();
  
  if (!bMsg && myHud != None)
  {
    ClientMessage("This server is running Valhalla Avatar 0.9 BETA for UTPure.  Type 'help' for more information or hit ESC and view the ValAvatar menus!",'DeathMessage',true);
    bMsg = true;
  }
  //REMOVE THIS:
}

// FIXME: After game revert to old menu!
function InitMenu()
{
  local Windowconsole PlayerConsole;
  local UMenuMenuBar MenuBar;
  local UWindowMenuBarItem aMenu;
  local Class<UWindowWindow> OldClass;

  if (Player != none)
  {
    PlayerConsole = Windowconsole(Player.Console);
    if (PlayerConsole == none || !PlayerConsole.bCreatedRoot)
    {
      //Log("[--Debug--]: PlayerConsole == none");
      return;
    }
  
    MenuBar = UMenuRootWindow(PlayerConsole.Root).MenuBar;
    if (MenuBar == none)
    {
      //Log("[--Debug--]: MenuBar == none");
      return;
    }
  
    //I jacked up oldskool, so this is a hack fix.
    if (UMenuOptionsMenu(MenuBar.OptionsItem.menu).PlayerWindowClass != class'DPMSPlayerWindow')
    {
      OldClass=UMenuOptionsMenu(MenuBar.OptionsItem.menu).PlayerWindowClass;
      //Log("[--Debug--]: Replacing the PlayerWindowClass");
      UMenuOptionsMenu(MenuBar.OptionsItem.menu).PlayerWindowClass = class'DPMSPlayerWindow';
    }
  
    //already installed check:
    for( aMenu = UWindowMenuBarItem(Menubar.Items.Next); aMenu != None; amenu = UWindowMenuBarItem(amenu.Next) )
       if (amenu.Caption == "&ValAvatar")
        return;
    
    //Insert VA menu here:
    AMenu=MenuBar.AddItem("&ValAvatar");
    VaMenu(amenu.CreateMenu(class'VaMenu')).oldclass=oldclass;
    bMenuClassSetup = true;
  }
}

//WIPED: we do not want this to occur server-side. heck, it will save loading time anyway :P
static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum);

//used for ubrowser!
static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{ 
  if (SkinActor.class!=class'ALplayer') //screw this.
    return;
  
  //simply return whatever the client set it as:
  SkinName = ALPRI(Pawn(SkinActor).PlayerReplicationInfo).zzSkinString;
  
  if (ALPRI(Pawn(SkinActor).PlayerReplicationInfo).zzFaceString != "") //ubroswer none thing
    FaceName=ALPRI(Pawn(SkinActor).PlayerReplicationInfo).zzFaceString;
//else
//  facename="";
}

//DPMS STUFF!!  ?
// intercept a SetMesh call
simulated function SetMesh()
{
  SkelAnim=None;
  
  if (Role == ROLE_Authority || (PlayerReplicationInfo == None && Mesh == None))
    Mesh=default.Mesh; //so will replicate.
  else
    Mesh=PlayerReplicationInfo.Mesh;
}

//Swaps skin from player setup call.   (team num is ignored).
function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
  if (/* Level.Game.bCanChangeSkin*/ class'VaSettings'.default.MeshSkinAllowChange>0)
  {
    //Self.Static.SetMultiSkin(Self, SkinName, FaceName, TeamNum );
    ALPRI(PlayerReplicationInfo).zzSkinString=SkinName;  //hey, lets fix this stuff up!
    ALPRI(playerreplicationinfo).zzFaceString=FaceName;
  }
}
//=============================================================================
// Sound Playing Functions (all overridden to use SoundInfo class for sounds)

// From Engine.Pawn
event FootZoneChange(ZoneInfo newFootZone)
{
  local actor HitActor;
  local vector HitNormal, HitLocation;
  local float splashSize;
  local actor splash;
  
  if (Level.NetMode == NM_Client) //autonomous sound playing (in theory some sounds may over-ride, but really shouldn't)
  {
    if ( Level.TimeSeconds - SplashTime > 0.25 )
    {
      SplashTime = Level.TimeSeconds;
      if (!FootRegion.Zone.bWaterZone&&newFootZone.bWaterZone)
    {
        if ( newFootZone.EntrySound != None )
        {
          HitActor = Trace(HitLocation, HitNormal, Location - (CollisionHeight + 40) * vect(0,0,0.8),
               Location - CollisionHeight * vect(0,0,0.8), false);
           
          if ( HitActor != None )
            SoundInfo.static.FootZoneChange(self);
        }
      }
    }
  
    if (FootRegion.Zone.bPainZone)   ///autonomous pain timer stuff.
    {
      if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
        PainTime = -1.0;
    }
    else if (newFootZone.bPainZone)
      PainTime = 0.01;
    
    return;
  }
  if ( Level.TimeSeconds - SplashTime > 0.25 )
  {
    SplashTime = Level.TimeSeconds;
  
    if (Physics == PHYS_Falling)
      MakeNoise(1.0);
    else
      MakeNoise(0.3);
    
    if ( FootRegion.Zone.bWaterZone )
    {
      if ( !newFootZone.bWaterZone && (Role==ROLE_Authority) )
      {
        if ( FootRegion.Zone.ExitSound != None )
          PlaySound(FootRegion.Zone.ExitSound, SLOT_Interact, 1);
      
        if ( FootRegion.Zone.ExitActor != None )
          Spawn(FootRegion.Zone.ExitActor,,,Location - CollisionHeight * vect(0,0,1));
      }
    }
    else if ( newFootZone.bWaterZone)
    {
      splashSize = FClamp(0.000025 * Mass * (300 - 0.5 * FMax(-500, Velocity.Z)), 1.0, 4.0 );
    
      if ( newFootZone.EntrySound != None )
      {
        HitActor = Trace(HitLocation, HitNormal,
          Location - (CollisionHeight + 40) * vect(0,0,0.8), Location - CollisionHeight * vect(0,0,0.8), false);
      
        if ( HitActor == None )
          PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize);
        else
        {
          //PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize);
          //nextsound=Sound_Footzonechange; //don't play on server, but let clients get it.
          //lastsoundtimer=-1*level.timeseconds;  //double check this
          xxServerSound(5);
        }
      }
    
      if( newFootZone.EntryActor != None )
      {
        splash = Spawn(newFootZone.EntryActor,,,Location - CollisionHeight * vect(0,0,1));
        if ( splash != None )
          splash.DrawScale = splashSize;
      }
      //log("Feet entering water");
    }
  }
  
  if (FootRegion.Zone.bPainZone)
  {
    if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
      PainTime = -1.0;
  }
  else if (newFootZone.bPainZone)
    PainTime = 0.01;
}

// From BotPack.TournamentPlayer
function PlayDyingSound()
{
  //lastsoundtimer=level.timeseconds;
  if (Role == ROLE_Authority)
    //nextsound=Sound_PlayDyingSound;
    xxServerSound(4);
  else
    SoundInfo.static.PlayDyingSound(self); //autonomous call.
}

//Player Jumped
function DoJump( optional float F )
{
  if ( CarriedDecoration != None )
    return;
  
  if ( !bIsCrouching && (Physics == PHYS_Walking) )
  {
    if ( !bUpdating )
  {
      //lastsoundtimer=-1*level.timeseconds;
      if (Role == ROLE_AutonomousProxy)
        SoundInfo.static.DoJump(self);
      else
        //nextsound=Sound_dojump;
        xxServerSound(3);
    }
  
    if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
      MakeNoise(0.1 * Level.Game.Difficulty);
    
    PlayInAir();
    if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
      Inventory.OwnerJumped();
    
    if ( bIsWalking )
      Velocity.Z = Default.JumpZ;
    else
      Velocity.Z = JumpZ;
    
    if ( (Base != Level) && (Base != None) )
      Velocity.Z += Base.Velocity.Z;
     
    SetPhysics(PHYS_Falling);
  }
}

simulated function FootStepping() //already simulated.  makes life a lot easier.
{
  if (Role<ROLE_Authority)
    SoundInfo.static.FootStepping(self);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
  if ( Level.TimeSeconds - LastPainSound < 0.3 )
    return;
  
  LastPainSound = Level.TimeSeconds;
  
  //lastsoundtimer=level.timeseconds;
  if ( HeadRegion.Zone.bWaterZone )
  {
    if ( damageType == 'Drowned' )
      //nextsound=Sound_drown;
      xxServerSound(7);
    else
      //nextsound=Sound_uwhit;
      xxServerSound(8);
    
    return;
  }
  
  damage *= FRand();

  if (damage < 8) 
    //nextsound=Sound_hit1;
    xxServerSound(9);
  else if (damage < 25)
  {
    //nextsound=Sound_hit23;
    xxServerSound(10);
  }
  else
    //nextsound=Sound_hit4;
    xxServerSound(11);
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
  super.ClientPlayTakeHit(hitloc,damage,bServerGuessWeapon);
  
  //autonomous hit sounds.
  if ( Level.TimeSeconds - LastPainSound < 0.3 )
    return;
  
  LastPainSound = Level.TimeSeconds;

  if ( HeadRegion.Zone.bWaterZone )
  {
    if ( Hitloc == CollisionHeight * vect(0,0,0.5)) //Drown type: so accurate a real hit would barely affect.
      SoundInfo.static.drown(self);
    else if ( FRand() < 0.5 )
      soundinfo.static.uwhit(self);
    
    return;
  }
  damage *= FRand();

  if (damage < 8) 
    soundinfo.static.hit1(self);
  else if (damage < 25)
  {
    soundinfo.static.hit23(self);
  }
  else
    soundinfo.static.hit4(self);
}
function Gasp()
{
//  lastsoundtimer=-1*level.timeseconds;
  if ( PainTime < 2 )
    //extsound=Sound_gasp;
    xxServerSound(1);
  else
    //nextsound=Sound_breathagain;
    xxServerSound(2);
}

event HeadZoneChange(ZoneInfo newHeadZone)  //allows gasp to get called!
{
  if (role==role_authority)
  {
    super.headzonechange(newheadzone);
    return;
  }
  
  if (HeadRegion.Zone.bWaterZone)
  {
    if (!newHeadZone.bWaterZone)
    {
      if (PainTime > 0 && (PainTime < 8) )
    {
        if ( PainTime < 2 )
          soundinfo.static.gasp(self);
        else
          soundinfo.static.breathagain(self);
      }
    
      bDrowning = false;
      if ( !FootRegion.Zone.bPainZone )
        PainTime = -1.0;
    }
  }
  else if (newHeadZone.bWaterZone && !FootRegion.Zone.bPainZone )
    PainTime = UnderWaterTime;
}

event PainTimer()  //autonomous proxy pain timer.  due to checks on this side.
{
  local float depth;
  
  if (Level.NetMode != NM_Client)
  {
    super.paintimer();
    return;
  }
  
  if (Health < 0)
    return;
  
  if ( FootRegion.Zone.bPainZone )
      PainTime = 1.0;
  else if ( HeadRegion.Zone.bWaterZone )
      PainTime = 2.0;
}

// here to support UnrealI.MaleOne
simulated function PlayMetalStep()
{
  if (role<ROLE_Authority)
    SoundInfo.static.PlaySpecial(self, 'MetalStep');
}

// used by SkaarjTrooper mesh
simulated function WalkStep()
{
  if (role<ROLE_Authority)
    SoundInfo.static.PlaySpecial(self, 'WalkStep');
}

simulated function RunStep()
{
  if (role<ROLE_Authority)
    SoundInfo.static.PlaySpecial(self, 'RunStep');
}

//=============================================================================
// Animation Playing Functions
// a lot of 'em, eh?
// anims played on local player (like normal UT) and replicated as names from the server

state FeigningDeath   //this has been overloaded to use a timer, for animations no longer occur server-side :P
{
ignores SeePlayer, HearNoise, Bump;

  function Rise()
  {
    if ( (Role == ROLE_Authority) && (Health <= 0) )
    {
      GotoState('Dying');
      return;
    }
  
    if ( !bRising )
    {
      settimer(0.7,false); //as tweenanim is noramlly 0.7 :P
      BaseEyeHeight = Default.BaseEyeHeight;
      bRising = true;
      banimon=true;
      PlayRising();
    }
  }
//UTPure compatibility: uncomment playermove/comment feign anim check for normal. reverse for UTPure.

//for UTPure (playermove support)
function bool FeignAnimCheck(){ //for VA compatibility
  return bAnimon;
}
 //uses super in PURE!
/*  function PlayerMove( float DeltaTime)
  {
    local rotator currentRot;
    local vector NewAccel;

    aLookup  *= 0.24;
    aTurn    *= 0.24;

    // Update acceleration.
    if ( !banimon && (aForward != 0) || (aStrafe != 0) )
      NewAccel = vect(0,0,1);
    else
      NewAccel = vect(0,0,0);

    // Update view rotation.
    currentRot = Rotation;
    UpdateRotation(DeltaTime, 1);
    SetRotation(currentRot);

    if ( Role < ROLE_Authority ) // then save this move and replicate it
      ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
    else
      ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
    
    bPressedJump = false;
  }
 */
  function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
  {
    if ( bAnimOn )
    {
      SetTimer(tweentime, false);
      bAnimOn=true;
      Global.PlayTakeHit(tweentime, HitLoc, Damage);
    }
  }
  
  function timer()
  {
    if ( Role < ROLE_Authority )
      return;
    
    if ( Health <= 0 )
    {
      GotoState('Dying');
      return;
    }
  
    GotoState('PlayerWalking');
    PendingWeapon.SetDefaultDisplayProperties();
    ChangedWeapon();
  }
  
  function PlayDying(name DamageType, vector HitLocation)
  {
    BaseEyeHeight = Default.BaseEyeHeight;
  
    if ( bRising || bAnimOn)
      Global.PlayDying(DamageType, HitLocation);
  }
  
  function Landed(vector HitNormal)
  {
//    lastsoundtimer=-1*level.timeseconds;
    if ( Role == ROLE_Authority )
      //nextsound=Sound_playerlanded;
      xxServerSound(6);
    else
      SoundInfo.static.PlayerLanded(self); //autonomous
    
    if ( bUpdating )
      return;
    
    TakeFallingDamage();
    bJustLanded = true;  
  }
  
  simulated function BeginState()
  {
    if (role==role_simulatedproxy)  //do it directly (else seeing feigned player could get b0rked)
      meshinfo.static.PlayFeignDeath(self);
    else
      super.beginstate();
    
    bAnimOn=false;
  }
}

function PlayTurning()
{
  BaseEyeHeight = Default.BaseEyeHeight;
  if (role<role_authority)
    MeshInfo.static.PlayTurning(self);
  else
//    baseanim='playturning';
    baseanim=13;
}

function TweenToWalking(float tweentime)  //tweentime is always called as 0.1!
{
  BaseEyeHeight = Default.BaseEyeHeight;
  
  if ((weapon!=none&&weapon.bpointing)|| (CarriedDecoration != None) )
  {
    if (Role < ROLE_Authority)
      MeshInfo.static.TweenToWalkingPoint(self);
  //  else
  //    nextanim='tweentowalkingpoint';
  }
  else if (role<role_authority)
    MeshInfo.static.TweenToWalking(self);
//  else
//    nextanim='tweentowalking';
}

function PlayDodge(eDodgeDir DodgeMove)
{
  Velocity.Z = 210;
  if (Role < ROLE_Authority)
  {
    if ( DodgeMove == DODGE_Left )
      MeshInfo.static.PlayDodgeL(self);
    else if ( DodgeMove == DODGE_Right )
      MeshInfo.static.PlayDodgeR(self);
    else if (dodgemove == DODGE_BACK)
      MeshInfo.static.PlayDodgeB(self);
    else
      MeshInfo.static.PlayDodgeF(self);
  }
  else
  {
  //  lastanimtimer=-1*level.timeseconds;
    if ( DodgeMove == DODGE_Left )
//      nextanim='PlayDodgeL';
      xxServerAnim(1);
    else if ( DodgeMove == DODGE_Right )
      //nextanim='PlayDodgeR';
      xxServerAnim(2);
    else if (dodgemove == DODGE_BACK)
      //nextanim='PlayDodgeB';
      xxServerAnim(3);
    else
//      nextanim='PlayDodgeF';
      xxServerAnim(4);
  }
}

function PlayWalking()
{
  BaseEyeHeight = Default.BaseEyeHeight;
  if ((weapon!=none&&weapon.bpointing)|| (CarriedDecoration != None) )
  {
    if (Role < ROLE_Authority)
      MeshInfo.static.PlayWalkingPoint(self);
    else
//      baseanim='playwalkingpoint';
      baseanim=12;
  }
  else if (role<role_authority)
    MeshInfo.static.PlayWalking(self);
  else
      //baseanim='playwalking';
      baseanim=11;
}

function TweenToRunning(float tweentime)  //always tweentime=0.1
{
  local vector X,Y,Z, Dir;
  
  BaseEyeHeight = Default.BaseEyeHeight;
  if (bIsWalking)
  {
    TweenToWalking(0.1);
    return;
  }
  
  GetAxes(Rotation, X,Y,Z);
  Dir = Normal(Acceleration);
  
  if (Role<ROLE_Authority)
  {
    if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
    {
      // strafing or backing up
      if ( Dir Dot X < -0.75 )
        MeshInfo.static.Playrunning(self,2,true);
      else if ( Dir Dot Y > 0 )
        MeshInfo.static.Playrunning(self,3,true);
      else
        MeshInfo.static.Playrunning(self,4,true);
    }
    else if (weapon!=none&&weapon.bpointing)
      meshinfo.static.Playrunning(self,1,true);
    else
      MeshInfo.static.Playrunning(self,0,true);
  }
 /* else{
    if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
    {
      // strafing or backing up
      if ( Dir Dot X < -0.75 )
        nextanim='TBackRun';
      else if ( Dir Dot Y > 0 )
        nextanim='TStrafeR';
      else
        nextanim='TStrafeL';
    }
    else if (weapon!=none&&weapon.bpointing)
      nextanim='TPlayRunningPoint';
    else
      nextanim='TPlayRunning';
  }  */
}

function PlayRunning()
{
  local vector X,Y,Z, Dir;
  
  BaseEyeHeight = Default.BaseEyeHeight;
  GetAxes(Rotation, X,Y,Z);
  Dir = Normal(Acceleration);
  
  if (Role < ROLE_Authority)
  {
    if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
    {
      // strafing or backing up
      if ( Dir Dot X < -0.75 )
        MeshInfo.static.Playrunning(self,2,false);
      else if ( Dir Dot Y > 0 )
        MeshInfo.static.Playrunning(self,3,false);
      else
        MeshInfo.static.Playrunning(self,4,false);
    }
    else if (weapon!=none&&weapon.bpointing)
      meshinfo.static.Playrunning(self,1,false);
    else
      MeshInfo.static.PlayRunning(self,0,false);
  }
  else
  {
    if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
    {
      // strafing or backing up
      if ( Dir Dot X < -0.75 )
        //baseanim='BackRun';
        baseanim=8;
      else if ( Dir Dot Y > 0 )
        //baseanim='StrafeR';
        baseanim=9;
      else
        //baseanim='StrafeL';
        baseanim=10;
    }
    else if (weapon!=none&&weapon.bpointing)
      //baseanim='PlayRunningPoint';
      baseanim=7;
    else
      //baseanim='PlayRunning';
      baseanim=6;
  }
}

function PlayRising()
{
  BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
  if (role<role_authority)
    MeshInfo.static.PlayRising(self);
  else
  {
/*    lastanimtimer=-1*level.timeseconds;
    nextanim='PlayRising';*/
    xxServerAnim(5);
  }
}

function PlayFeignDeath()
{
  BaseEyeHeight = 0;
  if (role<role_authority)
    MeshInfo.static.PlayFeignDeath(self);
//else                             //no replication. I decided to go with beginstate();
// nextanim='PlayFeignDeath';
}

//landed hax for all those replication problemz... now it is simulated :P
/*simulated */ function Landed(vector HitNormal)
{
  //Note - physics changes type to PHYS_Walking by default for landed pawns
  if ( bUpdating )
    return;
  
  PlayLanded(Velocity.Z);
//  if (role>role_simulatedproxy){ //only local & server.
  LandBob = FMin(50, 0.055 * Velocity.Z);
  TakeFallingDamage();
  bJustLanded = true;
//  }
}

/*simulated */function PlayLanded(float impactVel) //now simulated as well :P   (beware of bugs!)
{
 // if (role>role_simulatedproxy)
  BaseEyeHeight = Default.BaseEyeHeight;

/*  else{
    nextanim='playlanded'; //wierd hax thingies :P
//    lastanim='playlanded';
  }  */
//  if (role<role_authority)
  if (role==role_authority) //compress landed veloc.
  {
    impactvel /= -20; //terminal velocity is 2500 max, so this makes it fit into 7 bits.
    if (impactvel >= 1)
  {
      zzNextAnim = impactvel;
      zzNextAnim += 128;   //flags last byte as 8th.
    }
//    log ("Server sayz that impactvel is"@impactvel@"and nextanim is"@zznextanim);
  }
  else
    MeshInfo.static.PlayLanded(self, impactVel); //one of the few that have params.
}

//This var also allows sim clients to detect physics!
function PlayInAir()   //may be a little wierd due to acceleration not being replicated, but oh well...
{
  BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
  
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayInAir(self);
  else {
    //log ("server play in air.  Current baseanim is"@baseanim@"and nextanim is"@nextanim);
    //baseanim='playinair'; //it must be base (continuous loop) and base (immediately swaps)
//    lastanimtimer=-1*level.timeseconds;
//    nextanim='playinair';
      if (DodgeDir != DODGE_Active)   //me supposes
        xxServerAnim(16);
  }
}

function PlayDuck()
{
  BaseEyeHeight = 0;
  
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayDuck(self);
  else
    //baseanim='playduck';
    baseanim=15;
}

function PlayCrawling()
{
  BaseEyeHeight = 0;
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayCrawling(self);
  else
    //baseanim='PlayCrawling';
    baseanim=16;
}

function TweenToWaiting(float tweentime)  //never actually replicated. hell I'm not even sure if it is called...
{
  if ( (IsInState('PlayerSwimming')) || (physics==phys_swimming) )
    BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
  else
    BaseEyeHeight = Default.BaseEyeHeight;
//  if (role==role_authority)
  //  nextanim='tweentowaiting';
  //else
  if (role==role_autonomousproxy)
    MeshInfo.static.TweenToWaiting(self, tweentime);   //only case where it is called server-side.
}

function PlayRecoil(float Rate)  //note rate, with exception of duel enforcer, is always weapon.firingrate.  checks for enforcer thing
{
  if (role==role_autonomousproxy){
    if (rate>=1.9*weapon.FiringSpeed)
      MeshInfo.static.PlayDoubleRecoil(self);  //for 2x recoil
    else
      MeshInfo.static.PlayRecoil(self);
  }
  else
  {
    //lastanimtimer=level.timeseconds;
    if (rate>=1.9*weapon.FiringSpeed)
     // nextanim='PlayDoubleRecoil';  //for 2x recoil
     xxServerAnim(7);
    else
      //nextanim='playrecoil';
      xxServerAnim(8);
  }
}

function PlayFiring()   //FIX ME: HL anim viewrot support
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayFiring(self);
  else
  {
    if ((zznextanim>0&&zznextanim<5)||zznextanim==16)
      return;
//    lastanimtimer=level.timeseconds;
  //  nextanim='playfiring';
    xxServerAnim(9);
  }
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
  if ( (Weapon == None) || (Weapon.Mass < 20) )
  {
    if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
    {
      if (role==role_autonomousproxy)
        MeshInfo.static.PlayBigWeaponSwitch(self);
      else
    {
        if ((zznextanim>0&&zznextanim<5)||zznextanim==16)
          return;
       // lastanimtimer=level.timeseconds;
      //  nextanim='PlayBigWeaponSwitch';
        xxServerAnim(10);
      }
    }
  }
  else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
  {  
    if (role==role_autonomousproxy)
      MeshInfo.static.PlayWeaponSwitch(self);
    else
  {
      if ((zznextanim>0&&zznextanim<5)||zznextanim==16)
        return;
      //nextanim='PlayWeaponSwitch';
      //lastanimtimer=level.timeseconds;
      xxServerAnim(11);
    }
  }
}

function PlaySwimming()       //no anim replicated.  (only called autonomously or in animends)
{
  BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
  
  if (role==role_autonomousproxy)
    MeshInfo.static.PlaySwimming(self);
//  else
   // nextanim='playswimming';
}

function TweenToSwimming(float tweentime)  //no anim replicated
{
  if (role<role_authority)
    MeshInfo.static.TweenToSwimming(self, tweentime);
}

//DYING ANIMATIONS:
//Note: there are some issues involved with dying.  With unreali players it won't always use the intended animation (such as in case of repeater), but what can I say?
// carcass heads and body parts are all spawned client-side, due to anim stuff. of course this screws up take damage, but oh well...
function PlayDying(name DamageType, vector HitLoc)
{
  //used for unreali player anim changing.
  local vector X,Y,Z, HitVec, HitVec2D;
  local float dotp;
  //known: suicide, decap, dead9, high, type1 (normal), type2, type3
  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();
      
  if ( DamageType == 'Suicided' )
  {
    if (role==role_authority)
  //nextanim='suicide';
      zzPendingDeath=3;
    else
      MeshInfo.static.PlayDying(self,3);
    
    return;
  }
  
  if (DamageType == 'Decapitated')
  {
    if (role==role_authority)
      //nextanim='decap';
      zzPendingDeath=4;
    else
      MeshInfo.static.PlayDying(self,4);
    
    return;
  }
  // check for repeater death
  if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
  {
    if (role==role_authority)
  //  nextanim='dead9r';  //s3?
      zzPendingDeath=5;
    else
      MeshInfo.static.PlayDying(self,5);
    
    return;
  }
  
  if ( HitLoc.Z - Location.Z > 0.7 * CollisionHeight){ //high hit
    if (role==role_authority)
//      nextanim='highdead';
      zzPendingDeath=6;
    else
      MeshInfo.static.PlayDying(self,6);
    return;
  }
  GetAxes(Rotation,X,Y,Z);
  X.Z = 0;
  HitVec = Normal(HitLoc - Location);
  HitVec2D= HitVec;
  HitVec2D.Z = 0;
  dotp = HitVec2D dot X;
  
  if (Abs(dotp) > 0.71){ //then hit in front or back
    if (role==role_authority)
      //nextanim='type0';
      zzPendingDeath=0;
    else
      MeshInfo.static.PlayDying(self,0);
    }
  else
  {
    dotp = HitVec dot Y;
    if (dotp > 0.0){
      if (role==role_authority)
        //nextanim='type1';
        zzPendingDeath=1;
      else
        MeshInfo.static.PlayDying(self,1); }
    else{
    if (role==role_authority)
//      nextanim='type2';
      zzPendingDeath=2;
    else
      MeshInfo.static.PlayDying(self,2); }
  }
}

function Carcass SpawnCarcass()    //custom carcass functions.
{
local AlCarcass carc;
carc=AlCarcass(super.spawncarcass());
//if (nextanim=='dead9r')
//carc.bjerking=true; //set jerk this way.
//carc.zzdeathanim=zzPendingDeath+1;      //anim seq of carc.
carc.xxsetanim(zzPendingDeath);
//carc.lasthit=level.timeseconds; //saves bandwith
}

function PlayGutHit(float tweentime)  //all tweentimes of hits are 0.1!
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayGutHit(self);
  else{
   // lastanimtimer=level.timeseconds;
   // nextanim='playguthit';
   xxServerAnim(12);
  }
}

function PlayHeadHit(float tweentime)
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayHeadHit(self);
  else{
   // nextanim='playheadhit';
    //lastanimtimer=level.timeseconds;
    xxServerAnim(13);
  }
}

function PlayLeftHit(float tweentime)
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayLeftHit(self);
  else  {
   // nextanim='playlefthit';
    //lastanimtimer=level.timeseconds;
    xxServerAnim(14);
  }
}

function PlayRightHit(float tweentime)
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayRightHit(self);
  else {
   // nextanim='playrighthit';
   // lastanimtimer=level.timeseconds;
    xxServerAnim(15);
  }
}
///////////////////////////////////////////////////////
// Crap because of stupid animation checks!!!!!!!!!!!!!
////////////////////////////////////////////////////////
function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
  local float rnd;
  local Bubble1 bub;
  local bool bServerGuessWeapon;
 //local class<DamageType> DamageClass;
  local vector BloodOffset, Mo;
  local int iDam;

  if ( (Damage <= 0) && (ReducedDamageType != 'All') )
    return;

  //DamageClass = class(damageType);
  if ( ReducedDamageType != 'All' ) //spawn some blood
  {
    if (damageType == 'Drowned')
    {
      bub = spawn(class 'Bubble1',,, Location 
        + 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
      if (bub != None)
        bub.DrawScale = FRand()*0.06+0.04; 
    }
    else if ( (damageType != 'Burned') && (damageType != 'Corroded') 
          && (damageType != 'Fell') )
    {
      BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
      BloodOffset.Z = BloodOffset.Z * 0.5;
      if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') )
      {
        Mo = Momentum;
        if ( Mo.Z > 0 )
          Mo.Z *= 0.5;
        spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
      }
      else
        spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
    }
  }  

  rnd = FClamp(Damage, 20, 60);
  if ( damageType == 'Burned' )
    ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
  else if ( damageType == 'Corroded' )
    ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
  else if ( damageType == 'Drowned' )
    ClientFlash(-0.390, vect(312.5,468.75,468.75));
  else 
    ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

  ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage); 
  PlayTakeHitSound(Damage, damageType, 1);
  //overloaded due to anim checks
  bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || DodgeDir == DODGE_Active/*(nextanim=='PlayDodgeR'||nextanim=='PlayDodgeL'||nextanim=='PlaydodgeF'||nextanim=='PlaydodgeB')*/);
  iDam = Clamp(Damage,0,200);
  ClientPlayTakeHit(hitLocation - Location, iDam, bServerGuessWeapon ); 
  if ( !bServerGuessWeapon 
    && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
  {
    //Enable('AnimEnd');
    BaseEyeHeight = Default.BaseEyeHeight;
    //bAnimTransition = true;
    PlayTakeHit(0.1, hitLocation, Damage);
  }
}

// "GetAnimGroup()" functions from "Engine.Pawn"
function SwimAnimUpdate(bool bNotForward)
{
  if (role==role_autonomousproxy)
    MeshInfo.static.SwimAnimUpdate(self, bNotForward);
  else if (bnotforward)     //client anim analysis will send proper param.
    //baseanim='swimanimupdatenotf';
    baseanim=18;
  else
    //baseanim='swimanimupdate';
    baseanim=17;
}

state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;
  simulated function AnimEnd()    //from the swim anim update, I can tell what anim to play!
  {
    if (role<role_authority)
      MeshInfo.static.xxSwimAnimEnd(self);
  }
  simulated function beginstate(){
    if (role==role_simulatedproxy&&!IsAnimating())
      TweenToWaiting(0.3);
    else if (role>role_simulatedproxy)
      super.beginstate();
  }
  event UpdateEyeHeight(float DeltaTime) //lets local playerpawns still tick   why not playertick? too lazy to overwrite every tick()...
  {
    super.updateeyeheight(deltatime);
    tick(deltatime);
  }
  function playduck(){
    local byte zzoldanim;
    zzoldanim=baseanim;
    global.playduck();
    baseanim=zzoldanim;
    if (role==role_authority)
      xxServerAnim(17);
  }
}

state playerFlying
{
ignores SeePlayer, HearNoise, Bump;
    
  simulated function AnimEnd()
  {
    if (role<role_authority)
      meshinfo.static.PlaySwimming(self);
  }// From Engine.PlayerPawn
}
state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, TakeDamage;
    
  simulated function AnimEnd()
  {
    if (role<role_authority)
      meshinfo.static.PlaySwimming(self);
  }// From Engine.PlayerPawn
}
//////////////////////////////////////////////////////
// AutonomousWalkAnim: Processes anims autonomously with overloadable getanimgroup()
//////////////////////////////////////////////////////
function AutonomousWalkAnim(vector oldaccel)
{
  if ( (Physics == PHYS_Walking) && (meshinfo.static.GetMyAnimGroup(self) != 'Dodge') )
    {
      if (!bIsCrouching)
      {
        if (bDuck != 0)
        {
          bIsCrouching = true;
          PlayDuck();
        }
      }
      else if (bDuck == 0)
      {
        OldAccel = vect(0,0,0);
        bIsCrouching = false;
        TweenToRunning(0.1);
      }

      if ( !bIsCrouching )
      {
        if ( (!bAnimTransition || (AnimFrame > 0)) && (meshinfo.static.GetMyAnimGroup(self) != 'Landing') )
        {
          if ( Acceleration != vect(0,0,0) )
          {
            if ( (meshinfo.static.GetMyAnimGroup(self) == 'Waiting') || (meshinfo.static.GetMyAnimGroup(self) == 'Gesture') || (meshinfo.static.GetMyAnimGroup(self) == 'TakeHit') )
            {
              bAnimTransition = true;
              TweenToRunning(0.1);
            }
          }
           else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000) 
            && (meshinfo.static.GetMyAnimGroup(self) != 'Gesture') )
           {
             if ( meshinfo.static.GetMyAnimGroup(self) == 'Waiting' )
             {
              if ( bIsTurning && (AnimFrame >= 0) ) 
              {
                bAnimTransition = true;
                PlayTurning();
              }
            }
             else if ( !bIsTurning ) 
            {
              bAnimTransition = true;
              TweenToWaiting(0.2);
            }
          }
        }
      }
      else
      {
        if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
          PlayCrawling();
        else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
          PlayDuck();
      }
    }
}
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;
  function Dodge(eDodgeDir DodgeMove)
  {
    local vector x,y,z;
    if ( bIsCrouching || (Physics != PHYS_Walking) )
      return;

    GetAxes(Rotation,X,Y,Z);
    if (DodgeMove == DODGE_Forward)
      Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
    else if (DodgeMove == DODGE_Back)
      Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y; 
    else if (DodgeMove == DODGE_Left)
      Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X; 
    else if (DodgeMove == DODGE_Right)
      Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X; 

    Velocity.Z = 160;
    if (role==role_authority){
      //lastsoundtimer=-1*level.timeseconds;
      //nextsound=Sound_dodgesound;
      xxServerSound(12);
    }
    else
      soundinfo.static.dodgesound(self);
    PlayDodge(DodgeMove);
    DodgeDir = DODGE_Active;
    SetPhysics(PHYS_Falling);
  }

  simulated function AnimEnd()   //a b1tch to handle
  {
    if (role<role_authority)
      MeshInfo.static.xxWalkingAnimEnd(self);
  }
  //This is actually now the base anim setter-upper :D
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
  {    //the client will end up fixing up most of these things to follow same rules as this for animend and such.
    local vector OldAccel;
    
    OldAccel = Acceleration;
    Acceleration = NewAccel;
    bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
    if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
      DodgeDir = DODGE_Active;  
    else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
      Dodge(DodgeMove);

    if ( bPressedJump )
      DoJump();
    if (role==role_autonomousproxy){ //FIXME: May require overload for anim group stuff.
      AutonomousWalkanim(oldaccel);
      return;
    }
    if ( (Physics == PHYS_Walking) && (dodgedir!=DODGE_ACTIVE) )
    {
      if (!bIsCrouching)
      {
        if (bDuck != 0)
        {
          bIsCrouching = true;
         // PlayDuck();
        }
      }
      else if (bDuck == 0)
      {
        OldAccel = vect(0,0,0);
        bIsCrouching = false;
      }

      if ( !bIsCrouching )
      {
        if ( Acceleration != vect(0,0,0) )
        {
          if (biswalking)
            playwalking();
          else
            playrunning();
        }
        else if ( bIsTurning)
        {
          PlayTurning();
        }
        else
          playwaiting(); //replicated crap
      }
        //  }
   // }
  //}
      else
      {
        if ( Acceleration != vect(0,0,0) ||bisturning)
          PlayCrawling();
        else
          PlayDuck();
      }
    }
  else
    //baseanim='playinair'; //for purpose of client-physics check?
    baseanim=0;
  }
  simulated function BeginState()
  {
    if (role>role_simulatedproxy){
      super.beginstate();
      return;
    }
    if ( Mesh == None )
      SetMesh();
    if ( !IsAnimating() )
      PlayWaiting();
  }
  
}
function int xxID(){ //16-bit IDENTIFICATION TAG. (anti-leak security) add IP based encryption?
return 31645;
}
function PlayWaiting()    //contains many animations, as some vars used are not client-side.
{
  if ( bIsTyping )
  {
    PlayChatting();
    return;
  }

  if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )       //a tiny check for eyeheight only
    BaseEyeHeight = 0.7 * Default.BaseEyeHeight;         //region/state is checked on client.
  else
    BaseEyeHeight = Default.BaseEyeHeight;
  ViewRotation.Pitch = ViewRotation.Pitch & 65535;
  If ( (ViewRotation.Pitch > RotationRate.Pitch)
    && (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
  {
    If (ViewRotation.Pitch < 32768)
    {
      if (role==role_authority)
        //baseanim='AimUp';
        baseanim=2;
      else
        MeshInfo.static.Playwaiting(self,1);
    }
    else
    {
      if (role==role_authority)
        //baseanim='AimDown';
        baseanim=3;
      else
        MeshInfo.static.Playwaiting(self,2);
    }
  }
  else if ( (Weapon != None) && Weapon.bPointing )  //client doesn't know much
  {
    if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
    {
      if (role==role_authority)
        //baseanim='Playrapid';
        baseanim=4;
      else
        MeshInfo.static.Playwaiting(self,3);
    }
    else
    {
      if (role==role_authority)
        //baseanim='PlayWeapPoint';
        baseanim=5;
      else
        MeshInfo.static.Playwaiting(self,4);
    }
  }
  else
  {
    if (role==role_authority)
      //baseanim='PlayWaiting';
      baseanim=1;
    else
      meshinfo.static.Playwaiting(self,0);
  }
}

function PlayChatting()
{
  if (role==role_autonomousproxy)
    MeshInfo.static.PlayChatting(self);
  else
    //baseanim='playchatting';
    baseanim=14;
}
function ServerTaunt(name Sequence); //no more! :P
/*
function ServerTaunt(name Sequence )   //ANTI=cheat and replication. as well as gesture timer.
{
//  if (zzisbeta)
//    log ("ServerTaunt. received gesture"@sequence@"last gesture was at"@lastgesturetime);
  if (!Level.Game.bGameEnded&&(class'vasettings'.default.gesturetime==0||level.timeseconds<lastgesturetime+class'vasettings'.default.gesturetime))
  return;
  if (Sequence == 'Thrust'||Sequence == 'Wave' ||Sequence == 'taunt1'||Sequence == 'victory1'){ //server-side check, so no feign death hack.
    lastanimtimer=-1*level.timeseconds;
    nextanim=sequence; //now will replicate back
//     if (zzisbeta)
  //      log ("ServerTaunt. Processed gesture!");
  }
  lastgesturetime=level.timeseconds;
} */
function xxServerTaunt(byte zzsequence){ //sent as a byte
if (zzsequence<5)
  xxServerAnim(zzsequence+18);
}
exec function Taunt( name zzSequence )  //over-loading for BETTER unreali player support.
{
  local byte zzseq;
//  if (Sequence == 'Thrust'||Sequence == 'Wave' ||Sequence == 'taunt1'||Sequence == 'victory1')   //new checks
//  {
    //ServerTaunt(Sequence);
    switch (zzsequence){
      case 'taunt1':
        zzseq=0;
        break;
      case 'thrust':
        zzseq=1;
        break;
      case 'victory1':
        zzseq=2;
        break;
      case 'wave':
        zzseq=3;
        break;
      case 'challenge': //AMS stuff
        zzseq=4;
        break;
     }
    xxservertaunt(zzseq);
    meshinfo.static.taunt(self,zzsequence); //why a meshinfo call?  Allows swaps for other models, such as trooper.
//  }
}
function ClientWeaponEvent(name EventType)  //s3 hack fix.....
{
  if (string(weapon.class)~="botpack.impacthammer"&&eventtype!='FireBlast'){
    log("Abnormal clientweaponeventtype:"@EventType);
    eventtype='FireBlast';
  }
  else if (string(weapon.class)~="botpack.translocator"&&eventtype!='TouchTarget'){
    log("Abnormal clientweaponeventtype:"@EventType);
    eventtype='TouchTarget';
  }

  super.ClientWeaponEvent(EventType);
}
function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
  super.sendvoicemessage(playerreplicationinfo,recipient,messagetype,messageID,broadcasttype);  //lame anti-cheat :P
}
function SetVoice(class<ChallengeVoicePack> V)
{
  PlayerReplicationInfo.VoiceType = V;
  UpdateURL("Voice", string(V), True);
  ServerSetVoice(V);
  xxServerSetVPString(string(V));  //send string.
}

function ServerSetVoice(class<ChallengeVoicePack> V)
{
  if (V!=none)
    PlayerReplicationInfo.VoiceType = V;
}

function xxServerSetVPString(string V){
  if (v!="")
    ALPRI(playerreplicationinfo).zzvoicestring=v;
}

/////////////////////////////////////////////////////////////////
//EXEC'S FOR SETTING PROPERTIES AND HELP!
/////////////////////////////////////////////////////////////////
exec function Help(string cmd){
//ClearProgressMessages();
if (cmd==""){
  Clientmessage("Welcome to Valhalla Avatar BETA 0.8");
  Clientmessage("Commands: (type help [command name] for more info)");
 // Clientmessage("About: Credits");
//  Clientmessage("info: Information About Valhalla Avatar");
//  Clientmessage("PlayerInfo: Displays info about each player's model, skin, and voicepack.");
  Clientmessage("SetDefault (string): Set default mesh");
  Clientmessage("SetGestureTime (float): Set gesture time");
  Clientmessage("More info can be found by hitting ESC and viewing the ValAvatar menus.");
}
else if (cmd~="about"||cmd~="info"||cmd~="playerinfo")
  Clientmessage("Obsolete commands. Please use menus by hitting ESC");
//  Clientmessage("Self-Explainatory");
//else if (cmd~="PlayerInfo")
//  Clientmessage("This displays information on what model, skin, and voicepack each player in the game has intended to use.  Installed tells if you have that file installed and it is being used (if not, a default is).");
else if (cmd~="SetDefault"){
  ClientMessage("Specify a player class to be used if you do not have one another player is using installed");
  Clientmessage("Note that this will not work if the server has disabled 'AllowClientOverride'");
  Clientmessage("Ex: SetDefault Botpack.Tmale2");
}
else if (cmd~="SetGestureTime"){
  ClientMessage("Set the amount of time in seconds between player gestures.  Ignored at end of game.");
  Clientmessage("If you choose 0, then no gestures, other than your own, will occur");
  Clientmessage("Ex: SetGesture 2.12");
}
else
  Clientmessage(cmd$": Unknown command!");
}
exec function About(){
/*  Clientmessage("About Valhalla Avatar BETA 0.9");
  Clientmessage("Created by: UsAaR33");
  Clientmessage("DPMS base by Ob1-Kenobi");
  Clientmessage("Some code written by Psychic_313 and Dr. SiN");
  Clientmessage("With a lot of C++ code base help from Mongo");
  Clientmessage("Special thanks to: Darkbyte for testing and Epicknights, PuF, and GTF for encouragement!");*/
ClientMessage ("OBSOLETE! Please use menus.");
}
exec function Info(){
//  ClientMessage("Valhalla Avatar allows you to use ANY model, skin, or voicepack on this server, regardless of whether it is installed on the server!  For more information visit http://www.unreality.dk/usaar33 or email me at usaar33@yahoo.com");
ClientMessage ("OBSOLETE! Please use menus.");
}
exec function SetDefault(string cmd){
  if (cmd=="")
    ClientMessage("Please specify a class");        //FixME: add mesh swaps.
  else if (class<playerpawn>(DynamicLoadObject(cmd,class'class'))==none)
    ClientMessage("The class"@cmd@"is invalid or not installed on this computer");
  else {
    class'vasettings'.default.defaultplayer=cmd;
    class'vasettings'.static.staticsaveconfig();
    ClientMessage("Default model is now"@cmd);
  }
}
exec function SetGestureTime (float cmd){
  class'vasettings'.default.gesturetime=cmd;
  class'vasettings'.static.staticsaveconfig();
  if (cmd==0)
    ClientMessage("Gestures Disabled!");
  else
    ClientMessage("Gestures will play every"@cmd@"seconds.");
}
//info on players.
exec function PlayerInfo (){
/*local byte zzi;
local ALPRI zzPRI;
local string zzmsg[2], zzskinstring, zzfacestring;
zzmsg[0]="not ";
zzmsg[1]="";
for (zzi=0;zzi<32;zzi++){
  if (GameReplicationInfo.PRIarray[zzi]==none)
    return;
  zzPRI=ALPRI(GameReplicationInfo.PRIArray[zzi]);
  if (zzPRI!=none){
    zzPRI.zzmyclass.static.getmultiskin(zzPRI,zzskinstring,zzfacestring);
    Clientmessage (zzPRI.playername$"'s model is"@zzPRI.zzclassstring@"and is"@zzmsg[byte(zzPRI.zzclassstring~=string(zzPRI.zzmyclass))]$"installed.  Skin is"@zzPRI.zzskinstring@"and is"@zzmsg[byte(zzPRI.zzskinstring~=zzskinstring)]$"installed.  Face is"@zzPRI.zzfacestring@"and is"@zzmsg[byte(zzPRI.zzfacestring~=zzfacestring)]$"installed.  Voicepack is"@zzPRI.zzvoicestring@"and is"@zzmsg[byte(zzPRI.zzvoicestring~=string(zzPRI.voicetype))]$"installed.");
   }
} */
ClientMessage ("OBSOLETE! Please use menus.");
}
//////////////////////////////////////////////////////////////////////////////////////////
// SetMeshClass: in game mesh swaps!
////////////////////////////////////////////////////////////////////////////////////////////
function xxSetMeshClass(coerce string zzmesh,coerce string SkinName, coerce string FaceName)
{
local mutator zzm;
if (class'VaSettings'.default.MeshSkinAllowChange!=2||zzmesh=="")    //mesh swap disallowed.
return;
//process muty:
for (zzm=level.game.basemutator;zzm!=none;zzm=zzm.nextmutator)
  if (zzm.class==class'vaserver')
    break;
zzmesh=VaServer(ZZM).xxclasscheck(zzmesh);  //perform class swaps!
menuname=VaServer(ZZM).menuname;
ALPRI(playerreplicationinfo).zzClassString=zzmesh;
serverchangeskin(skinname,facename,playerreplicationinfo.team);
}
/////////////////////////////////////////////
// CTF/E enhancements. For the hell of it
/////////////////////////////////////////////
/*
//enhanced teamsay:
exec function TeamSay( string Msg )
{
  local string OutMsg;
  local string cmd;
  local int pos,i, zzi;
  local int ArmorAmount;
  local inventory inv;
  local TournamentWeapon Weap,tw;
  local TournamentPickup Item,Special,a;

  local int x;
  local int zone;  // 0=Offense, 1 = Defense, 2= float
  local flagbase Red_FB, Blue_FB;
  local CTFFlag F,Red_F, Blue_F;
  local float dRed_b, dBlue_b, dRed_f, dBlue_f;


  if (PlayerReplicationInfo.Team==255)
  {
    super.TeamSay(Msg);
    return;
  }
  
  OutMsg = "";
  pos = InStr(Msg,"%");
  if (pos>-1)
  {
    for (i=0;i<100;i=1)
    {
      if (pos>0)
      {
        OutMsg = OutMsg$Left(Msg,pos);
        Msg = Mid(Msg,pos);
        pos = 0;
        }

      x = len(Msg);
      cmd = mid(Msg,pos,2);
      if (x-2 > 0)
        Msg = right(msg,x-2);
      else
        Msg = "";
     
      if (cmd~="%H")
      {
      OutMsg = OutMsg$Health$" Health";
      }
      else if (cmd~="%W")
      {
        OutMsg = OutMsg$Weapon.GetHumanName();
      }
      else if (cmd~="%A")
      {
        ArmorAmount = 0;
        for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
        { 
          if (Inv.bIsAnArmor) 
          {
            if ( Inv.IsA('UT_Shieldbelt') )
              OutMsg = OutMsg$"PowerShield ("$Inv.Charge$") and ";
            else 
              ArmorAmount += Inv.Charge;
          }
        }
      
         OutMsg = OutMsg$ArmorAmount$" Armor";
      }
  else if (cmd~="%P"&&gamereplicationinfo.isa('CTFReplicationInfo')) //CTF only
      {
      
        // Figure out Posture.
        
        //ForEach AllActors(class'CTFFlag', F)
        for (zzi=0;zzi<4;zzi++){
          f=CTFReplicationInfo(gamereplicationinfo).FlagList[zzi];
          if (f==none)
            break;
          if (F.homebase.team==0)
            Red_FB = F.homebase;
          else if (F.homebase.team==1)
            Blue_FB = F.homebase;
          if (F.Team==0)
            Red_F = F;
          else if (F.Team==1)
            Blue_F = F;
        }


        dRed_b = vSize(Location - Red_FB.Location);
        dBlue_b = vSize(Location - Blue_FB.Location);
        dRed_f = vSize(Location - Red_F.Position().Location);
        dBlue_f = vSize(Location - Blue_F.Position().Location);

        if (PlayerReplicationInfo.Team==0)
        {
          if (dRed_f<2048 && Red_F.Holder != None&&(Blue_f.holder==none||dRed_f<dBlue_f))
            zone = 0;
          else if (dBlue_f<2048 && Blue_F.Holder != None&&(Red_f.holder==none||dRed_f>dBlue_f))
            zone = 1;
          else if (dBlue_b<2049)
            zone = 2;
          else if (dRed_b<2048)
            zone = 3;
          else
            zone = 4;
        }
        else if (PlayerReplicationInfo.Team==1)
        {
          if (dBlue_f<2048 && Blue_f.Holder != None&&(Red_f.holder==none||dRed_f>=dBlue_f))
            zone = 0;
          else if (dRed_f<2048 && Red_f.Holder != None&&(Blue_f.holder==none||dRed_f<dBlue_f))
            zone = 1;
          else if (dRed_b<2048)
            zone = 2;
          else if (dBlue_b<2048)
            zone = 3;
          else
            zone = 4;
        }

        if ( (Blue_f.Holder == Self) ||
             (Red_f.Holder == Self) )
            zone = 5;
         
        
        
        switch (zone)
        {
          case 0: OutMsg = OutMsg$"Attacking Enemy Flag Carrier";break;
          case 1: OutMsg = OutMsg$"Supporting Our Flag Carrier";break;
          case 2: OutMsg = OutMsg$"Attacking";break;
          case 3: OutMsg = OutMsg$"Defending";break;
          case 4: OutMsg = OutMsg$"Floating";break;
          case 5: OutMsg = OutMsg$"Carrying Flag";break;
          
        }
      
      }
      else if (cmd=="%%")
        OutMsg = OutMsg$"%";
      else
      {
        OutMsg = OutMsg$cmd;
      }
      
      pos = InStr(Msg,"%");
  
      if (Pos==-1)
        break;

    }  
    if (len(msg)>0)
      OutMsg = OutMsg$Msg;

  }
  else
    OutMsg = Msg;

  super.TeamSay(OutMsg);
}
*/
//CTF/E teleporter spectating support:
state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;
/*  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)  
  {
   local Teleporter TP,DestTP;
    super.ProcessMove(deltatime,NewAccel,DodgeMove,DeltaRot);

    foreach RadiusActors(class 'Teleporter',DestTP,CollisionRadius,location)
    {
      TP = DestTP;  // Using DEST as a temp var since it will NONE out.
    }
    
    if (TP != None)
    {
  
      if (zzLastTP != TP)
      {
      
        // Ok this isn't the last TP we touched...
      
        foreach AllActors(class 'Teleporter',DestTP)
        {
          if (string(DestTP.Tag) ~= TP.URL)
          {
            zzLastTP = DestTP;
             TP.Touch(Self);
             return;
          }
        }
      }
    }
    else
    {
      zzLastTP = None;
    }
  }*/
  function BeginState()
  {
    super.beginstate();
    drawtype=DT_none;
  }
  function EndState(){
    super.EndState();
    drawtype=DT_mesh;
  }
}

state PlayerSpectating
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;
/*  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)  
  {
   local Teleporter TP,DestTP;
    super.ProcessMove(deltatime,NewAccel,DodgeMove,DeltaRot);

    foreach RadiusActors(class 'Teleporter',DestTP,CollisionRadius,location)
    {
      TP = DestTP;  // Using DEST as a temp var since it will NONE out.
    }
    
    if (TP != None)
    {
      if (zzLastTP != TP)
      {
      
        // Ok this isn't the last TP we touched...
      
        foreach AllActors(class 'Teleporter',DestTP)
        {
          if (string(DestTP.Tag) ~= TP.URL)
          {
            zzLastTP = DestTP;
             TP.Touch(Self);
             return;
          }
        }
      }
    }
    else
    {
      zzLastTP = None;
    }
  }*/
  function BeginState()
  {
    super.beginstate();
    drawtype=DT_none;
  }
  function EndState(){
    super.EndState();
    drawtype=DT_mesh;
  }  
}
state GameEnded  //anim no move
{
  ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, PainTimer, Died;

//these functions are not used under network!
  function ServerReStartGame();
  exec function Fire( optional float F );

  simulated function BeginState()    //rewrote force anim stopping client-side.
  {
    local Pawn P;

    if (role==role_simulatedproxy){   //force anim stopping!
      AnimRate = 0.0;
      SimAnim.Y = 0;
    }
    else
      super.beginstate(); //call parents
  }
}
/*
exec function VADebug(){
  clientmessage("PRI"@string(playerreplicationinfo));
  clientmessage("Meshinfo"@string(meshinfo));
  clientmessage("Soundinfo"@string(soundinfo));
  clientmessage("mesh"@string(mesh));
  //clientmessage("Nextanim"@string(nextanim));
  //clientmessage("Baseanim"@string(baseanim));
  clientmessage("Anim"@string(animsequence));
  clientmessage("player window"@string(UMenuOptionsMenu(UMenuRootWindow(UTConsole(Player.Console).Root).MenuBar.OptionsItem.menu).PlayerWindowClass));
  clientmessage("Menu setup?"@string(bMenuClassSetup));
}
*/
/*add stuff later:

exec function SetSkin(coerce string NewSkinName)
{
  local string OldSkin, MeshName, SkinName, FaceName;
  local string SkinDesc, TestName, Temp;
  local bool bFound;

  // get the mesh name
  MeshName = GetItemName(String(Mesh));

  SkinName = "None";
  FaceName = "None";
  TestName = "";
  bFound = false;

  // find the skin
  if (MeshInfo.default.bIsMultiSkinned)
  {
    while (true)
    {
      GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

      if (TestName == SkinName)
        break;

      if (TestName == "")
        TestName = SkinName;

      if ((SkinDesc ~= NewSkinName) && (SkinDesc != ""))
      {
        SkinName = Left(SkinName, Len(SkinName) - 1);
        bFound = true;
        break;
      }

      if (NewSkinName ~= SkinName)
      {
        SkinName = Left(SkinName, Len(SkinName) - 1);
        bFound = true;
        break;
      }
    }

    // get a valid face for this skin
    if (bFound)
    {
      TestName = "";
      while ( True )
      {
        GetNextSkin(MeshName, FaceName, 1, FaceName, SkinDesc);

        if( FaceName == TestName )
          break;

        if( TestName == "" )
          TestName = FaceName;

        // Multiskin format
        if( SkinDesc != "")
        {
          Temp = GetItemName(FaceName);
          if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetItemName(SkinName))
          {
            // valid face found so set skin
            FaceName = Left(FaceName, Len(FaceName) - Len(Temp)) $ Mid(Temp, 5);
            ServerChangeSkin(SkinName, FaceName, PlayerReplicationInfo.Team);
            return;
          }
        }
      }
    }
  }
  else
  {
    // try to set skin
    MeshInfo.static.GetMultiSkin(self, SkinName, FaceName);
    ServerChangeSkin(NewSkinName, FaceName, PlayerReplicationInfo.Team);
  }
}

exec function SetFace(coerce string NewFaceName)
{
  local string SkinName, MeshName, FaceName, FullFaceName;
  local string TestName, SkinDesc, Temp;

  if (!MeshInfo.default.bIsMultiSkinned)
    return;

  MeshName = GetItemName(String(Mesh));

  MeshInfo.static.GetMultiSkin(self, SkinName, FaceName);

  FullFaceName = "None";
  TestName = "";
  while ( True )
  {
    GetNextSkin(MeshName, FullFaceName, 1, FullFaceName, SkinDesc);
    if( FullFaceName == TestName )
      break;

    if( TestName == "" )
      TestName = FullFaceName;

    // Multiskin format
    if( SkinDesc != "")
    {
      Temp = GetItemName(FullFaceName);
      if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetItemName(SkinName))
      {
        // valid face found so set skin
        FaceName = Left(FullFaceName, Len(FullFaceName) - Len(Temp)) $ Mid(Temp, 5);
        if (GetItemName(FaceName) ~= NewFaceName)
        {
          ServerChangeSkin(SkinName, FaceName, PlayerReplicationInfo.Team);
          return;
        }
      }
    }
  }
}
function ServerChangeMeshClass(class<Pawn> NewPlayerClass)
{
  //remarked here
   Example mesh class changing code:

  if (NewPlayerClass.default.mesh == MeshInfo.default.PlayerMesh)
  {
    // Could check if mesh is already same here
    return;
  }

  // change class
  SomeGame(Level.Game).ChangeMeshClass(Self, NewPlayerClass);

  MeshInfo.static.CheckMesh(self); // force mesh to update

  UpdateVoicePack(); // check to see if voice pack needs to be changed

  PlayWaiting(); // stops the new mesh from looking frozen when changed
  //to here
}
      */
defaultproperties {
  Mesh=LodMesh'botpack.Commando'
  PlayerReplicationInfoClass=class'alpri'
  carcasstype=class'ALcarcass'
  Meshinfo=class'DPMSMeshInfo'
//  zzisbeta=true
  AnimSequence=
  lastgesturetime=-1000
}
