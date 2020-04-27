// ===============================================================
// Stats.ST_TMale2Bot: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_TMale2Bot extends ST_MaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'TMale2');
}

defaultproperties
{
     CarcassType=Class'Botpack.TMale2Carcass'
     LandGrunt=Sound'Botpack.MaleSounds.(All).land10'
     FaceSkin=3
     FixedSkin=2
     TeamSkin2=1
     DefaultSkinName="SoldierSkins.blkt"
     DefaultPackage="SoldierSkins."
     SelectionMesh="Botpack.SelectionMale2"
     MenuName="Male Soldier"
     Mesh=LodMesh'Botpack.Soldier'
}
