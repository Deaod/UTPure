// ===============================================================
// UTPureRC7H.PureBanHandler: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureBanHandler extends Info
	abstract;

// Bans are stored in this string in the format
// ComputerName,IP4,IP3,IP2,IP1,"Banner","Date"|  (Repeat)

var string zzBans;		
var int zzBan;

function bool xxCheckForBan(string zzCN, string zzIP)
{
	return False;
}

function xxAddBan(string zzCN, string zzIP)
{
}

function xxDelBan(string zzCN, string zzIP)
{
}

defaultproperties {
}
