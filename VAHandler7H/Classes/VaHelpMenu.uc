// ============================================================
// VAbeta2.VaHelpMenu: no client.
// Info/About stuff.
// ============================================================

class VaHelpMenu expands UMenuFramedWindow;
/*function BeforeCreate(){
LookAndFeel = root.GetLookAndFeel("UWindow.UWindowWin95LookAndFeel"); //1337 look and feel
super.beforecreate();
}    */
function Created()
{
  Super(uwindowwindow).Created();
  MinWinWidth = 50;
  MinWinHeight = 50;
  //ClientArea = CreateWindow(ClientClass, 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
  CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
}
function Resized(); //do nothing as no client area.
function WriteText(canvas C, string text, out float Y){
  local float W, H;
  TextSize(C, Text, W, H);
  Y+=H;
  ClipText(C, (WinWidth - W)/2, Y, text); //go back to cliptext?
}
function Paint(Canvas C, float X, float Y)
{
  LookAndFeel.FW_DrawWindowFrame(Self, C);
  DrawStretchedTexture(C, 2, 16, WinWidth - 4, WinHeight - 18, Texture'BlackTexture'); //combo hack
  //credits info here:
  c.drawcolor.R=255;
  c.drawcolor.G=255;
  c.drawcolor.B=255;
  C.Font=root.fonts[F_Normal];
  //TextSize(C, Text, W, H);
  Y=4;
  WriteText(C, "Valhalla Avatar 0.9 PURE allows you to use ANY model, skin, or voicepack on this server.", Y);
  Y+=5;
  WriteText(C, "Unlike standard UT, the files do NOT need to be installed on the server.", Y);
  Y+=5;
  WriteText(C, "If others have your custom file, installed, they will see/hear it.  Otherwise, a default will be used.", Y);
  Y+=10;
  WriteText(C, "Using Valhalla Avatar", Y);
  Y+=7;
  WriteText(C, "Currently, you may use the menus only to view what model/skin/voicepack each player is using.", Y);
  Y+=5;
  WriteText(C, "If you do not have them installed, you can download them from utskins.com or planetunreal.com/utmachine", Y);
  C.Font=root.fonts[F_Bold];
  Y+=8;
  WriteText(C, "Console commands may be used for other options:", Y);
  C.Font=root.fonts[F_Normal];
  Y+=5;
  WriteText(C, "SetDefault (classname): Assign the default class to be used if another player's class cannot be used.", Y);
  Y+=5;
  WriteText(C, "SetGestureTime (seconds): specify the delay between gestures.  A value of 0 prevents gestures from playing.", Y);
  Y+=5;
  WriteText(C, "The teamsay command has been enhanced.  Inserting the following symbols in text causes the following to replace them:", Y);
  Y+=4;
  WriteText(C, "%h : Your health", Y);
  Y+=4;
  WriteText(C, "%W : Your weapon", Y);
  Y+=4;
  WriteText(C, "%A : Your armor", Y);
  Y+=4;
  WriteText(C, "%P : Calculates what you appear to be doing in a CTF game", Y);
  Y+=4;
  WriteText(C, "%% : Inserts in a '%'", Y);
}




//reset colors:
 /* C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;*/

defaultproperties {
WindowTitle="Info/Help"
}
