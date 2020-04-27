class DPMSPlayerSetupScrollClient extends UMenuPlayerSetupScrollClient;

function Created()
{
  ClientClass = class'DPMSPlayerSetupClient';
  FixedAreaClass = None;

  Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}
