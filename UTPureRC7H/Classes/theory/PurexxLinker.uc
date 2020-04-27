// ===============================================================
// UTPureRC7D.PurexxLinker: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PurexxLinker extends Object;

struct xxPackageFileSummary
{
	var int zzTag;
	var int zzFileVersion;
	var int zzPackageFlags;
	var int zzNameCount, zzNameOffset;
	var int zzExportCount, zzExportOffset;
	var int zzImportCount, zzImportOffset;
	var GUID zzGUID;
	var Array<int> zzGenerations;
};

struct xxObjectImport
{
	var name zzClassPackage;
	var name zzClassName;
	var int zzPackageIndex;
	var name zzObjectName;
	var Object zzXObject;
	var Object zzSourceLinker;
	var int zzSourceIndex;
};

struct xxObjectExport
{
	var int zzClassIndex;
	var int zzSuperIndex;
	var int zzPackageIndex;
	var name zzObjectName;
	var int zzObjectFlags;
	var int zzSerialSize;
	var int zzSerialOffset;
	var Object zzObject;
	var int zziHashNext;
};

var native const Object zzRoot;
var native const xxPackageFileSummary zzSummary;
var native const Array<Int> zzNameMap;
var native const Array<xxObjectImport> zzImportMap;
var native const Array<xxObjectExport> zzExportMap;
var native const int zzSuccess;
var native const string zzFileName;
var native const int zzContextFlags;

//	TArray<FObjectImport>	ImportMap;			// Maps file object indices >=0 to external object names.
//	TArray<FObjectExport>	ExportMap;			// Maps file object indices >=0 to external object names.

defaultproperties {
}
