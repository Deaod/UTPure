// ============================================================
// ValAvatar.VAsettings: This is a class which stores settings.  modified through exec commands or a window..
// ============================================================

class VAsettings expands Info
config (ValAvatar);
    //used on server and client
var config string DefaultPlayer; //model to revert to.
var config string BadClasses[64];           //classes I don't like. (used on server and client :P).
var config float gesturetime;               //how frequently are gestures allowed?  ignored if endgame. 0=none
var config bool bAllowNameScripts;          //allow name scripts?  this is a struct which allows names to be changed dynamically. kinda like cool Q1 name anims.
    //Client only:
var ALPRI BadPlayers[32];                  //revert to default always for these.  only invoked in game.
var config bool ChangeEffect;                 //Show an effect when changing mesh?
    //Server only:
var config bool AllowVoices;                //is the voice rep stuff allowed to be used?
var config byte MeshSkinAllowChange;              //0=none  1=skins only 2=skins and meshes
var config bool AllowClientOverride;         //is the client allowed to select his own default model?
var config float SkinChangeTime;            //how long to wait until clients can change mesh/skin again?

defaultproperties {
defaultplayer="botpack.tmale1"
AllowVoices=true
MeshSkinAllowChange=2
AllowClientOverride=true
ChangeEffect=true
SkinChangeTime=43
gesturetime=3
bAllowNameScripts=true
}
