// ============================================================
// VAbeta2.VAMenu: menu for Valhalla Avatar.
// ============================================================

class VAMenu expands UWindowPulldownMenu;

var UWindowPulldownMenuItem PlayerInfo, Credits, Help, Options;
var Class<UWindowWindow> OldClass;

function Created()
{
  Super.Created();
  log ("Va menu generated");
  // Add menu items.
  Options = AddMenuItem("Settings", None);
  Options.bdisabled=true;      //REMOVE ME!
  PlayerInfo = AddMenuItem("Player Selections", None);
  AddMenuItem("-", None);
  Help = AddMenuItem("Info/Help", None);
  Credits = AddMenuItem("Credits", None);
}
//help:
function Select(UWindowPulldownMenuItem I)
{
  switch(I)
  {
  case Options:
    UMenuMenuBar(GetMenuBar()).SetHelp("Coming soon!  For now, please use console commands for configuration.");
    return;
  case PlayerInfo:
    UMenuMenuBar(GetMenuBar()).SetHelp("View information on what model, skin, and voicepack each player in the game is using that you may or may not have installed");
    return;
  case Help:
    UMenuMenuBar(GetMenuBar()).SetHelp("Information and help on Valhalla Avatar.");
    break;
  case Credits:
    UMenuMenuBar(GetMenuBar()).SetHelp("See the names of the über-l33t people who brought Valhalla Avatar to you!");
    break;
  }
  Super.Select(I);
}
//menu generation:
function ExecuteItem(UWindowPulldownMenuItem I)
{
  switch(I)
  {
  case PlayerInfo:
    Root.CreateWindow(class'PlayerInfoWindow', 50, 100, min(root.winwidth-50,800), min(root.winheight-150,250), Self, True);
    break;
  case Credits:
    Root.CreateWindow(class'vacreditsmenu', 100, 100, min(root.winwidth-100,350), min(root.winheight-150,200), Self, True);
    break;
  case Help:
     Root.CreateWindow(class'vahelpmenu', 100, 100, min(root.winwidth-100,550), min(root.winheight-150,350), Self, True);
    break;
  }
  super.executeitem(I);
}
//used to remove menu as needed. FIXME: spectators
function NotifyAfterLevelChange()
{
  if (!getplayerowner().isa('alplayer')){
   // log ("VA Menu unlinked!");
    owner.remove(); //remove from existance.  also happens to unlink this.
  }
}

function NotifyBeforeLevelChange()
{ //again I screwed up oldskool :(
if (string(root.class)~="olroot.oldskoolRootwindow")
  owner.remove();
else
  super.NotifyBeforeLevelChange();
}

defaultproperties {
}
