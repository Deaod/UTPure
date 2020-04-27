// ============================================================
// allmodel.ALPRI: a PRI that will replicate the voice as a string.  voicetype is then set.
// also manages all replicated info. (mesh and skins).  This is to allow talktextures to load at beginning, as well as allow carcs to possess correctly
// ============================================================

class ALPRI expands PlayerReplicationInfo;
var string  zzVoicestring; //the voice the player selected.
var playerpawn zzlocalplayer; //client-side only: This represents the local player  (would be cast but need spectating support)
//ACTUAL SKIN/MODEL:
var string zzskinstring; //REPLICATED: this is skin occording to URL
var string zzfacestring; //REPLICATED: this is the face occording to URL
var string zzlastskin, zzlastface, zzlastclass; //checks if the other three have changed.
var string zzClassString; //REPLICATED: this is the class.
var class<playerpawn> zzmyclass; //loaded on each client.  This is the model that is used.  static functions (skin) are called and defaults read from it.
var byte zzlastteam;  //see if new team and need to set to skin
var bool initialized;
//good 'ol RI:
replication{
reliable if ( Role == ROLE_Authority )
zzvoicestring, //voices
zzskinstring,zzfacestring,zzclassstring; //skin stuff
}
simulated function Tick(float delatime){
  if (role==role_authority){
    disable('tick');
    return;
  }
  if (zzclassstring!=""){
    xxInit();
    disable('tick');
  }
}
event postbeginplay(){ //this will give the GRI and won't set bisfemale (client handles that, so yes gender is different on different clients :P)
  StartTime = Level.TimeSeconds;
  Timer();
  SetTimer(2.0, true);
}

simulated event xxInit(){ //I really hate to use this, but due to variable replication I need to...
  local playerpawn zzP;
//timer related
  SetTimer(1.0, true); //seemed like a good update time...
  //FIND LOCAL PLAYER (we use the playerpawn to set skins and such like that):
  if (playerpawn(owner)!=none&&viewport(playerpawn(owner).player)!=none) //quick set (spec issues).
  zzlocalplayer=playerpawn(owner);
  else
//find local player.
    foreach allactors(class'playerpawn',zzP)
      if (viewport(zzP.player)!=none){
        zzlocalplayer=zzP;
        break;
      }
  xxsetclass();
  Timer();
}
simulated function xxsetclass(){
//  if (zzmyclass==none)
    if (zzclassstring=="")
//      zzclassstring="";
//   if (zzclassString=="")
    zzmyclass=none;
   else //then load.
    zzmyclass=class<playerpawn>(dynamicloadobject(zzclassstring,class'class',true)); //mayfail=no warning?
  if (zzmyclass==none||zzmyclass.default.mesh==none){ //I seem to not have this or non-meshed class
    if (alplayer(zzlocalplayer)==none||!Alplayer(zzlocalplayer).zznooverride)
      zzmyclass=class<playerpawn>(dynamicloadobject(class'VAsettings'.default.defaultplayer,class'class')); //use player default. FIXME: Server client override prevention!
    if (zzmyclass==none||zzmyclass.default.mesh==none)
      zzmyclass=class'tmale1';
    zzskinstring="";  //wipe info.
    zzfacestring="";
  }
  mesh=zzmyclass.default.mesh;
  if (string(zzmyclass)~="unreali.skaarjplayer"){ //drawscale fix.
    Drawscale=0.75;
    prepivot.z=-5;
  }
  else {
    drawscale=default.drawscale;
    prepivot=default.prepivot;
  }
  if (owner!=none){
    owner.skelanim=none;
    if (alplayer(owner).mystate!='playerwaiting'&&alplayer(owner).mystate!='playerspectating')   //fix for wait showing bug.
      owner.mesh=mesh;
    owner.drawscale=drawscale;
    owner.prepivot=prepivot;
    Alplayer(owner).meshinfo=class'dpmsmeshinfo';  //reset infos
    Alplayer(owner).soundinfo=none;
    owner.tick(0); //fix stuff up.
    owner.AnimEnd(); //new info requires new animations
  }
  bisfemale=zzmyclass.default.bisfemale;  //gender check
  zzlastclass=zzclassstring; //so can detect swap.
  zzlastskin="q"; //force skin update!
}
simulated event timer(){
local class<voicepack> myvp;
local string zzskinpackage;
if (role==role_authority){
super.timer();
return;}
//log ("ALPRI: client timer");
if (zzClassString!=zzlastclass) //new class
  xxSetClass();
//SKIN/model
if (zzmyclass!=none&&owner!=none&&owner.mesh!=zzmyclass.default.mesh&&!owner.isinstate('playerwaiting')&&!owner.isinstate('playerspectating'))
  owner.mesh=zzmyclass.default.mesh; //case mostly for server-side demos when spec'ing
if ((owner!=none&&owner.mesh==none&&!owner.isinstate('playerwaiting')&&!owner.isinstate('playerspectating'))||zzlastskin!=zzskinstring||zzlastface!=zzfacestring||zzlastteam!=team){
    log ("Setting skin to"@zzskinstring@"and face to"@zzfacestring@"with team"@team@"for"@playername);
    //skin security:
    zzskinpackage=left(zzskinstring,len(getitemname(zzskinstring)));
    if ((owner==none||owner.role==role_simulatedproxy)&&!(left(string(zzmyclass.default.mesh),14)~="skeletalchars.")) //allow people to skin cheat on their own computers :D
      if (left(zzskinpackage,len(getitemname(string(zzmyclass.default.mesh))))!=getitemname(string(zzmyclass.default.mesh))||right(zzskinstring,2)=="t_"){ //also checks the team mix hack
        //illigal skin!
        zzskinstring="";
        zzfacestring="";
      }
    zzlastteam=team;
    zzlastskin=zzskinstring; //now ignore this until next change.
    zzlastface=zzfacestring;
    xxsetupskin(); //init skin.
      //lodset fixing (MANY custom skins, as well as unreali skins.)

}
//VOICE PACK RELATED:
if (zzvoicestring!=""&&string(voicetype)!=zzvoicestring){
myvp=class<voicepack>(dynamicloadobject(zzvoicestring,class'class',true)); //tries to load up the voice.
if (myvp==none)
zzvoicestring="";  //only a new VP could cause a voicepack to try to load.
else
voicetype=myvp; }
}

//SKIN FUNCTIONS FOLLOW:
simulated function xxsetupskin() //this process the skin here. can copy to PRI.
{ 
local texture zzmultiback[8], zzskinback, zztalkback; //old.
local int zzi;
//if (zzlocalplayer==none)
//  log ("Warning: zzlocalplayer is none!");
if (owner!=none){
  owner.skelanim=none;  //skeletal anim
  owner.mesh=zzmyclass.default.mesh;
}
mesh=zzmyclass.default.mesh;
for (zzi=0;zzi<8;zzi++){ //clear all skins, or else could overlap
  multiskins[zzi]=none;
  if (owner!=none)
    owner.multiskins[zzi]=none;
}
skin=none;
if (owner!=none)
  owner.skin=none;
if (classischildof(zzmyclass,class'unrealiplayer'))    //bunch of checks for skin setting.
  self.static.setunrealiskin(self,zzskinstring,team); //uses my oldskool code to do this.
else if (string(zzmyclass)~="multimesh.tnali")
  setnaliskin(); //my allow-custom team skins fix code.
else if (string(zzmyclass)~="multimesh.tcow")
  setcowskin();   //lets atomic cow in and some other stuff
else if (string(zzmyclass)~="skeletalchars.WarBoss"||string(zzmyclass)~="skeletalchars.XanMK2")
  setskelskins();  //uses Phychic's custom skin fix!
else if (string(zzmyclass)~="botpack.tboss")
  setBossSkins();
else if (owner!=none){ //use owner's setting!
  owner.mesh=zzmyclass.default.mesh;
  zzmyclass.static.setmultiskin(owner,zzskinstring,zzfacestring,team);
  //now grab vars.
  for (zzi=0;zzi<8;zzi++)
    Multiskins[zzi]=owner.multiskins[zzi];
  skin=owner.skin;
  if (zzskinstring=="") //was wiped
   zzmyclass.static.getmultiskin(owner,zzskinstring,zzfacestring);
}
else{//teh nasty way of using local player.
  for (zzi=0;zzi<8;zzi++)
    zzmultiback[zzi]=zzlocalplayer.multiskins[zzi];
  mesh=zzlocalplayer.mesh;    //crappy skin cheat check!
  zzlocalplayer.mesh=zzmyclass.default.mesh;
  zzskinback=zzlocalplayer.skin;
  zztalkback=zzlocalplayer.playerreplicationinfo.talktexture;
  //ACTUAL SKIN SETTER! LOCAL PLAYER IS USED SO THAT TALKTEXTURE IS SET.
  zzmyclass.static.setmultiskin(zzlocalplayer,zzskinstring,zzfacestring,team); //why localplayer?  simple: normal setmultiskins set a talktexture only if skinactor is a pawn.
  if (zzskinstring=="") //was wiped
   zzmyclass.static.getmultiskin(zzlocalplayer,zzskinstring,zzfacestring);
  //now grab vars and returnto old values.
  for (zzi=0;zzi<8;zzi++){
    multiskins[zzi]=zzlocalplayer.multiskins[zzi];
    zzlocalplayer.multiskins[zzi]=zzmultiback[zzi];
  }
  skin=zzlocalplayer.skin;
  zzlocalplayer.skin=zzskinback;
  zzlocalplayer.mesh=mesh; //all that skin cheat stuff.
  mesh=zzmyclass.default.mesh;
  talktexture=zzlocalplayer.playerreplicationinfo.talktexture;
  talktexture.lodset=LODSET_None; //no reduction.
  zzlocalplayer.playerreplicationinfo.talktexture=zztalkback;
}
if (owner!=none){    //as postnetbeginplay already called.
  owner.skelanim=none;
  owner.mesh=mesh;
  for (zzi=0;zzi<8;zzi++){
    owner.multiskins[zzi]=multiskins[zzi];
    if (multiskins[zzi]!=none)
      owner.multiskins[zzi].lodset=lodset_skin;
  }
  owner.skin=skin;
  if (classischildof(zzmyclass,class'tournamentplayer')){
    tournamentplayer(owner).StatusDoll=class<tournamentplayer>(zzmyclass).default.statusdoll;
    tournamentplayer(owner).StatusBelt=class<tournamentplayer>(zzmyclass).default.statusbelt;
  }
  else if (bisfemale){ //get the female doll
    tournamentplayer(owner).StatusDoll=Texture'botpack.Icons.Woman';
    tournamentplayer(owner).StatusBelt=Texture'botpack.Icons.WomanBelt';
  }
  else{
    tournamentplayer(owner).StatusDoll=tournamentplayer(owner).default.StatusDoll;
    tournamentplayer(owner).StatusBelt=tournamentplayer(owner).default.StatusBelt;
  }
  owner.drawscale=drawscale;
  owner.prepivot=prepivot;
  tournamentplayer(owner).bisfemale=bisfemale;
}
}
//CUSTOM SKIN SETTINGS BASED ON FIXES.  due to this, the backups need not occur.
simulated function setnaliskin(){       //my fix I made a while back.  will allow people to be spidey and such in team games.
  local string SkinItem, SkinPackage;
  local string skinname;
  skinname=zzskinstring;
  log ("setting nali");
  // two skins
  if ( skinname == "" ){
    skinname = "TNaliMeshSkins.Ouboudah";
    SkinPackage="TNaliMeshSkins.";
  }
  else
  {
    SkinItem = mid(zzskinstring,instr(zzskinstring,".")+1);
    SkinPackage = Left(skinname, Len(skinname) - Len(SkinItem));
  
    if( SkinPackage == "" )
    {
      SkinPackage="TNaliMeshSkins.";
      skinname=SkinPackage$skinname;
    }
  }
  if( !SetSkinElement( 0, skinname, "TNaliMeshSkins.Ouboudah") )
    skinname = "TNaliMeshSkins.Ouboudah";

  // Set the team elements
  if( team<4)
    SetSkinElement( 0, skinpackage$"T_nali_"$String(team), "TNaliMeshSkins.T_nali_"$String(team));   //set it!


  // Set the talktexture (contains other changes too: deletions)
  TalkTexture = Texture(DynamicLoadObject(SkinName$"-Face", class'Texture',true));
  if ( TalkTexture == None )
       TalkTexture = Texture(DynamicLoadObject("TNaliMeshSkins.nali-Face", class'Texture'));
}
simulated function setcowskin(){ //uses the cow fix.  now allows atomic cows!
  local string SkinItem, SkinPackage, skinname;
  skinname=zzskinstring;
  log ("setting cow");
  // two skins

  if ( SkinName == "" ){
    SkinName = "TCowMeshSkins.WarCow";
    SkinPackage="TCowMeshSkins.";
  }
  else
  {
    SkinItem = mid(zzskinstring,instr(zzskinstring,".")+1);
    SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
  
    if( SkinPackage == "" )
    {
      SkinPackage="TCowMeshSkins.";
      SkinName=SkinPackage$SkinName;
    }
  }
 SetSkinElement( 0, SkinName, "TCowMeshSkins.WarCow"); //info reader.
  if( !SetSkinElement( 1, SkinName, "TCowMeshSkins.WarCow") )
    SkinName = "TCowMeshSkins.WarCow";

  // Set the team elements
  if( team < 4 )
    {
    SetSkinElement(1, SkinName$"T_"$String(team), skinname);
    SetSkinElement(2, skinpackage$"T_cow_"$String(team), "TCowMeshSkins.T_Cow_"$String(team));
  }
  else
    SetSkinElement(2, skinpackage$"cowpack", "EpicCustomModels.TCowMeshSkins.cowpack");

  // Set the talktexture
  TalkTexture = Texture(DynamicLoadObject(SkinName$"Face", class'Texture',true));
      if ( TalkTexture == None )
        TalkTexture = Texture(DynamicLoadObject("EpicCustomModels.TCowMeshSkins.WarCowFace", class'Texture'));
}
/*
//GET AROUND TO ADDED BETTER OSA SKIN SUPPORT! USE EUT'S!
simulated function setunrealiskin(){ //skins for unreali players. based on OSA.  however some stuff had to go like team skin preserving. its do or die.
  local string SkinItem, SkinPackage;             //various local strings.....
  local string TeamColor[4];          //from unreali player.  used for non-full versions....
  TeamColor[0]="Red";
  TeamColor[1]="Blue";
  TeamColor[2]="Green";
  TeamColor[3]="Yellow";

  //SkinItem =GetItemName(SkinName);
  Skinitem=mid(zzskinstring,instr(zzskinstring,".")+1);
  if (string(zzmyclass)~="unreali.skaarjplayer"){ //item swapper!
    if (skinitem~="officer")
      skinitem="T_skaarj3";
    else if (skinitem~="sniper")
      skinitem="T_skaarj2";
    else
      skinitem="T_skaarj1";
  }
  //skinpackage =getitemname(string(zzmyclass.default.Mesh))$"skins."; //always use normal files.
  skinpackage =mid(string(mesh),instr(string(mesh),".")+1)$"skins.";
  //back-up talktexture, so it doesn't revert to team one
  if( team != 255 )
  {
  //there'd be some major problems if the following failed :P
    if (string(zzmyclass)~="unreali.skaarjplayer"&&zzlocalplayer.gamereplicationinfo.bteamgame){ //team stuff
      if (team==1)
        Multiskins[0] = texture(DynamicLoadObject(skinpackage$"T_skaarj2", class'Texture'));
      else
        Multiskins[0] = texture(DynamicLoadObject(skinpackage$"T_skaarj3", class'Texture'));
    }
    else
      Multiskins[0] = texture(DynamicLoadObject(skinpackage$"T_"$TeamColor[team], class'Texture'));
  }
  //not team......
  else
   SetSkinElement(0, Skinpackage$skinitem, ""); //doens't matter if it failed, for all skins already have a back layer.
    // Set the talktexture (go for an OSA one first).
  if (string(zzmyclass)~="unreali.skaarjplayer")    //special case
    TalkTexture = Texture(DynamicLoadObject("SkTrooperSkiny.offi5", class'Texture',true));
  else
    TalkTexture = Texture(DynamicLoadObject(mid(string(mesh),instr(string(mesh),".")+1)$"skiny."$Left(skinitem$"111", 4)$"5", class'Texture',true));
  if (talktexture==none){
    if (zzmyclass.default.bisfemale)
      TalkTexture = Texture(DynamicLoadObject("fcommandoskins.cMDo5Ivana", class'Texture'));        //Ivana's face
    else  //cliffyB!
      TalkTexture = Texture(DynamicLoadObject("UTtech2.Deco.xmetex2x1", class'Texture'));
  }
} */
////////////////////////////////////////////////////////////////////
// UnrealI skin support.
// Based on code by PSYCIC_313 for oldmodels.u
// 0 support for old conversions :P
////////////////////////////////////////////////////////////////////
static function Texture GetUISkin(string SkinName)
{
  local string fem, male, UI, sk;   //consts
  fem="FEMALE2SKINSUTHIDDENUNREALI.";
  male="MALE1SKINSUTHIDDENUNREALI.";
  UI="UnrealI.Skins.";
  sk="SKTROOPERSKINSUT.";
  //catch hidden skins. hidden skins r fun :)
  switch (CAPS(skinname)){
    Case fem$"SHIVA":
      return DLO(UI$"F2Female2");
    Case fem$"CHOLERAE":
    Case fem$"CHOL1T_2": //team skin I guess.
      return DLO(UI$"F2Female4");
    Case male$"DAVIES":
      return DLO(UI$"JMale2");
    Case male$"DARGAN":
      return DLO(UI$"JMale3");
    Case male$"AVATAR":
      return DLO(UI$"JMale4");
    Case male$"BORIS":
      return DLO(UI$"JMale5");
    Case male$"SMITH":
      return DLO(UI$"JMale6");
    Case male$"KARL":
      return DLO(UI$"JMale7");
    Case male$"CURTIS":
    Case male$"CURT1T_2":
      return DLO(UI$"JMale8");
    Case "MALE1SKINS.CARY1T_3":
      return DLO("Male1Skins.Carter");
    Case sk$"SKAARJ":
    Case sk$"FALLBACK":
    Case sk$"FALL1T_3":
    Case "SKTROOPERSKINS.T_SKAARJ1":
      return DLO(UI$"SkTrooper1");
    Case sk$"SNIPER":
    Case sk$"FALL1T_1":
    Case "SKTROOPERSKINS.T_SKAARJ2":
      return DLO(UI$"SkTrooper2");
    case sk$"OFFICER":
    case "SKTROOPERSKINS.T_SKAARJ3":
      return DLO(UI$"SkTrooper3");
    //hacked colours
    case sk$"FALL1T_0":
     return DLO("GenFluid.lava.SHlava3");
    case sk$"FALL1T_2":
      return DLO("GenFluid.water8");
   }
  //nothin' special
  return DLO (SkinName);
}
static function Texture DLO(string zzskin){ //return texture (dynamicload objects get annoying to write out :P)
  return Texture(DynamicLoadObject(zzSkin,Class'Texture',true));
}
static function SetUnrealISkin(Actor SkinActor, string SkinName, byte TeamNum){ //based on oldmodels code.
  local string SkinItem, SkinPackage, TeamSkinName, MeshName; // NOTE: SkinPackage does NOT have a trailing dot!
  local texture MySkin;
  local int i;
  local string TeamColor[4];  //from the Unreal I player.
  TeamColor[0]="Red";
  TeamColor[1]="Blue";
  TeamColor[2]="Green";
  TeamColor[3]="Yellow";
  //Parse SkinItem, SkinPackage. (no dot in package)
  SkinItem = mid(skinname,instr(skinname,".")+1);
  SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem) - 1);

  //See if SkinName is valid for our mesh. If not, reset to default.

  if(TeamNum==255)
  {
    //Non-team:
    //If our texture exists in SkinPackage, use it.
    MySkin=GetUISkin(SkinName);
    if (MySkin==None && InStr(SkinPackage,"SkinsUT") < 0 )
    {
      //If not, try looking in SkinPackage$"UT" (e.g. Male1SkinsUT).
      MySkin=GetUISkin(SkinPackage$"UT."$SkinItem);
    }
    if (MySkin==None) //UI skins already have a skin attached, but do to lodsets I do this:
    {
      //If it's not there either, fall back to default.
      MySkin=GetUISkin(GetUIDefault(mid(skinactor.mesh,instr(skinactor.mesh,".")+1)));
    }

  }
  else
  {
    //Team:
    if (!(string(skinactor.mesh)~="unreali.sktrooper") && SkinName~=GetUIDefault(mid(skinactor.mesh,instr(skinactor.mesh,".")+1)))
      TeamSkinName=SkinPackage$".T_"$TeamColor[TeamNum];
    else
      TeamSkinName=SkinPackage$"."$Left(SkinItem$"1111",4)$"1T_"$TeamNum;
    //If our texture exists in SkinPackage, use it.
    MySkin=GetUISkin(TeamSkinName);
    if (MySkin==None && InStr(SkinPackage,"SkinsUT") < 0)
    {
      //If not, try looking in SkinPackage$"UT" (e.g. Male1SkinsUT). These always
      //use new-style naming.
      MySkin=GetUISkin(SkinPackage$"UT."$Left(SkinItem$"1111",4)$"1T_"$TeamNum);
    }
    if (MySkin==None)
    {
      //If it's not there either, fall back to default.
      if (string(skinactor.mesh)~="unreali.sktrooper")
      {
        MySkin=GetUISkin("sktrooperskinsut.fall1T_"$TeamNum);
      }
      else
        MySkin=GetUISkin(mid(skinactor.mesh,instr(skinactor.mesh,".")+1)$"skins.T_"$TeamColor[TeamNum]);
    }
  }

  if (MySkin==None)
    MySkin=GetUISkin(GetUIDefault(mid(skinactor.mesh,instr(skinactor.mesh,".")+1)));
//  Class'OldModelsLODSetReplicator'.static.AdjustLOD(SkinActor,MySkin,1);

  SkinActor.Skin=MySkin;
  SkinActor.Multiskins[0]=MySkin;
  if (string(skinactor.mesh)~="unreali.sktrooper")
    SkinActor.Multiskins[1]=DLO("UnrealI.STEffect.stshield"); //shield lodset
  if (SkinActor.class==default.class)  //check if PRI
  {
    MySkin=GetUISkin(SkinPackage$"."$Left(SkinItem$"1111",4)$"5");
    if (MySkin==None && InStr(SkinPackage,"SkinsUT") < 0)
      MySkin=GetUISkin(SkinPackage$"UT."$Left(SkinItem$"1111",4)$"5");
    if (MySkin==None)   //default in oldmodels package.
      MySkin=GetUISkin(GetUITalk(mid(skinactor.mesh,instr(skinactor.mesh,".")+1)));
    if (MySkin==none){ //hack faces
      if (ALPRI(skinactor).zzmyclass.default.bisfemale) //Ivana's face
        MySkin = Texture(DynamicLoadObject("fcommandoskins.cMDo5Ivana", class'Texture'));
      else  //cliffyB!
        MySkin = Texture(DynamicLoadObject("UTtech2.Deco.xmetex2x1", class'Texture'));
    }
  }
//    Class'OldModelsLODSetReplicator'.static.AdjustLOD(SkinActor,MySkin,2);
    Playerreplicationinfo(SkinActor).TalkTexture=MySkin;
}
static function string GetUIDefault(string meshname){
  switch (caps(meshname)){
    case "SKTROOPER":
      return meshname$"skinsut.fallback";
    case "MALE1":
      return meshname$"skins.kurgan";
    case "MALE2":
      return meshname$"skins.ash";
    case "MALE3":
      return meshname$"skins.dante";
    case "FEMALE1":
      return meshname$"skins.gina";
    case "FEMALE2":
      return meshname$"skins.sonya";
  }
}
static function string GetUITalk(string meshname){
switch (caps(meshname)){
    case "SKTROOPER":
      return "sktrooperskinsUT.skaa5";
    case "MALE1":
      return "male1skinsUT.kurg5";
    case "MALE2":
      return "male2skinsUT.ash15";
    case "MALE3":
      return "male3skinsUT.dant5";
    case "FEMALE1":
      return "female1skinsUT.gina5";
    case "FEMALE2":
      return "female2skinsUT.sony5";
  }
}
//this makes use of the fix made by Psychic_313
simulated function setskelskins(){
  local string SkinItem, SkinPackage, FaceItem, FacePack, MeshName, skinname, fallbackskin[5], fallbackface[5];
  local bool bAllowed, bFake;
  local texture Face;
  local texture Body;
  if (string(zzmyclass)~="Skeletalchars.WarBoss"){
    fallbackskin[0]="WarRed";
    fallbackskin[1]="WarBlue";
    fallbackskin[2]="WarGreen";
    fallbackskin[3]="WarGold";
    fallbackskin[4]="WarBlue";
    fallbackface[0]="WarRedface";
    fallbackface[1]="WarBlueface";
    fallbackface[2]="WarGreenface";
    fallbackface[3]="WarGoldface";
    fallbackface[4]="WarBlueface";
  }
  else{
    fallbackskin[0]="XanBlue";
    fallbackskin[1]="XanRed";
    fallbackskin[2]="XanGreen";
    fallbackskin[3]="XanBronze";
    fallbackskin[4]="XanTitanium";
    fallbackface[0]="XanBlueface";
    fallbackface[1]="XanRedface";
    fallbackface[2]="Xanface";
    fallbackface[3]="bronzeface";
    fallbackface[4]="TitanFace";
  }
  skinname=zzskinstring;
   meshname=mid(string(zzmyclass.default.mesh),instr(string(zzmyclass.default.mesh),".")+1);
  if (skinname=="")
    skinname="skeletalchars."$fallbackskin[team];
  Skinitem=mid(zzskinstring,instr(zzskinstring,".")+1);
  SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem)-1); //excludes the dot
  bAllowed = ( Left(SkinName,Len(meshname)) ~= meshname );
  if(!bAllowed && (owner==none||owner.role==role_simulatedproxy))
    bFake = true;
  else
    bFake = ( Skinitem ~= "fake" );

  if ( team < 4 ) {
    if(!bFake) {
      Body = texture(DynamicLoadObject(SkinPackage$"."$SkinItem$"1T_"$team,class'Texture',true));
      if (body!=none)
        Face =  texture(DynamicLoadObject(SkinPackage$"."$SkinItem$"5T_"$team,class'Texture',true));
    }
    if ( bFake || (Body == None) ) {
      Body = texture(DynamicLoadObject("skeletalchars."$fallbackskin[team],class'Texture'));
      Face = texture(DynamicLoadObject("skeletalchars."$fallbackface[team],class'Texture'));
    }
    else if ( Face == None ) {
      Face = texture(DynamicLoadObject(SkinPackage$"."$SkinItem$"5",class'Texture'));
    }
  }
  else {
    if (!bFake) {
      Body = texture(DynamicLoadObject(SkinPackage$"."$SkinItem$"1",class'Texture',true));
      if (body!=none)
        Face = texture(DynamicLoadObject(SkinPackage$"."$SkinItem$"5",class'Texture',true));
    }
    if ( bFake || (Body == None) ) {
      Body = texture(DynamicLoadObject("skeletalchars."$fallbackskin[4],class'Texture'));
      Face = texture(DynamicLoadObject("skeletalchars."$fallbackface[4],class'Texture'));
    }
  }

  Skin = Body;
  MultiSkins[0] = Body; // make UT believe we have multiskins
  MultiSkins[1] = Body; // ditto
  TalkTexture = Face;
}
simulated function SetBossSkins(){  //my multi-face boss fix.
local string SkinItem, SkinPackage, FaceItem, FacePackage, skinname, facename;

  Skinname=zzskinstring;
  facename=zzfacestring;
  FaceItem = GetItemName(FaceName);
  FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));
  SkinItem = GetItemName(SkinName);
  SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));

  if(SkinPackage == "")
  {
    SkinPackage="BossSkins.";
    SkinName=SkinPackage$SkinName;
  }

  if(FacePackage == "")
  {
    FacePackage="BossSkins.";
    FaceName="Bossskins."$FaceName;
  }

  if( Team != 255 )
  {
   if(!SetSkinElement(0, SkinName$"1T_"$Team, ""))
    {
      if(!SetSkinElement(0, SkinName$"1", ""))
      {
        SetSkinElement(0, "BossSkins.boss1T_"$Team, "BossSkins.boss1");
        SkinName="BossSkins.boss";
      }
    }
    SetSkinElement( 1, SkinName$"2T_"$Team, SkinName$"2");
    SetSkinElement( 2, SkinName$"3T_"$Team, SkinName$"3");
    if (!SetSkinElement(3, SkinName$"4"$FaceItem$"T_"$Team, ""))    //a bool function that returns true or false.....
      SetSkinElement(3, SkinName$"4T_"$Team, SkinName$"4");          //if no TC's we use skinname$4.....
  }
  else
  {
    if(!SetSkinElement(0, SkinName$"1", "BossSkins.boss1"))
      SkinName="BossSkins.boss";

    SetSkinElement(1, SkinName$"2", "BossSkins.boss2");
    SetSkinElement(2, SkinName$"3", "BossSkins.boss3");
    SetSkinElement(3, SkinName$"4"$FaceItem, SkinName$"4");

  }

  TalkTexture = Texture(DynamicLoadObject(SkinName$"5"$FaceItem, class'Texture',true));
    if (TalkTexture == None)
      TalkTexture = Texture(DynamicLoadObject(SkinName$"5Xan", class'Texture',true));
      //so people who didn't relize skins need that 5Xan part........
    if (TalkTexture == None)
      TalkTexture = Texture(DynamicLoadObject(Skinname$"5"$FaceItem, class'Texture',true));
    if (TalkTexture == None)
      TalkTexture = Texture(DynamicLoadObject("bossskins.boss5Xan", class'Texture'));
}
//RI SETSKINELEMENT:
simulated function bool SetSkinElement(int SkinNo, string SkinName, string DefaultSkinName)
{
  local Texture NewSkin;
  local int i;

  
  NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture',true));
  if (NewSkin != None )
  {
    Multiskins[SkinNo] = NewSkin;
    return True;
  }
  else
  {
    log("Failed to load "$SkinName$" so load "$DefaultSkinName);
    if(DefaultSkinName != "")
    {
      NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
      Multiskins[SkinNo] = NewSkin;
    }
    return False;
  }
}
//problems?
function String GetItemName( string FullName )
{
/*  local int pos;

  pos = InStr(FullName, ".");
   While ( pos != -1 )
    {
    FullName = Right(FullName, Len(FullName) - pos - 1);
    pos = InStr(FullName, ".");
  }

  return FullName;*/
return mid(fullname,instr(fullname,".")+1);
}
/////////////////////////////////////////
//playerinfo info for the uwindow grid
////////////////////////////////////////

//returns if installed or not. string is the menuname (if known) as well as playername.
simulated function string getmesh(out byte zzinfo){
if (!(zzclassstring~=string(zzmyclass)))
  return zzclassstring;
zzinfo=1;
if (zzmyclass.default.menuname!="")
  return zzmyclass.default.menuname@"("$zzclassstring$")";
return zzclassstring;
}
////returns if installed or not. string is the package name of the skin.
simulated function string getskinpackage(out byte zzinfo){
if (zzskinstring==""||classischildof(zzmyclass,class'unrealiplayer')){
  zzinfo=1;
  return left(multiskins[0],instr(multiskins[0],"."));
}
if (left(zzskinstring,instr(zzskinstring,"."))~=left(multiskins[0],instr(multiskins[0],".")))    //check package only
  zzinfo=1;
return left(zzskinstring,instr(zzskinstring,"."));
}
//returns the non-package included skin item.
simulated function string GetSkinItem(){
return mid(zzskinstring,instr(zzskinstring,".")+1);
}
//returns the non-packaged included face. if none then it will return "N/A"
simulated function string GetFaceItem(){
if (zzfacestring!="")
  return mid(zzfacestring,instr(zzfacestring,".")+1);;
return "N/A";
}
defaultproperties {
drawtype=DT_None
remoterole=role_simulatedproxy
}
