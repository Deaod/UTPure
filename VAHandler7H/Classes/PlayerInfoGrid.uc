// ============================================================
// VAbeta2.PlayerInfoGrid: The ubrowser-like grid which displays player info (like console command)
// ============================================================

class PlayerInfoGrid expands UWindowGrid;
function Created() 
{
  Super.Created();

  RowHeight = 12;

  AddColumn(class'UBrowserPlayerGrid'.default.NameText, 80);
  //AddColumn(class'UBrowserPlayerGrid'.default.TeamText, 30);
  AddColumn(class'UBrowserPlayerGrid'.default.MeshText, 160); //has both menu and mesh package
  AddColumn("Skin Package", 130);
  AddColumn(class'UBrowserPlayerGrid'.default.SkinText, 80);
  AddColumn(class'UBrowserPlayerGrid'.default.FaceText, 60);
  AddColumn("VoicePack", 170);
}
function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
  local int Visible;
  local int Count;
  local int Skipped;
  local int Y;
  local int TopMargin;
  local int BottomMargin;
  local int zzi;
  local AlPRI l;
  local byte zzinfo;

  if(bShowHorizSB)
    BottomMargin = LookAndFeel.Size_ScrollbarWidth;
  else
    BottomMargin = 0;

  TopMargin = LookAndFeel.ColumnHeadingHeight;

  for (skipped=0;skipped<32;skipped++){   //count PRI's.
    if (getplayerowner().gamereplicationinfo.priarray[skipped]!=none)
      count++;
    else
      break;
  }

  C.Font = Root.Fonts[F_Normal];
  Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);
  
  VertSB.SetRange(0, Count+1, Visible);
  TopRow = VertSB.Pos;

  Skipped = 0;
  visible=0; //counts all.
  Y = 1;
  //zzi=0;
  l = alpri(getplayerowner().gamereplicationinfo.priarray[0]);
  while(visible<count&&(Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)))
  {
    if (l!=none){
     if(Skipped >= VertSB.Pos)
     {
      switch(Column.ColumnNum)
      {
      case 0:
        Column.ClipText( C, 2, Y + TopMargin, l.PlayerName );
        break;
      case 1:
        Column.ClipText( C, 2, Y + TopMargin, l.GetMesh(zzinfo) );
        PaintCheck(C,Column,bool(zzinfo),Y+ TopMargin);
        break;
      case 2:
        Column.ClipText( C, 2, Y + TopMargin, l.getskinpackage(zzinfo) );
        PaintCheck(C,Column,bool(zzinfo),Y+ TopMargin);
        break;
      case 3:
        Column.ClipText( C, 2, Y + TopMargin, l.GetSkinItem() );
        break;
      case 4:
        Column.ClipText( C, 2, Y + TopMargin, l.GetFaceItem() );
        break;
      case 5:
        Column.ClipText( C, 2, Y + TopMargin, l.zzVoicestring );
         PaintCheck(C,Column,l.zzVoicestring~=string(l.voicetype),Y+ TopMargin);
        break;
      }

      Y = Y + RowHeight;      
     }
     Skipped ++;
    }
    visible++;
    if (visible<32)
      l = alpri(getplayerowner().gamereplicationinfo.priarray[visible]);
  }
}
/*
function RightClickRow(int Row, float X, float Y)
{
  local UBrowserInfoMenu Menu;
  local float MenuX, MenuY;
  local UWindowWindow W;

  W = GetParent(class'UBrowserInfoWindow');
  if(W == None)
    return;
  Menu = UBrowserInfoWindow(W).Menu;

  WindowToGlobal(X, Y, MenuX, MenuY);
  Menu.WinLeft = MenuX;
  Menu.WinTop = MenuY;

  Menu.ShowWindow();
} */

function SortColumn(UWindowGridColumn Column) //implament me!
{
//  UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server.PlayerList.SortByColumn(Column.ColumnNum);
}
function PaintCheck (Canvas C, UWindowGridColumn Column, bool bchecked,int Y){ //draws a check mark in
//DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
if (bchecked)
  Column.DrawClippedTexture( C, Column.WinWidth - 13, Y, Texture'ChkChecked');
else
  Column.DrawClippedTexture( C, Column.WinWidth - 13, Y, Texture'ChkUnchecked');
}
/*
function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
  local float TW, TH;

  W.TextSize(C, W.Text, TW, TH);
  W.WinHeight = Max(TH+1, 16);
  
  switch(W.Align)
  {
  case TA_Left:
    W.ImageX = W.WinWidth - 16;
    W.TextX = 0;
    break;
  case TA_Right:
    W.ImageX = 0;  
    W.TextX = W.WinWidth - TW;
    break;
  case TA_Center:
    W.ImageX = (W.WinWidth - 16) / 2;
    W.TextX = (W.WinWidth - TW) / 2;
    break;
  }

  W.ImageY = (W.WinHeight - 16) / 2;
  W.TextY = (W.WinHeight - TH) / 2;

  if(W.bChecked) 
  {
    W.UpTexture = Texture'ChkChecked';
    W.DownTexture = Texture'ChkChecked';
    W.OverTexture = Texture'ChkChecked';
    W.DisabledTexture = Texture'ChkCheckedDisabled';
  }
  else 
  {
    W.UpTexture = Texture'ChkUnchecked';
    W.DownTexture = Texture'ChkUnchecked';
    W.OverTexture = Texture'ChkUnchecked';
    W.DisabledTexture = Texture'ChkUncheckedDisabled';
  }
}
*/
defaultproperties {
}
