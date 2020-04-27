// ===============================================================
// UTPureRC7A.PureHUDHelper: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureHUDHelper extends Actor
	abstract;

// Contains functions that are similar in all HUDs to reduce the size of them.

static simulated function xxDrawXHair(Canvas zzCanvas, PlayerPawn zzP)
{
	local Weapon zzW;

	zzW = zzP.Weapon;

	if (zzW == None)
		return;

	if (zzW.IsA('SniperRifle') || zzW.IsA('AssaultRifle'))
		xxSniperPostRender(zzCanvas, zzP);
	else if (zzW.IsA('UT_Eightball'))
		xxRocketPostRender(zzCanvas, zzP);
	else if (zzW.IsA('WarheadLauncher'))
		xxRedeemerPostRender(zzCanvas, zzP);
}

static simulated function xxSniperPostRender(Canvas zzCanvas, PlayerPawn zzP)
{
	local Weapon zzW;
	local float zzScale;

	zzW = zzP.Weapon;
	if ( (zzP != None) && (zzP.DesiredFOV != zzP.DefaultFOV) ) 
	{
		zzW.bOwnsCrossHair = true;
		zzScale = zzCanvas.ClipX/640;
		zzCanvas.SetPos(0.5 * zzCanvas.ClipX - 128 * zzScale, 0.5 * zzCanvas.ClipY - 128 * zzScale );
		if ( zzP.Level.bHighDetailMode )
			zzCanvas.Style = ERenderStyle.STY_Translucent;
		else
			zzCanvas.Style = ERenderStyle.STY_Normal;
		zzCanvas.DrawIcon(Texture'RReticle', zzScale);
		zzCanvas.SetPos(0.5 * zzCanvas.ClipX + 64 * zzScale, 0.5 * zzCanvas.ClipY + 96 * zzScale);
		zzCanvas.DrawColor.R = 0;
		zzCanvas.DrawColor.G = 255;
		zzCanvas.DrawColor.B = 0;
		zzScale = zzP.DefaultFOV/zzP.DesiredFOV;
		zzCanvas.DrawText("X"$int(zzScale)$"."$int(10 * zzScale - 10 * int(zzScale)));
	}
	else
		zzW.bOwnsCrossHair = false;
}

static simulated function xxRocketPostRender( canvas zzCanvas, PlayerPawn zzP )
{
	local float zzXScale;
	local Weapon zzW;

	zzW = zzP.Weapon;

	zzW.bOwnsCrossHair = zzW.bLockedOn;
	if ( zzW.bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		zzXScale = FMax(1.0, zzCanvas.ClipX/640.0);
		zzCanvas.SetPos(0.5 * (zzCanvas.ClipX - Texture'Crosshair6'.USize * zzXScale), 0.5 * (zzCanvas.ClipY - Texture'Crosshair6'.VSize * zzXScale));
		zzCanvas.Style = ERenderStyle.STY_Normal;
		zzCanvas.DrawIcon(Texture'Crosshair6', 1.0);
		zzCanvas.Style = 1;	
	}
}

static simulated function xxRedeemerPostRender( canvas zzCanvas, PlayerPawn zzP )
{
	local int zzi, zznumReadouts, zzOldClipX, zzOldClipY;
	local float zzXScale;
	local WarheadLauncher zzW;

	zzW = WarheadLauncher(zzP.Weapon);

	zzW.bOwnsCrossHair = ( zzW.bGuiding || zzW.bShowStatic );

	if ( !zzW.bGuiding )
	{
		if ( !zzW.bShowStatic )
			return;

		zzCanvas.SetPos( 0, 0);
		zzCanvas.Style = ERenderStyle.STY_Normal;
		zzCanvas.DrawIcon(Texture'LadrStatic.Static_a00', FMax(zzCanvas.ClipX, zzCanvas.ClipY)/256.0);
		zzP.ViewTarget = None;
		return;
	}
	zzW.GuidedShell.PostRender(zzCanvas);
	zzOldClipX = zzCanvas.ClipX;
	zzOldClipY = zzCanvas.ClipY;
	zzXScale = FMax(0.5, int(zzCanvas.ClipX/640.0));
	zzCanvas.SetPos( 0.5 * zzOldClipX - 128 * zzXScale, 0.5 * zzOldClipY - 128 * zzXScale );
	if ( zzP.Level.bHighDetailMode )
		zzCanvas.Style = ERenderStyle.STY_Translucent;
	else
		zzCanvas.Style = ERenderStyle.STY_Normal;
	zzCanvas.DrawIcon(Texture'GuidedX', zzXScale);

	zznumReadouts = zzOldClipY/128 + 2;
	for ( zzi = 0; zzi < zznumReadouts; zzi++ )
	{ 
		zzCanvas.SetPos(1,zzW.Scroll + zzi * 128);
		zzW.Scroll--;
		if ( zzW.Scroll < -128 )
			zzW.Scroll = 0;
		zzCanvas.DrawIcon(Texture'Readout', 1.0);
	}
}	

static simulated function DrawImprovedTeamInfo(Canvas Canvas, PureTeamInfo PTI, ChallengeTeamHUD HUD)
{
	local float fW, fH;
	local float fY;
	local int x, i;
	local string s;
	local PlayerReplicationInfo oPRI, pPRI;
	local int Health, Armor, Pads, Shield, Ammo, Other;
	local class<Weapon> cWeapon;
	local float LocN, LocH, LocA, LocO;

	Canvas.Font = HUD.MyFonts.GetSmallestFont( Canvas.ClipX );
	Canvas.StrLen("123456", fW, fH);

	fY = Canvas.ClipY * 0.5;

	oPRI = HUD.PlayerOwner.PlayerReplicationInfo;
/*
	if (oPRI.Team == 0)
		TeamColor = RedColor;
	else
		TeamColor = BlueColor;
*/
	// Draw like:
	// PlayerName (Location) : Weapon (Ammo)
	// Health   Armor   Other
	LocN = 5.0;
	LocH = LocN;
	LocA = LocH + fW;
	LocO = LocA + fW;

	for (x = 0; x < 32; x++)
	{
		PTI.xxGetData(x, oPRI, pPRI, Health, cWeapon, Ammo, Armor, Pads, Shield, Other);
		if (pPRI == None)
			continue;

		// PlayerName (Location):(Health%)  
		Canvas.DrawColor = HUD.WhiteColor;

		if ( pPRI.PlayerLocation != None )
			s = pPRI.PlayerLocation.LocationName;
		else if ( pPRI.PlayerZone != None )
			s = pPRI.PlayerZone.ZoneName;
		else 
			s = "";
		if (s != "")
			s = " ("$s$")";

		if (cWeapon == None)
			s = s$": No weapon";
		else
			s = s$":"@cWeapon.Default.ItemName$" ("$Ammo$")";

		Canvas.SetPos(LocN, fY);
		Canvas.DrawText(pPRI.PlayerName$s);

		fY += fH;
		
		// 199->121 = green, 120-81 = blueish, 80-41 = yellow, 40-0 = red
		if (Health > 120)
			Canvas.DrawColor = HUD.GreenColor;
		else if (Health > 80)
			Canvas.DrawColor = HUD.CyanColor;
		else if (Health > 40)
			Canvas.DrawColor = HUD.GoldColor;
		else
			Canvas.DrawColor = HUD.RedColor;
		Canvas.SetPos(LocH, fY);
		Canvas.DrawText(Health$"% ");

		i = Armor + Pads + Shield;
		if (i > 0)
		{
			if (Shield > 0)
				Canvas.DrawColor = HUD.GoldColor;
			else
				Canvas.DrawColor = HUD.WhiteColor;
			Canvas.SetPos(LocA, fY);
			Canvas.DrawText(i$"A ");
		}

		Canvas.DrawColor = HUD.WhiteColor;
		s = "";
		if ((Other & 1) != 0)
			s = s@"Boots";
		if ((Other & 2) != 0)
			s = s@"Amp";
		if ((Other & 4) != 0)
			s = s@"Invis";
		if (CTFFlag(pPRI.HasFlag) != None && PureFlag(pPRI.HasFlag) == None)
			s = s@"*** FLAGCARRIER ***";
		Canvas.SetPos(LocO, fY);
		Canvas.DrawText(s);		
		
		fY += (fH * 1.5);
		if (fY > Canvas.ClipY)
			break;		// Too many.
	}

}

static simulated function DrawTime(Canvas Canvas, float X, float Y, int Seconds)
{
	local int Min, Sec;
	local string Time;
	local float fX, fY;
	
//	Min = GRI.RemainingTime;
//	if (Min == 0)
//		Min = GRI.ElapsedTime;
	Seconds = Abs(Seconds);

	Min = Seconds / 60;
	Sec = Seconds % 60;

	Time = string(Min)$":";
	if (Sec < 10)
		Time = Time$"0"$string(Sec);
	else
		Time = Time$string(Sec);

	Canvas.StrLen(Time, fX, fY);
	Canvas.SetPos(X - fX * 0.5, Y - fY * 0.5);
	Canvas.DrawText(Time);
}

static simulated function TimeFont(Canvas Canvas, float Scale, FontInfo MyFonts)
{
	if (Scale > 0.5)
		Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
	else if (Scale > 0.3)
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
	else if (Scale > 0.2)
		Canvas.Font = MyFonts.GetMediumFont(Canvas.ClipX);
	else if (Scale > 0.1)
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
	else
		Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);
}

defaultproperties {
}
