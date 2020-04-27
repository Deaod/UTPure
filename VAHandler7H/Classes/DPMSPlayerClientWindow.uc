//uses the somewhat new code by Psychic_313 and myself

class DPMSPlayerClientWindow extends UMenuPlayerClientWindow;
function Created()
{
  Super(umenudialogclientwindow).Created();

  Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
  
  Splitter.RightClientWindow = 
UMenuPlayerMeshClient(Splitter.CreateWindow(class'ALPlayerMeshClient', 0, 0, 100, 100));
  Splitter.LeftClientWindow = Splitter.CreateWindow(PlayerSetupClass, 0, 0, 100, 100, OwnerWindow);

  Splitter.bRightGrow = True;
  Splitter.SplitPos = 240;
}

defaultproperties
{
     PlayerSetupClass=Class'DPMSPlayerSetupScrollClient'
}
