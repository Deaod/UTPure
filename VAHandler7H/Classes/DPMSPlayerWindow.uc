class DPMSPlayerWindow extends UMenuPlayerWindow;

function BeginPlay()
{
  Super.BeginPlay();

  ClientClass = class'DPMSPlayerClientWindow';
}

defaultproperties
{
   WindowTitle="Player Setup"
}
