// ===============================================================
// UTPureRC7A.PureHitSound: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureHitSound extends LocalMessagePlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
		return "";

	return RelatedPRI_1.PlayerName@"hit for"@Switch@"damage!";
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (bbPlayer(P) != None)
		bbPlayer(P).PlayHitSound();
	else if (bbCHSpectator(P) != None)
		bbCHSpectator(P).PlayHitSound();
//	P.ClientPlaySound(Sound'UnrealShare.StingerFire',, true);

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}
defaultproperties {
	bIsSpecial=False
	bIsUnique=False
	bFadeMessage=False
	bIsConsoleMessage=True
	bBeep=False
}
