// ============================================================
// VAbeta2.VaCreditsMenu: framed, but has no client window....
// Just an excuse to put my name somewhere :P
// ============================================================

class VaCreditsMenu expands UMenuFramedWindow;
/*
function BeforeCreate(){
LookAndFeel = root.GetLookAndFeel("UWindow.UWindowWin95LookAndFeel"); //1337 look and feel
super.beforecreate();
}
*/
function Created()
{
  Super(uwindowwindow).Created();
  MinWinWidth = 50;
  MinWinHeight = 50;
  //ClientArea = CreateWindow(ClientClass, 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
  CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
}
function Resized(); //do nothing as no client area.
//write text:
function WriteText(canvas C, string text, out float Y){
  local float W, H;
  TextSize(C, Text, W, H);
  Y+=H;
  WrapClipText(C, (WinWidth - W)/2, Y, text);
}
function Paint(Canvas C, float X, float Y)
{
  LookAndFeel.FW_DrawWindowFrame(Self, C);
  DrawStretchedTexture(C, 2, 16, WinWidth - 4, WinHeight - 18, Texture'BlackTexture'); //combo hack
  //credits info here:
  c.drawcolor.R=255;
  c.drawcolor.G=255;
  c.drawcolor.B=255;
  C.Font=root.fonts[F_Bold];
  //TextSize(C, Text, W, H);
  Y=4;
  WriteText(C, "Valhalla Avatar 0.9 BETA", Y);
  Y+=8;
  WriteText(C, "By", Y);
  Y+=5;
  WriteText(C, "UsAaR33", Y);
  Y+=8;
  WriteText(C, "DPMS base by Ob1-Kenobi", Y);
  y+=13;
  C.Font=root.fonts[F_Normal];
  WriteText(C, "Special Thanks to:", Y);
  y+=5;
  WriteText(C, "Psychic_313: Skeletal Fixes/UI models code", Y);
  y+=5;
  WriteText(C, "DrSiN: CTF/E enhancements", Y);
  y+=5;
  WriteText(C, "DarkByte: Testing and for UT Pure ->stopping cheats dead!", Y);
  y+=5;
  WriteText(C, "Mongo: Ever wonder why he is on almost every mod's credits list?", Y);
  y+=5;
  WriteText(C, "All the admins who have kindly run VA on their servers!", Y);
  //reset colors:
/*  C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;*/
}
defaultproperties {
WindowTitle="The diligent workers who brought Valhalla Avatar to you.."
}
