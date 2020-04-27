// ====================================================================
//  Class:  BP1Handler.BP1LoginHandler
//  Parent: BotBGone.ModifyLoginHandler
//
//  <Enter a description here>
// ====================================================================

class BP1LoginHandler extends ModifyLoginHandler;

function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
	if (SpawnClass == class 'TCow') 
		SpawnClass = class 'bbTCow';
	else if (SpawnClass == class 'TNali') 
		SpawnClass = class 'bbTNali';
	else if (SpawnClass == class 'TSkaarj') 
		SpawnClass = class 'bbTSkaarj';
	else
		Super.ModifyLogin(SpawnClass, Portal, Options);
}

function bool CanAdd(string spacks, int ppCnt)
{
local bool bCanAdd;

	bCanAdd = HasPack(spacks, "multimesh");
	bCanAdd = bCanAdd || HasPack(spacks, "EpicCustomModels");
	bCanAdd = bCanAdd || HasPack(spacks, "TCowMeshSkins");
	bCanAdd = bCanAdd || HasPack(spacks, "TNaliMeshSkins");
	bCanAdd = bCanAdd || HasPack(spacks, "TSkMSkins");
	return bCanAdd;
}

defaultproperties
{
	LogLine="Bonus Pack 1 supported"
	NeededPack="MULTIMESH"
}
