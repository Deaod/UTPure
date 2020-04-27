// ===============================================================
// UTPureRC7H.PureLevel: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureLevel extends PureLevelBase;

struct xxReachSpec
{
	var int zzDistance;
	var Actor zzStart,zzEnd;
	var int zzCollisionRadius;
	var int zzReachFlags;
	var bool zzbPruned;
};

var Array<xxReachSpec> zzReachSpecs;
var Model zzModel;

defaultproperties {
}
