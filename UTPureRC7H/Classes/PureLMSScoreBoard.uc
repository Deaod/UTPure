// ====================================================================
//  Class:  ClickBoard.ClickLMSScoreBoard
//  Parent: Botpack.LMSScoreBoard
//
//  <Enter a description here>
// ====================================================================

class PureLMSScoreBoard extends LMSScoreBoard;

var Texture PureFlagIcon;

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	Super.DrawNameAndPing(Canvas, PRI, XOffset, YOffset, bCompressed);
	if ( PRI.HasFlag == None || !PRI.HasFlag.IsA('PureFlag') )
		return;

	// Flag icon
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(XOffset - 32, YOffset);
	Canvas.DrawIcon(PureFlagIcon, 1.0);
}

defaultproperties
{
	PureFlagIcon=Texture'Botpack.Icons.GreenFlag'
}
