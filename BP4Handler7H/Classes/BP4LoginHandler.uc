// ====================================================================
//  Class:  BP4Handler.BP4LoginHandler
//  Parent: BotBGone.ModifyLoginHandler
//
//  <Enter a description here>
// ====================================================================

class BP4LoginHandler extends ModifyLoginHandler;

function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
	if (SpawnClass == class 'XanMK2') 
		SpawnClass = class 'bbXanMK2';
	else if (SpawnClass == class 'WarBoss') 
		SpawnClass = class 'bbWarBoss';
	else
		Super.ModifyLogin(SpawnClass, Portal, Options);
}

function bool CanAdd(string spacks, int ppCnt)
{
	return HasPack(spacks, "SkeletalChars");
}

defaultproperties
{
	LogLine="Bonus Pack 4 supported"
}
