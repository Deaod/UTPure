//=============================================================================
// DPMSPlayerSetupClient.
// Used to set up DPMS player skins and meshes properly.
//=============================================================================
class DPMSPlayerSetupClient extends UTPlayerSetupClient;
function Close(optional bool bByParent){  //only update on window close.
  local int newteam;
  NewTeam = Int(TeamCombo.GetValue2());
  //custom function to swap mesh:
  if ((newPlayerClass != none) && (newPlayerClass.default.Mesh != GetPlayerOwner().Mesh))
    ALPlayer(GetPlayerOwner()).xxSetMeshClass(newplayerclass,SkinCombo.GetValue2(),FaceCombo.GetValue2());
  else if (newPlayerClass != none)
    GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);
  if( GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam )
    GetPlayerOwner().ChangeTeam(NewTeam);
  super.close(bByParent);
}
function Created()
{
  super.Created();
  if (ALPRI(GetPlayerOwner().playerreplicationinfo)!=none)
    NewPlayerClass = ALPRI(GetPlayerOwner().playerreplicationinfo).zzmyclass;
}

function LoadCurrent()
{
  local string Voice, OverrideClassName;
  local class<PlayerPawn> OverrideClass;
  local string SN, FN;

  Voice = "";
  NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
  TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(string(GetPlayerOwner().PlayerReplicationInfo.Team)), 0));
  if(GetLevel().Game != None && GetLevel().Game.IsA('UTIntro') || GetPlayerOwner().IsA('Commander') || GetPlayerOwner().IsA('Spectator'))
  {
    SN = GetPlayerOwner().GetDefaultURL("Skin");
    FN = GetPlayerOwner().GetDefaultURL("Face");
    ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(GetPlayerOwner().GetDefaultURL("Class"), True), 0));
    Voice = GetPlayerOwner().GetDefaultURL("Voice");
  }
  else
  {
    if (alplayer(GetPlayerOwner())!=none)
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(ALPRI(GetPlayerOwner().playerreplicationinfo).zzmyclass), True), 0));
    else
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(GetPlayerOwner().Class), True), 0));
    GetPlayerOwner().static.GetMultiSkin(GetPlayerOwner(), SN, FN);
    if (classcombo.GetSelectedindex()==0&&alplayer(getplayerowner())!=none&&string(alPRI(getplayerowner().playerreplicationinfo).zzmyclass)~="Unreali.SkaarjPlayer"){
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex("Unreal Skaarj Trooper", True), 0));
      if (classcombo.GetSelectedindex()==0)
        ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex("Skaarj Trooper", True), 0));
    }
    if (classcombo.GetSelectedindex()==0&&alplayer(getplayerowner())!=none) //go for menu name
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex(ALPRI(GetPlayerOwner().playerreplicationinfo).zzmyclass.default.menuname, True), 0));
    if (classcombo.GetSelectedindex()==0&&alplayer(getplayerowner())!=none) //try for oldmodels.
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex("oldmodels.oldmodels"$getplayerowner().getitemname(ALPRI(GetPlayerOwner().playerreplicationinfo).zzmyclass.default.menuname), True), 0));
    if (classcombo.GetSelectedindex()==0&&alplayer(getplayerowner())!=none) //try for unreali.
      ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex("oldskool."$getplayerowner().getitemname(ALPRI(GetPlayerOwner().playerreplicationinfo).zzmyclass.default.menuname), True), 0));
  }
  SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(SN, True), 0));
  FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(FN, True), 0));

  if(Voice == "")
    Voice = alpri(GetPlayerOwner().PlayerReplicationInfo).zzVoicestring;

  IterateVoices();
  VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(Voice, True), 0));

  OverrideClassName = GetPlayerOwner().GetDefaultURL("OverrideClass");
  if(OverrideClassName != "")
    OverrideClass = class<PlayerPawn>(DynamicLoadObject(OverrideClassName, class'Class'));

  SpectatorCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'CHSpectator'));
/*  CommanderCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'Commander'));*/
}

function UseSelected()
{
  //local int NewTeam;
 // local class<playerpawn> playerclass;

  if (Initialized)
  {
    GetPlayerOwner().UpdateURL("Class", ClassCombo.GetValue2(), True);
    GetPlayerOwner().UpdateURL("Skin", SkinCombo.GetValue2(), True);
    GetPlayerOwner().UpdateURL("Face", FaceCombo.GetValue2(), True);
    GetPlayerOwner().UpdateURL("Team", TeamCombo.GetValue2(), True);
/*
    NewTeam = Int(TeamCombo.GetValue2());
   // PlayerClass = class<PlayerPawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'Class'));
    if ((newPlayerClass != none) && (newPlayerClass.default.Mesh != GetPlayerOwner().Mesh))   //custom function to swap mesh!
      ALPlayer(GetPlayerOwner()).xxSetMeshClass(newplayerclass,SkinCombo.GetValue2(),FaceCombo.GetValue2());
    else if (newPlayerClass != none)
      GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);

    if( GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam )
      GetPlayerOwner().ChangeTeam(NewTeam);*/
  }

  if (newplayerclass.default.selectionmesh!="")
    MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh);
  else
    MeshWindow.SetMesh(NewPlayerClass.default.mesh);
  MeshWindow.ClearSkins();
  //ui player fix
  if (ClassisChildof(Newplayerclass,class'unrealiplayer'))
    class'alpri'.static.SetUnrealISkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), Int(TeamCombo.GetValue2()));
  else
    NewPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), FaceCombo.GetValue2(), Int(TeamCombo.GetValue2()));
}
//Psychic_313 and my own OSA/Enhanced UT
function LoadClasses()
{
  local int NumPlayerClasses;
  local string NextPlayer, NextDesc;
  local bool bHasOSA; //does user have OldSkool Amp'd? (or unreali model conversions)

  GetPlayerOwner().GetNextIntDesc("TournamentPlayer", 0, NextPlayer, NextDesc);
  while( (NextPlayer != ""))
  {
//    if (class'Ladder'.Default.HasBeatenGame || !(NextPlayer ~= "Botpack.TBoss"))
      ClassCombo.AddItem(NextDesc, NextPlayer, 0);

    if (instr(nextplayer,"SkTrooper")!=-1)
      bHasOSA=true;
    NumPlayerClasses++;
    GetPlayerOwner().GetNextIntDesc("TournamentPlayer", NumPlayerClasses, NextPlayer, NextDesc);
  }
  numplayerclasses=0;
  if (!bHasOSA){ //get unreali models
  GetPlayerOwner().GetNextIntDesc("UnrealIPlayer", 0, NextPlayer, NextDesc);
  while( (NextPlayer != ""))
  {
    ClassCombo.AddItem(NextDesc, NextPlayer, 0);
    NumPlayerClasses++;
    GetPlayerOwner().GetNextIntDesc("UnrealIPlayer", NumPlayerClasses, NextPlayer, NextDesc);
  }}
  ClassCombo.Sort();
}

function IterateVoices()     //do not require ladder defeat. Yaay!
{
  local int NumVoices;
  local string NextVoice, NextDesc;
  local string VoicepackMetaClass;
  local bool OldInitialized;

  OldInitialized = Initialized;
  Initialized = False;
  VoicePackCombo.Clear();
  Initialized = OldInitialized;

  if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
    VoicePackMetaClass = class<TournamentPlayer>(NewPlayerClass).default.VoicePackMetaClass;
  else if(newplayerclass.default.bisfemale)       //UsAaR33: unreali player related.
    VoicePackMetaClass = "BotPack.VoiceFemale";
  else
    VoicePackMetaClass = "BotPack.VoiceMale";

  // Load the base class into memory to prevent GetNextIntDesc crashing as the class isn't loadded.
  DynamicLoadObject(VoicePackMetaClass, class'Class');

  GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, 0, NextVoice, NextDesc);
  while (NextVoice != "")       //no limit
  {
     VoicePackCombo.AddItem(NextDesc, NextVoice, 0);
     numvoices++;
    GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, NumVoices, NextVoice, NextDesc);
  }

  VoicePackCombo.Sort();
}

function IterateSkins()
// Psychic_313: allowed descriptions for non-bIsMultiSkinned skins; possibly speeded up INT processing a bit for
// multiskinned models
{
  local string SkinName, SkinDesc, TestName, Temp, FaceName;
  local int i;
  local bool bNewFormat;

  SkinCombo.Clear();

  if( ClassIsChildOf(NewPlayerClass, class'Spectator') )
  {
    SkinCombo.HideWindow();
    return;
  }
  else
    SkinCombo.ShowWindow();

  bNewFormat = NewPlayerClass.default.bIsMultiSkinned;

  SkinName = "None";
  TestName = "";
  while ( True )
  {
    GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

    if( SkinName == TestName )
      break;

    if( TestName == "" )
      TestName = SkinName;

    if( !bNewFormat )
    {
      Temp = GetPlayerOwner().GetItemName(SkinName);
      if( Left(Temp, 2) != "T_" )
        if( SkinDesc == "" )
          SkinCombo.AddItem(Temp, SkinName);
        else
          SkinCombo.AddItem(SkinDesc, SkinName);
    }
    else
    {
      // Multiskin format
      if( SkinDesc != "")
      {      
        Temp = GetPlayerOwner().GetItemName(SkinName);
        //if(Len(Temp) < 6) // This is a skin    (psychic change.  maybe 1% increase :P)
        if(Mid(Temp, 5, 64) == "")
          SkinCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Left(Temp, 4));
      }
    }
  }
  if (SkinCombo.List.Items.Count()==0) //a hack
    AddUISkins(meshname);  //add skins for UI models if none added.
  SkinCombo.Sort();
}
//includes hidden ones.
function AddUISkins(string model){
  model=model$"Skins";
  Switch Caps(model){
    Case "MALE1SKINS":
      SkinCombo.AddItem("Carter",model$".Carter");
      SkinCombo.AddItem("Gibbed",model$".Male1Gib");
      SkinCombo.AddItem("Kurgan",model$".Kurgan");
      SkinCombo.AddItem("Davies (hidden)",model$"UTHiddenUnrealI.Davies");
      SkinCombo.AddItem("Dargan (hidden)",model$"UTHiddenUnrealI.Dargan");
      SkinCombo.AddItem("Avatar (hidden)",model$"UTHiddenUnrealI.Avatar");
      SkinCombo.AddItem("Boris (hidden)",model$"UTHiddenUnrealI.Boris");
      SkinCombo.AddItem("Smith (hidden)",model$"UTHiddenUnrealI.Smith");
      SkinCombo.AddItem("Karl (hidden)",model$"UTHiddenUnrealI.Karl");
      SkinCombo.AddItem("Curtis (hidden)",model$"UTHiddenUnrealI.Curtis");
      break;
    Case "MALE2SKINS":
      SkinCombo.AddItem("Ash",model$".Ash");
      SkinCombo.AddItem("Gibbed",model$".Male2Gib");
      SkinCombo.AddItem("Ivan",model$".Ivan");
      SkinCombo.AddItem("Kristoph",model$".Kristoph");
      break;
    case "MALE3SKINS":
      SkinCombo.AddItem("Bane",model$".Bane");
      SkinCombo.AddItem("Dante",model$".Dante");
      SkinCombo.AddItem("Dregor",model$".Dregor");
      SkinCombo.AddItem("Gibbed",model$".Male3Gib");
      SkinCombo.AddItem("Krige",model$".Krige");
      break;
    case "FEMALE1SKINS":
      SkinCombo.AddItem("Drace",model$".Drace");
      SkinCombo.AddItem("Gibbed",model$".FemGib1");
      SkinCombo.AddItem("Gina",model$".Gina");
      SkinCombo.AddItem("Nikita",model$".Nikita");
      SkinCombo.AddItem("Raquel",model$".Raquel");
      SkinCombo.AddItem("Tamika",model$".Tamika");
      break;
    case "FEMALE2SKINS":
      SkinCombo.AddItem("Dimitra",model$".Dimitra");
      SkinCombo.AddItem("Gibbed",model$".Fem2Gib");
      SkinCombo.AddItem("Katryn",model$".Katryn");
      SkinCombo.AddItem("Sonya",model$".Sonya");
      SkinCombo.AddItem("Shiva (hidden)",model$"UTHiddenUnrealI.Shiva");
      SkinCombo.AddItem("Cholerae (hidden)",model$"UTHiddenUnrealI.Cholerae");
      //add hidden?
      break;
    case "SKTROOPERSKINS":
      SkinCombo.AddItem("Infantry",model$".T_Skaarj1");
      SkinCombo.AddItem("Officer",model$".T_Skaarj3");
      SkinCombo.AddItem("Sniper",model$".T_Skaarj2");
      break;
   }
}
function ClassChanged()    //more unreali player hax.
{
  Super.ClassChanged();

 // if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
//  {
    if(Initialized)
    {
      ClassChanging = True;
      IterateVoices();
      if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
      VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(class<TournamentPlayer>(NewPlayerClass).default.VoiceType, True), 0));
      else
      VoicePackCombo.SetSelectedIndex(0);
      ClassChanging = False;
    }
    VoicePackCombo.ShowWindow();
 // }
 // else
//  {
  //  VoicePackCombo.HideWindow();
//  }
}
simulated function VoiceChanged()
{
  local class<ChallengeVoicePack> VoicePackClass;
  local ChallengeVoicePack V;

  if(Initialized)
  {
    VoicePackClass = class<ChallengeVoicePack>(DynamicLoadObject(VoicePackCombo.GetValue2(), class'Class'));
    if(!ClassChanging)  //FIXME: DIFFERENT VOICESPAWN SYSTEM.
    {
      V = GetPlayerOwner().spawn(VoicePackClass,GetPlayerOwner(),,GetPlayerOwner().Location);
      V.ClientInitialize(GetPlayerOwner().PlayerReplicationInfo,GetPlayerOwner().PlayerReplicationInfo,'ACK', Rand(VoicePackClass.Default.NumAcks));
    }
    GetPlayerOwner().UpdateURL("Voice", VoicePackCombo.GetValue2(), True);

    if( GetPlayerOwner().IsA('TournamentPlayer') )
      TournamentPlayer(GetPlayerOwner()).SetVoice(VoicePackClass);
  }
}


