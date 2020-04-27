// ============================================================
// ValAvatar.VAServer: The main mutator.
// all it really does is change the login class and get a bunch of needed info.
// However this IS meant to be used as a server actor!
// ============================================================

class VaServer expands Mutator;
var string nextoptions;
var string MenuName;
var string RevertVoice;

function postbeginplay(){ //CSHP rip-off.  loaded as a Server-actor
//local mutator zzm;
local string pound; //saves memory :D
pound="____________________________";
/*for (zzm=level.game.basemutator;zzm!=none;zzm=zzm.nextmutator)
  if (zzm.class==class){
    destroy();
    log ("Valhalla Avatar WARNING: Do not put Valhalla Avatar in the mutators list!  Mutator deleted.  Valhalla Avatar will continue to function correctly");
    return;  //idiot proof, incase some moron decided to add me to the mutators list :p
  }*/
log(pound);
//log("");
log("    #  0.9  #    #");
log("     #     #    # #");
log("      #   #    #####");
log("       # #    #     #");
log("        #    #  PURE #");
log(pound);
log("# VALHALLA AVATAR 0.9 BETA FOR UTPURE #");
//log("#    Version 0.8 BETA   #");
//log("#    DO NOT DISTRIBUTE!    #");
if (level.netmode!=nm_dedicatedserver){ //idiot alert!
  log("#         ERROR: Only for use         #");
  log("#        on DEDICATED SERVERS!        #");
  destroy(); //good bye.
}
else
  log("#        Success: Initialized!        #");
//log (pound);
if (bdeleteme) //if destroyed don't add :D
return;
//add future settings logs
log("Client overrides:"@class'VAsettings'.default.AllowClientOverride);
log("Default player:"@class'VAsettings'.default.defaultplayer);
log("Gesture interval:"@class'VAsettings'.default.gesturetime);
if (class'VAsettings'.default.MeshSkinAllowChange==0)
  log("Mesh and skin in-game changing disabled!");
else if (class'VAsettings'.default.MeshSkinAllowChange==1)
  log("skin in-game changing enabled, but mesh changing is disabled!");
else
  log("Mesh and skin in-game changing enabled!");
log (pound);
//add to front of mutators list (front is better :D):
nextmutator=level.game.basemutator;
level.game.basemutator=self;
spawn(class'ShieldNotify'); //spawn the shield effect notifier
}
/*
function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
  nextoptions=options;  //due to CSHP 4Q+, this must be done, as CSHP modifies the options after.
  if ( NextMutator != None )    //this could be a bad idea...
    NextMutator.ModifyLogin(SpawnClass, Portal, Options);
  RevertVoice=spawnclass.default.VoiceType; //spawn class' voice attempt.
  if (!classischildof(spawnclass,class'spectator'))
    spawnclass=class'alplayer'; //setup custom player.  pretty much will always be the final setting :P
}
*/
function bool checkreplacement(actor thing, out byte i){
local class<voicepack> vpclass;
if (alplayer(thing)!=none){ //set ppawn options now
  alplayer(thing).zznooverride=!class'VAsettings'.default.AllowClientOverride;
}
if (alpri(thing)!=none){ //next in order :P
  alpri(thing).zzvoicestring=level.game.ParseOption ( nextOptions, "Voice" );
  //log ("Player voice"@alpri(thing).zzvoicestring);
  alpri(thing).zzclassstring=xxclasscheck(level.game.ParseOption ( nextOptions, "Class" ));
  //log ("Player class"@alpri(thing).zzclassstring);
  alpri(thing).zzskinstring=level.game.ParseOption ( nextOptions, "Skin" );
  //log ("Player skin"@alpri(thing).zzskinstring);
  alpri(thing).zzfacestring=level.game.ParseOption ( nextOptions, "Face" );
  //log ("Player face"@alpri(thing).zzfacestring);
  log (playerreplicationinfo(thing).playername@"Options: Class:"@alpri(thing).zzclassstring@"Skin:"@alpri(thing).zzskinstring@"Face:"@alpri(thing).zzfacestring@"Voice:"@alpri(thing).zzvoicestring);
  playerpawn(thing.owner).menuname=menuname; //name
  vpclass=class<voicepack>(dynamicloadobject(revertvoice,class'class'));
  if (vpclass!=none)
    alpri(thing).voicetype=vpclass; //more voices.
  //log ("Player menuname"@alplayer(thing.owner).menuname);
}
return true; // It doesn't destroy anything
}
function string xxclasscheck(string inclass){    //class changer and menu name reader,
local int i;
local class<playerpawn> localcheck;
menuname="";
//olmodels and fixes checks (and checks with old conversion):
switch (caps(inclass)){  //switches are good. (but I hate using caps :(
case "OLDSKOOL.MALEONE":
case "OLDMODELS.OLDMODELSMALEONE":
case "UNREAL1MODELS.TMALEONE":
case "UNREALI.MALEONE":
inclass="unreali.maleone";
MenuName="UnrealI Male I";
break;
case "OLDSKOOL.MALETWO":
case "OLDMODELS.OLDMODELSMALETWO":
case "UNREAL1MODELS.TMALETWO":
case "UNREALI.MALETWO":
inclass="unreali.maletwo";
MenuName="UnrealI Male ][";
break;
case "OLDSKOOL.MALETHREE":
case "OLDMODELS.OLDMODELSMALETHEEE":
case "UNREAL1MODELS.TMALETHREE":
case "UNREALI.MALETHREE":
inclass="unreali.malethree";
MenuName="UnrealI Male ]|[";
break;
case "OLDSKOOL.FEMALEONE":
case "OLDMODELS.OLDMODELSFEMALEONE":
case "UNREAL1MODELS.TFEMALEONE":
case "UNREALI.FEMALEONE":
inclass="unreali.femaleone";
MenuName="UnrealI Female I";
break;
case "OLDSKOOL.FEMALETWO":
case "UNREAL1MODELS.TFEMALETWO":
case "OLDMODELS.OLDMODELSFEMALETWO":
case "UNREALI.FEMALETWO":
inclass="unreali.femaletwo";
MenuName="UnrealI Female ][";
break;
case "UNREALI.NALIPLAYER":  //naliz
case "NALIFIX.TNALI2":
case "UNREAL1MODELS.TOURNAMENTNALI":
case "MULTIMESH.TNALI":
inclass="multimesh.tnali";
MenuName="Nali";
break;
case "OLDSKOOL.SKTROOPER":
case "OLDMODELS.OLDMODELSSKTROOPER":
case "UNREAL1MODELS.TOURNAMENTSKTROOPER":
CASE "UNREALI.SKAARJPLAYER":
inclass="unreali.skaarjplayer";
MenuName="Skaarj Trooper";
break;
case "MULTIMESH.TSKAARJ":
MenuName="Skaarj Hybrid";
break;
case "COWFIX.TCOWFIXED": //nali cow fix.
CASE "MULTIMESH.TCOW":
inclass="multimesh.tcow";
Menuname="Nali Cow";
break;
case "SKELETALCHARSFIX313.WARBOSSFIX313":     //psychic's fixes.
case "SKELETALCHARSFIX313.WARBOSSMFIX313":
CASE "SKELETALCHARS.WARBOSS":
inclass="skeletalchars.warboss";
MenuName="War Boss";
break;
case "SKELETALCHARSFIX313.XANMK2FIX313":
case "SKELETALCHARSFIX313.XANMK2MFIX313":
CASE "SKELETALCHARS.XANMK2":
inclass="skeletalchars.xanmk2";
MenuName="Xan Mark ][";
break;
case "BOSSFACE.TBOSSFACE": //a fix of mine
inclass="botpack.tboss";
MenuName="Boss";
break;
case "VABETA.ALPLAYER": //this could be a hack.
case "":
inclass=class'VAsettings'.default.defaultplayer;
break;
} //END
for (i=0;i<64;i++)
if (class'VAsettings'.default.badclasses[i]~=inclass){ //illigal class!
menuname="";
inclass=class'VAsettings'.default.defaultplayer; //use player selected as default
break;}
if (menuname==""){
  localcheck=class<playerpawn>(dynamicloadobject(inclass,class'class')); //set menuitem
  if (localcheck!=none)
    menuname=localcheck.default.menuname;
  else
    menuname=getitemname(inclass);
}
return inclass; //my new class.
}

function destroyed(){ //unlink the mutator in case it is!
local mutator zzm;
if (level.game==none) return;
for (zzm=level.game.basemutator;zzm!=none;zzm=zzm.nextmutator) //run through list.
if (zzm.nextmutator==self) break;      //next is me
zzm.nextmutator=nextmutator;     //make prev's next mine   (I'm now unlinked)
nextmutator=none; //no next mutator
}

defaultproperties {
}
