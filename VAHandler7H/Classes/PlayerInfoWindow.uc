// ============================================================
// VAbeta2.PlayerInfoWindow: client area is now a grid
// ============================================================

class PlayerInfoWindow expands UMenuFramedWindow;
var UWindowWindow      GridArea;
function Created()
{
  Super.Created();

  MinWinWidth = 50;
  MinWinHeight = 50;
  GridArea = CreateWindow(class'PlayerinfoGrid', 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
  CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
}
function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C,X,Y);
  DrawStretchedTexture(C, 4, 16, WinWidth - 8, WinHeight - 18, Texture'BlackTexture'); //combo hack
}
function Resized()
{
  local Region R;

  R = LookAndFeel.FW_GetClientArea(Self);  //not actually dependent on area

  GridArea.WinLeft = R.X;
  GridArea.WinTop = R.Y;

  if((R.W != GridArea.WinWidth) || (R.H != GridArea.WinHeight))
  {
    GridArea.SetSize(R.W, R.H);
  }

}
defaultproperties {
WindowTitle="Player Identification (check=file installed)"
}
