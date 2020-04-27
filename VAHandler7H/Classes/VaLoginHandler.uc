// ============================================================
// vapure.VaPureLoginHandler: VAPure handler.  Base when under UTPure
// ============================================================

class VaLoginHandler expands ModifyLoginHandler;

var VaServer Va; //main mutator

function Accepted() //better be in RC4 :)
{
  Va=spawn(class'VaServer');
}

function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
  if (Va != None)
  {
	  Va.NextOptions=options;  //due to CSHP 4Q+, this must be done, as CSHP modifies the options after.
	  Super.ModifyLogin(SpawnClass,Portal,Options);
	  Va.RevertVoice=spawnclass.default.VoiceType; //spawn class' voice attempt.
	  if (!classischildof(spawnclass,class'spectator'))
	    spawnclass=class'alplayer'; //setup custom player.  pretty much will always be the final setting :P
  }
}

function bool CanAdd(string spacks, int ppCnt)
{
  // Check if other player packs were installed ?
  return (ppCnt == 1);
}

defaultproperties
{
	LogLine="Valhalla Avatar supported"
}
