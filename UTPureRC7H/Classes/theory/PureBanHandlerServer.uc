// ===============================================================
// UTPureRC7H.PureBanHandlerServer: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureBanHandlerServer extends PureBanHandler
	config(PureBans);

struct xxBan
{
	var string A;		// Ban Mask
	var string B;		// Who Banned
	var string C;		// Date Banned
};

var config Array<xxBan> BanList;

function PostBeginPlay()
{
	local string zzList;
	local int zzx,zzy;

	zzList = GetPropertyText("BanList");

	while (Length(zzList) > 3)
	{
		zzx = InStr(zzList, "A=");	// Search for A=
		
		zzy = InStr(zz

	}
}

defaultproperties {
}
