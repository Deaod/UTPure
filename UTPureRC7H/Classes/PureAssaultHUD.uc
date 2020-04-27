// ============================================================
// UTPureRC56.PureAssaultHUD: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class PureAssaultHUD expands AssaultHUD;

var ServerInfo zzServerInfo;
var int OverTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (bbPlayer(Owner) != None)
		zzServerInfo = Spawn(bbPlayer(Owner).zzSIType, Owner);
	else
		zzServerInfo = Spawn(ServerInfoClass, Owner);
}

simulated function DrawFragCount(Canvas Canvas)
{
	local float Whiten;
	local int X,Y;
	local float Z;

	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Z = Canvas.ClipY - 128 * Scale;
	else
		Z = Canvas.ClipY - 192 * Scale;

	DrawTimeAt(Canvas, 2, Z);

	if ( PawnOwner.PlayerReplicationInfo == None )
		return;

	Canvas.Style = Style;
	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 63.5 * Scale;
	else
		Y = Canvas.ClipY - 127.5 * Scale;
	if ( bHideAllWeapons )
		X = 0.5 * Canvas.ClipX - 256 * Scale;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawColor = HUDColor; 
	Whiten = Level.TimeSeconds - ScoreTime;
	if ( Whiten < 3.0 )
	{
		if ( HudColor == GoldColor )
			Canvas.DrawColor = WhiteColor;
		else
			Canvas.DrawColor = GoldColor;
		if ( Level.bHighDetailMode )
		{
			Canvas.CurX = X - 64 * Scale;
			Canvas.CurY = Y - 32 * Scale;
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawTile(Texture'BotPack.HUDWeapons', 256 * Scale, 128 * Scale, 0, 128, 256.0, 128.0);
		}
		Canvas.CurX = X;
		Canvas.CurY = Y;
		Whiten = 4 * Whiten - int(4 * Whiten);
		Canvas.DrawColor = Canvas.DrawColor + (HUDColor - Canvas.DrawColor) * Whiten;
	}

	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 128, 128.0, 64.0);
	Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, PawnOwner.PlayerReplicationInfo.Score, X + 40 * Scale, Y + 16 * Scale);
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
	local TournamentGameReplicationInfo GRI;
	local PureTeamInfo PTI;

	GRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	// Draw Team Info.
	if ((bbPlayer(PlayerOwner) != None && bbPlayer(PlayerOwner).zzHUDInfo > 1))
	{
		PTI = PureTeamInfo(GRI.Teams[PlayerOwner.PlayerReplicationInfo.Team]);
		if (PTI != None)
			Class'PureHUDHelper'.Static.DrawImprovedTeamInfo(Canvas, PTI, Self);
	}
	else if (bbCHCoach(PlayerOwner) != None && bbCHCoach(PlayerOwner).CoachTeam != None)
	{
		PTI = PureTeamInfo(GRI.Teams[PlayerOwner.PlayerReplicationInfo.Team]);
		if (PTI != None)
			Class'PureHUDHelper'.Static.DrawImprovedTeamInfo(Canvas, PTI, Self);
	}
}

simulated function DrawTimeAt(Canvas Canvas, float X, float Y)
{
	local int Minutes, Seconds, d;

	if ( PlayerOwner.GameReplicationInfo == None )
		return;

	Canvas.DrawColor = RedColor;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.Style = Style;

	if ( PlayerOwner.GameReplicationInfo.RemainingTime > 0 )
	{
		Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
		Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
	}
	else
	{
		Minutes = 0;
		Seconds = 0;
	}
	
	if ( Minutes > 0 )
	{
		if ( Minutes >= 10 )
		{
			d = Minutes/10;
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, d*25, 0, 25.0, 64.0);
			Canvas.CurX += 7*Scale;
			Minutes= Minutes - 10 * d;
		}
		else
		{
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0);
			Canvas.CurX += 7*Scale;
		}

		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, Minutes*25, 0, 25.0, 64.0);
		Canvas.CurX += 7*Scale;
	} else {
		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0);
		Canvas.CurX += 7*Scale;
	}
	Canvas.CurX -= 4 * Scale;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 32, 64, 25.0, 64.0);
	Canvas.CurX += 3 * Scale;

	d = Seconds/10;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*d, 0, 25.0, 64.0);
	Canvas.CurX += 7*Scale;

	Seconds = Seconds - 10 * d;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*Seconds, 0, 25.0, 64.0);
	Canvas.CurX += 7*Scale;
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	local float XL, YL;

	if ( !Other.IsA('FortStandard') )
		return false;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.DrawColor = RedColor * IdentifyFadeTime * 0.333;
	Canvas.StrLen(IdentifyAssault, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, Canvas.ClipY - 74);
	Canvas.DrawText(IdentifyAssault);

	return true;
}

simulated function HUDSetup(canvas canvas)
{
	local int FontSize;

	bResChanged = (Canvas.ClipX != OldClipX);
	OldClipX = Canvas.ClipX;
		
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner.ViewTarget == None )
		PawnOwner = PlayerOwner;
	else if ( PlayerOwner.ViewTarget.bIsPawn )
		PawnOwner = Pawn(PlayerOwner.ViewTarget);
	else 
		PawnOwner = PlayerOwner;

	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.bNoSmooth = True;

	FontSize = Min(3, HUDScale * Canvas.ClipX/500);
	Scale = (HUDScale * Canvas.ClipX)/1280.0;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

	SolidHUDColor = FavoriteHUDColor * 15.9;
	if ( (Opacity == 16) || !Level.bHighDetailMode )
	{
		Style = ERenderStyle.STY_Normal;
		BaseColor = WhiteColor;
		HUDColor = SolidHUDColor;
	}
	else
	{
		Style = ERenderStyle.STY_Translucent;
		BaseColor = (16 * Opacity + 15) * UnitColor;
		HUDColor = FavoriteHUDColor * (Opacity + 0.9);
	}
	Canvas.DrawColor = BaseColor;
	Canvas.Style = Style;
	bLowRes = ( Canvas.ClipX < 400 );
	if ( bLowRes )
		WeaponScale = 1.0;

	if ( bUseTeamColor && (PawnOwner.PlayerReplicationInfo != None)
		&& (PawnOwner.PlayerReplicationInfo.Team < 4) )
	{
		HUDColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];
		SolidHUDColor = HUDColor;
		if ( Level.bHighDetailMode )
			HUDColor = Opacity * 0.0625 * HUDColor;
	}
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		Canvas.SetPos(Canvas.ClipX - 64 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale);
		Canvas.DrawIcon(TeamIcon[TI.TeamIndex], Scale);
		Canvas.StrLen(int(TI.Score), XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 66 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale + ((64 * Scale) - YL)/2 );
		Canvas.DrawText(int(TI.Score), false);
	}
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	if ( type == 0 )
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
	else
		Canvas.DrawColor = TeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;

}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL;
	local Pawn P;

	if ( !TraceIdentify(Canvas))
		return false;

	if( IdentifyTarget.PlayerName != "" )
	{
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
		DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 256 * Scale);
	}

	Canvas.StrLen("TEST", XL, YL);
	if( PawnOwner.PlayerReplicationInfo.Team == IdentifyTarget.Team )
	{
		P = Pawn(IdentifyTarget.Owner);
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
		if ( P != None )
			DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
	}
	return true;
}

function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
	if ( !bHideHUD && (PawnOwner.PlayerReplicationInfo != None) && !PawnOwner.PlayerReplicationInfo.bIsSpectator )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawColor = FaceTeam;
		Canvas.DrawTile(texture'LadrStatic.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'FacePanel1'.USize, texture'FacePanel1'.VSize);
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset + 4*Scale, 4*Scale);
		Canvas.DrawTile(FaceTexture, YPos - 1*Scale, YPos - 1*Scale, 0, 0, FaceTexture.USize, FaceTexture.VSize);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = FaceColor;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawTile(texture'LadrStatic.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize);
		Canvas.DrawColor = WhiteColor;
	}
}

simulated function DrawDigit(Canvas Canvas, int d, int Step, float UpScale, out byte bMinus )
{
	if ( bMinus == 1 )
	{
		Canvas.CurX -= Step;
		Canvas.DrawTile(Texture'BotPack.HudElements1', UpScale*25, 64*UpScale, 0, 64, 25.0, 64.0);
		bMinus = 0;
	}
	if ( d == 1 )
		Canvas.CurX -= 0.625 * Step;
	else
		Canvas.CurX -= 0.25 * Step;		
	Canvas.DrawTile(Texture'BotPack.HudElements1', UpScale*25, 64*UpScale, d*25, 0, 25.0, 64.0);
	Canvas.CurX += 7*UpScale;
}

// DrawBigNum should already have Canvas set up
// X and Y should be the left most allowed position of the number (will be adjusted right if possible)
simulated function DrawBigNum(Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor)
{
	local int d, Mag, Step;
	local float UpScale;
	local byte bMinus;

	if ( ScaleFactor != 0 )
		UpScale = Scale * ScaleFactor;
	else
		UpScale = Scale;

	Canvas.CurX = X;	
	Canvas.CurY = Y;
	Step = 16 * UpScale;
	if ( Value < 0 )
		bMinus = 1;
	Mag = FMin(9999, Abs(Value));

	if ( Mag >= 1000 )
	{
		Canvas.CurX -= Step;
		d = 0.001 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 1000 * d;
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else if ( Mag >= 100 )
	{
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else
		Canvas.CurX += Step;

	if ( Mag >= 10 )
	{
		d = 0.1 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 10 * d;
	}
	else if ( d > 0 )
		DrawDigit(Canvas, 0, Step, UpScale, bMinus);
	else
		Canvas.CurX += Step;

	DrawDigit(Canvas, Mag, Step, UpScale, bMinus);
}

simulated function DrawStatus(Canvas Canvas)
{
	local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
	Local int ArmorAmount,CurAbs,i;
	Local inventory Inv,BestArmor;
	local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;
	local int BootCharges;

	ArmorAmount = 0;
	CurAbs = 0;
	i = 0;
	BestArmor=None;
	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{ 
		if (Inv.bIsAnArmor) 
		{
			if ( Inv.IsA('UT_Shieldbelt') )
				bShieldbelt = true;
			else if ( Inv.IsA('Thighpads') )
			{
				ThighAmount += Inv.Charge;
				bThighArmor = true;
			}
			else
			{ 
				bChestArmor = true;
				ChestAmount += Inv.Charge;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('UT_JumpBoots') )
		{
			bJumpBoots = true;
			BootCharges = Inv.Charge;
		}
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	if ( !bHideStatus )
	{	
		TPOwner = TournamentPlayer(PawnOwner);
		if ( Canvas.ClipX < 400 )
			bHasDoll = false;
		else if ( TPOwner != None)
		{
			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			if ( BotOwner != None )
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if ( bHasDoll )
		{ 							
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if (PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128*StatScale, 256*StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if ( bShieldBelt )
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if ( bChestArmor )
			{
				ChestAmount = FMin(0.01 * ChestAmount,1);
				Canvas.DrawColor = HUDColor * ChestAmount;
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 0, 128, 64);
			}
			if ( bThighArmor )
			{
				ThighAmount = FMin(0.02 * ThighAmount,1);
				Canvas.DrawColor = HUDColor * ThighAmount;
				Canvas.SetPos(X, 64*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 64, 128, 64);
			}
			if ( bJumpBoots )
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 1 )
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = (WhiteColor - HudColor) * FMin(1, 2 * DamageTime);
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
					}
				}
			}
		}
	}
	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 64 * Scale;
	}
	Canvas.SetPos(X,Y);
	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = WhiteColor * H2 + (HUDColor - WhiteColor) * H1;
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 128, 128.0, 64.0);

	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = Canvas.DrawColor * H2 + (WhiteColor - Canvas.DrawColor) * H1;
	}
	else
		Canvas.DrawColor = WhiteColor;

	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 0;
	}
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 192, 128.0, 64.0);
	if ( bHideStatus && bShieldBelt )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, Min(150,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);

	if ((bbPlayer(PlayerOwner) != None && bbPlayer(PlayerOwner).zzHUDInfo > 0) || bbCHSpectator(PlayerOwner) != None)
	{
		Canvas.DrawColor = HUDColor;
		if ( bHideStatus && bHideAllWeapons )
		{	// Draw in front of Frags
			X = 0.5 * Canvas.ClipX - 384 * Scale;
			Y = Canvas.ClipY - 64 * Scale;				
		}
		else
		{
			X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
			Y = 128 * Scale;
		}
		Canvas.SetPos(X,Y);
		Canvas.DrawTile(Texture'PureTimeBG', 128*Scale, 64*Scale, 0, 0, 128.0, 64.0);
		Canvas.DrawColor = WhiteColor;
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

		i = PlayerOwner.GameReplicationInfo.RemainingTime;
		if (i == 0)
		{
			i = PlayerOwner.GameReplicationInfo.ElapsedTime;
			if (OverTime < 0)
				OverTime = i;
			if (OverTime > 0)
				i = OverTime - i;
		}
		else
			OverTime = -1;
		Class'PureHUDHelper'.Static.DrawTime(Canvas, X + 64 * Scale, Y + 32 * Scale, i);

		if (bJumpBoots)
		{
			Canvas.DrawColor = HUDColor;
			if ( bHideStatus && bHideAllWeapons )
			{	// Draw after ammo.
				X = 0.5 * Canvas.ClipX + 256 * Scale;
				Y = Canvas.ClipY - 64 * Scale;
			}
			else
			{
				X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
				Y = 192 * Scale;
			}
			Canvas.SetPos(X,Y);
			Canvas.DrawTile(Texture'PureBoots', 128*Scale, 64*Scale, 0, 0, 128.0, 64.0);
			Canvas.DrawColor = WhiteColor;
			DrawBigNum(Canvas, BootCharges, X + 4 * Scale, Y + 16 * Scale, 1);
		}
	}
}

simulated function xxDrawAmmo(Canvas Canvas)
{
	local int X,Y;

	Canvas.Style = Style;
	Canvas.DrawColor = HUDColor;
	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 63.5 * Scale;
	else
		Y = Canvas.ClipY - 127.5 * Scale;
	if ( bHideAllWeapons )
		X = 0.5 * Canvas.ClipX + 128 * Scale;
	else
		X = Canvas.ClipX - 128 * Scale;
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 192, 128.0, 64.0);

	if ( (PawnOwner.Weapon == None) || (PawnOwner.Weapon.AmmoType == None) )
		return;

	Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, PawnOwner.Weapon.AmmoType.AmmoAmount, X + 4 * Scale, Y + 16 * Scale);
}

simulated function DrawWeapons(Canvas Canvas)
{
	local Weapon W, WeaponSlot[11];
	local inventory Inv;
	local int i, BaseY, BaseX, Pending, WeapX, WeapY;
	local float AmmoScale, WeaponOffset, WeapScale, WeaponX, TexX, TexY;

	BaseX = 0.5 * (Canvas.ClipX - HudScale * WeaponScale * Canvas.ClipX);
	WeapScale = WeaponScale * Scale;
	Canvas.Style = Style;
	BaseY = Canvas.ClipY - 63.5 * WeapScale;
	WeaponOffset = 0.1 * HUDScale * WeaponScale * Canvas.ClipX;

	if ( PawnOwner.Weapon != None )
	{
		W = PawnOwner.Weapon;
		if ( (Opacity > 8) || !Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Normal;
		WeaponX = BaseX + (W.InventoryGroup - 1) * WeaponOffset;
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawColor = SolidHUDColor;
		Canvas.DrawIcon(W.StatusIcon, WeapScale);
		Canvas.DrawColor = GoldColor;
		Canvas.CurX = WeaponX + 4 * WeapScale;
		Canvas.CurY = BaseY + 4 * WeapScale;
		Canvas.Style = Style;
		if ( W.InventoryGroup == 10 )
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 0, 0, 25.0, 64.0);
		else
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 25*W.InventoryGroup, 0, 25.0, 64.0);

		WeaponSlot[W.InventoryGroup] = W;  
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawTile(Texture'BotPack.HUDWeapons', 128 * WeapScale, 64 * WeapScale, 128, 64, 128, 64);
	}
	if ( Level.bHighDetailMode && (PawnOwner.PendingWeapon != None) )
	{
		Pending = PawnOwner.PendingWeapon.InventoryGroup;
		Canvas.CurX = BaseX + (Pending - 1) * WeaponOffset - 64 * WeapScale;
		Canvas.CurY = Canvas.ClipY - 96 * WeapScale; 
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = GoldColor;
		Canvas.DrawTile(Texture'BotPack.HUDWeapons', 256 * WeapScale, 128 * WeapScale, 0, 128, 256.0, 128.0);
	}
	else
		Pending = 100;

	Canvas.Style = Style;
	i = 0;
	for ( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Inv.IsA('Weapon') && (Inv != PawnOwner.Weapon) )
		{
			W = Weapon(Inv);
			if ( WeaponSlot[W.InventoryGroup] == None )
				WeaponSlot[W.InventoryGroup] = W;
			else if ( (WeaponSlot[W.InventoryGroup] != PawnOwner.Weapon)
					&& ((W == PawnOwner.PendingWeapon) || (WeaponSlot[W.InventoryGroup].AutoSwitchPriority < W.AutoSwitchPriority)) )
				WeaponSlot[W.InventoryGroup] = W;
		}
		i++;
		if ( i > 100 )
			break; // can occasionally get temporary loops in netplay
	}
	W = PawnOwner.Weapon;

	// draw weapon list
	TexX = 128 * WeapScale;
	TexY = 64 * WeapScale;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] == None )
		{
			Canvas.Style = Style;
			Canvas.DrawColor =  0.5 * HUDColor;
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;
			
			WeapX = ((i-1)%4) * 64;
			WeapY = ((i-1)/4) * 32;
			Canvas.DrawTile(Texture'BotPack.HUDWeapons',TexX,TexY,WeapX,WeapY,64.0,32.0);
		}
		else if ( WeaponSlot[i] != W )
		{
			if ( Pending == i )
			{
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.DrawColor = SolidHUDColor;
			}
			else
			{
				Canvas.Style = Style;
				Canvas.DrawColor = 0.5 * HUDColor;
			}
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;
			
			if ( WeaponSlot[i].bSpecialIcon )
				Canvas.DrawIcon(WeaponSlot[i].StatusIcon, WeapScale);
			else
			{
				WeapX = ((i-1)%4) * 64;
				WeapY = ((i-1)/4) * 32;
				Canvas.DrawTile(Texture'BotPack.HUDWeapons',TexX,TexY,WeapX,WeapY,64.0,32.0);
			}
		}
	}

	//draw weapon numbers and ammo
	TexX = 0.75 * WeapScale * 25;
	TexY = 0.75 * WeapScale * 64;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] != None )
		{
			WeaponX = BaseX + (i - 1) * WeaponOffset + 4 * WeapScale;
			if ( WeaponSlot[i] != W )
			{
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 4 * WeapScale;
				Canvas.DrawColor = GoldColor;
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				else
					Canvas.Style = Style;
				if ( i == 10 )
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 0, 0, 25.0, 64.0);
				else
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 25*i, 0, 25.0, 64.0);
			}
			if ( WeaponSlot[i].AmmoType != None )
			{
				// Draw Ammo bar
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 52 * WeapScale;
				Canvas.DrawColor = BaseColor;
				AmmoScale = FClamp(88.0 * WeapScale * WeaponSlot[i].AmmoType.AmmoAmount/WeaponSlot[i].AmmoType.MaxAmmo, 0, 88);
				Canvas.DrawTile(Texture'BotPack.HudElements1', AmmoScale, 8 * WeapScale,64,64,128.0,8.0);
			}
		}
	}
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Normal;	

	Canvas.bCenter = True;
	Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	if ( UTIntro(Level.Game) != None )
		YOffset = 64 * scale + 2 * YL;
	else if ( (MOTDFadeOutTime <= 0) || (Canvas.ClipY < 300) )
		YOffset = 64 * scale + 6 * YL;
	else
	{
		YOffset = 64 * scale + 6 * YL;
		GRI = PlayerOwner.GameReplicationInfo;
		if ( GRI != None )
		{
			if ( GRI.MOTDLine1 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine2 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine3 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine4 != "" )
				YOffset += YL;
		}
	}
	for (i=0; i<8; i++)
	{
		Canvas.SetPos(0, YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], False);
		YOffset += YL + 1;
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.bCenter = False;
	HUDSetup(Canvas);	
}

function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
{
	local float YPos, Yadj;
	local float WackNumber;
	local int paneltype;

	YPos = FMax(YL*4 + 8, 70*Scale);
	Yadj = YPos + 7*Scale;
	YPos *=2;
	MinFaceAreaOffset = -1 * Yadj;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = HUDColor * MessageFadeTime;

	Canvas.SetPos(FaceAreaOffset, 0);
	Canvas.DrawTile(texture'LadrStatic.Static_a00', Yadj, Yadj, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize);

	WackNumber = 512*Scale - 64 + FaceAreaOffset; // 256*Scale - (512*Scale - (768*Scale - 64 + FaceAreaOffset));
	if ( !PlayerOwner.Player.Console.bTyping )
		paneltype = 0;
	else 
	{
		Canvas.StrLen("(>"@PlayerOwner.Player.Console.TypedStr$"_", XL, YL);
		if (XL < 768*Scale)
			paneltype = 1;
		else 
			paneltype = 2;
	}

	Canvas.SetPos(Yadj + FaceAreaOffset, 0);
	Canvas.DrawTile(FP1[paneltype], 256*Scale - FaceAreaOffset, YPos, 0, 0, FP1[paneltype].USize, FP1[paneltype].VSize);

	Yadj += 256 * Scale;
	Canvas.SetPos(Yadj, 0);
	Canvas.DrawTile(FP2[paneltype], WackNumber, YPos, 0, 0, FP2[paneltype].USize, FP2[paneltype].VSize);

	Canvas.SetPos(Yadj + WackNumber, 0);
	Canvas.DrawTile(FP3[paneltype], 64, YPos, 0, 0, FP3[paneltype].USize, FP3[paneltype].VSize);

	return False;
}

//========================================
// Master HUD render function.

simulated function PostRender( canvas Canvas )
{
	local float XL, YL, YPos, FadeValue;
	local int M, i, j, k;
	local float OldOriginX;

	HUDSetup(canvas);
	if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
		return;

	if ( bShowInfo )
	{
		if (bbCHSpectator(Owner) != None)
			zzServerInfo.RenderInfo( Canvas );
		else if (bbPlayer(Owner) != None && zzServerInfo.Class == bbPlayer(Owner).zzSIType)
			zzServerInfo.RenderInfo( Canvas );
		return;
	}

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetClip(768*Scale - 10, Canvas.ClipY);
	bDrawFaceArea = false;
	if ( !bHideFaces && !PlayerOwner.bShowScores && !bForceScores && !bHideHUD 
			&& !PawnOwner.PlayerReplicationInfo.bIsSpectator && (Scale >= 0.4) )
	{
		DrawSpeechArea(Canvas, XL, YL);
		bDrawFaceArea = (FaceTexture != None) && (FaceTime > Level.TimeSeconds);
		if ( bDrawFaceArea )
		{
			if ( !bHideHUD && ((PawnOwner.PlayerReplicationInfo == None) || !PawnOwner.PlayerReplicationInfo.bIsSpectator) )
				Canvas.SetOrigin( FMax(YL*4 + 8, 70*Scale) + 7*Scale + 6 + FaceAreaOffset, Canvas.OrgY );
		}
	}

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message != None )
		{
			j++;

			if ( bResChanged || (ShortMessageQueue[i].XL == 0) )
			{
				if ( ShortMessageQueue[i].Message.Default.bComplexString )
					Canvas.StrLen(ShortMessageQueue[i].Message.Static.AssembleString( 
											self,
											ShortMessageQueue[i].Switch,
											ShortMessageQueue[i].RelatedPRI,
											ShortMessageQueue[i].StringMessage), 
								   ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				else
					Canvas.StrLen(ShortMessageQueue[i].StringMessage, ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				Canvas.StrLen("TEST", XL, YL);
				ShortMessageQueue[i].numLines = 1;
				if ( ShortMessageQueue[i].YL > YL )
				{
					ShortMessageQueue[i].numLines++;
					for (k=2; k<4-i; k++)
					{
						if (ShortMessageQueue[i].YL > YL*k)
							ShortMessageQueue[i].numLines++;
					}
				}
			}

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			Canvas.SetPos(6, 2 + YL * YPos);
			YPos += ShortMessageQueue[i].numLines;
			if ( YPos > 4 )
				break; 

			if ( ShortMessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				ShortMessageQueue[i].Message.Static.RenderComplexMessage( 
					Canvas,
					ShortMessageQueue[i].XL,  YL,
					ShortMessageQueue[i].StringMessage,
					ShortMessageQueue[i].Switch,
					ShortMessageQueue[i].RelatedPRI,
					None,
					ShortMessageQueue[i].OptionalObject
					);				
			} 
			else
			{
				Canvas.DrawColor = ShortMessageQueue[i].Message.Default.DrawColor;
				Canvas.DrawText(ShortMessageQueue[i].StringMessage, False);
			}
		}
	}

	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);
	Canvas.SetOrigin(OldOriginX, Canvas.OrgY);

	if ( PlayerOwner.bShowScores || bForceScores )
	{
		if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
		if ( PlayerOwner.Scoring != None )
		{ 
			PlayerOwner.Scoring.OwnerHUD = self;
			PlayerOwner.Scoring.ShowScores(Canvas);
			if ( PlayerOwner.Player.Console.bTyping )
				DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
			return;
		}
	}

	YPos = FMax(YL*4 + 8, 70*Scale);
	if ( bDrawFaceArea )
		DrawTalkFace( Canvas,0, YPos );
	if (j > 0) 
	{
		bDrawMessageArea = True;
		MessageFadeCount = 2;
	} 
	else 
		bDrawMessageArea = False;

	if ( !bHideCenterMessages )
	{
		// Master localized message control loop.
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if (FadeValue > 0.0)
					{
						if ( bResChanged || (LocalMessages[i].XL == 0) )
						{
							if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
								LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
							else // ==2
								LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
							Canvas.Font = LocalMessages[i].StringFont;
							Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
							LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
						}
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
						Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
						Canvas.DrawText( LocalMessages[i].StringMessage, False );
					}
				} 
				else 
				{
					if ( bResChanged || (LocalMessages[i].XL == 0) )
					{
						if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
							LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
						else // == 2
							LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
						LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
					}
					Canvas.Font = LocalMessages[i].StringFont;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.DrawColor = LocalMessages[i].DrawColor;
					Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
					Canvas.DrawText( LocalMessages[i].StringMessage, False );
				}
			}
		}
	}
	Canvas.Style = ERenderStyle.STY_Normal;

	if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
	{
		Canvas.DrawColor = WhiteColor;
		Class'PureHUDHelper'.Static.xxDrawXHair(Canvas, PlayerOwner);
//		PawnOwner.Weapon.PostRender(Canvas);
		if ( !PawnOwner.Weapon.bOwnsCrossHair )
			DrawCrossHair(Canvas, 0,0 );
	}

	if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		Canvas.bCenter = true;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = CyanColor * TutIconBlink;
		Canvas.SetPos(4, Canvas.ClipY - 96 * Scale);
		Canvas.DrawText( LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName, true );
		Canvas.bCenter = false;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = Style;
	}

	if ( bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
	if ( (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) && !bHideCenterMessages )
		DisplayProgressMessage(Canvas);

	// Display MOTD
	if ( MOTDFadeOutTime > 0.0 )
		DrawMOTD(Canvas);
		 
	if( !bHideHUD )
	{
		if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
		{
			Canvas.Style = Style;

			// Draw Ammo
			if ( !bHideAmmo )
				xxDrawAmmo(Canvas);
			
			// Draw Health/Armor status
			DrawStatus(Canvas);

			// Display Weapons
			if ( !bHideAllWeapons )
				DrawWeapons(Canvas);
			else if ( Level.bHighDetailMode
					&& (PawnOwner == PlayerOwner) && (PlayerOwner.Handedness == 2) )
			{
				// if weapon bar hidden and weapon hidden, draw weapon name when it changes
				if ( PawnOwner.PendingWeapon != None )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.PendingWeapon.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.PendingWeapon.ItemName, False);
				}
				else if ( (Level.NetMode == NM_Client)  
						&& PawnOwner.IsA('TournamentPlayer') && (TournamentPlayer(PawnOwner).ClientPending != None) )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = TournamentPlayer(PawnOwner).ClientPending.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(TournamentPlayer(PawnOwner).ClientPending.ItemName, False);
				}
				else if ( (WeaponNameFade > 0) && (PawnOwner.Weapon != None) )
				{
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.Weapon.NameColor;
					if ( WeaponNameFade < 1 )
						Canvas.DrawColor = Canvas.DrawColor * WeaponNameFade;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
				}
			}
			// Display Frag count
			if ( !bAlwaysHideFrags && !bHideFrags )
				DrawFragCount(Canvas);
		}
		// Team Game Synopsis
		if ( !bHideTeamInfo )
			DrawGameSynopsis(Canvas);

		// Display Identification Info
		if ( PawnOwner == PlayerOwner )
			DrawIdentifyInfo(Canvas);

		if ( HUDMutator != None )
			HUDMutator.PostRender(Canvas);

		if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) ) 
		{
			if ( TimeMessageClass == None )
				TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

			if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300)
			  && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
			{
				LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
				if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
				{
					bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );	
					if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
						TellTime(5);
					else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
						TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
				}
				else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
				{
					M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
					TellTime(5 - M);
				}
			}
		}
	}
	if ( PlayerOwner.Player.Console.bTyping )
		DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

	if ( PlayerOwner.bBadConnectionAlert && (PlayerOwner.Level.TimeSeconds > 5) )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (64*Scale), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'DisconnectWarn', Scale);
	}
}

simulated function DrawMOTD(Canvas Canvas)
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local float InitialY;

	GRI = PlayerPawn(Owner).GameReplicationInfo;
	if ( (GRI == None) || (GRI.GameName == "Game") || (MOTDFadeOutTime <= 0) ) 
		return;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.Style = Style;
	Canvas.bCenter = true;
	Canvas.DrawColor = UnitColor * MOTDFadeOutTime * 0.5;
	InitialY = 64*Scale;
	Canvas.SetPos(0.0, InitialY);
	Canvas.StrLen("TEST", XL, YL);
	if ( Level.NetMode != NM_Standalone )
	{
		Canvas.DrawText(GRI.ServerName);
		if ( Canvas.ClipY >= 300 )
		{
			Canvas.SetPos(0.0, InitialY + 6*YL);
			Canvas.DrawText(GRI.MOTDLine1, true);
			Canvas.SetPos(0.0, InitialY + 7*YL);
			Canvas.DrawText(GRI.MOTDLine2, true);
			Canvas.SetPos(0.0, InitialY + 8*YL);
			Canvas.DrawText(GRI.MOTDLine3, true);
			Canvas.SetPos(0.0, InitialY + 9*YL);
			Canvas.DrawText(GRI.MOTDLine4, true);
		}
	}
	Canvas.DrawColor = UnitColor * MOTDFadeOutTime * 0.6;
	Canvas.SetPos(0.0, InitialY + YL);
	Canvas.DrawText(GRI.GameName, true);
	Canvas.SetPos(0.0, InitialY + 2*YL);
	Canvas.DrawText(MapTitleString2@Level.Title, true);
	if ( Canvas.ClipY >= 300 )
	{
		Canvas.SetPos(0.0, InitialY + 3*YL);
		Canvas.DrawText(AuthorString2@Level.Author, true);
		if (Level.IdealPlayerCount != "")
		{
			Canvas.SetPos(0.0, InitialY + 4*YL);
			Canvas.DrawText(PlayerCountString$Level.IdealPlayerCount, true);
		}
	}
	Canvas.bCenter = false;
}

simulated function DrawCrossHair( canvas Canvas, int X, int Y)
{
	local float XScale, PickDiff;
	local float XLength;
	local texture T;

 	if (Crosshair>=CrosshairCount) Return;
	if ( Canvas.ClipX < 512 )
		XScale = 0.5;
	else
		XScale = FMax(1, int(0.1 + Canvas.ClipX/640.0));
	PickDiff = Level.TimeSeconds - PickupTime;
	if ( PickDiff < 0.4 )
	{
		if ( PickDiff < 0.2 )
			XScale *= (1 + 5 * PickDiff);
		else
			XScale *= (3 - 5 * PickDiff);
	}
	XLength = XScale * 64.0;

	Canvas.bNoSmooth = False;
	if ( PlayerOwner.Handedness == -1 )
		Canvas.SetPos(0.503 * (Canvas.ClipX - XLength), 0.504 * (Canvas.ClipY - XLength));
	else if ( PlayerOwner.Handedness == 1 )
		Canvas.SetPos(0.497 * (Canvas.ClipX - XLength), 0.496 * (Canvas.ClipY - XLength));
	else
		Canvas.SetPos(0.5 * (Canvas.ClipX - XLength), 0.5 * (Canvas.ClipY - XLength));
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = 15 * CrosshairColor;

	T = CrossHairTextures[Crosshair];
	if( T == None )
		T = LoadCrosshair(Crosshair);

	Canvas.DrawTile(T, XLength, XLength, 0, 0, 64, 64);
	Canvas.bNoSmooth = True;
	Canvas.Style = Style;
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
	local string TypingPrompt;
	local float XL, YL, YPos, XOffset;
	local float MyOldClipX, OldClipY, OldOrgX, OldOrgY;

	MyOldClipX = Canvas.ClipX;
	OldClipY = Canvas.ClipY;
	OldOrgX = Canvas.OrgX;
	OldOrgY = Canvas.OrgY;

	Canvas.DrawColor = GreenColor;
	TypingPrompt = "(>"@Console.TypedStr$"_";
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen( "TEST", XL, YL );
	YPos = YL*4 + 8;
	if (PawnOwner.PlayerReplicationInfo.bIsSpectator || bHideHUD || bHideFaces)
		XOffset = 0;
	else
		XOffset = FMax(0,FaceAreaOffset + 15*Scale + YPos);
	Canvas.SetOrigin(XOffset, FMax(0,YPos + 7*Scale));
	Canvas.SetClip( 760*Scale, Canvas.ClipY );
	Canvas.SetPos( 0, 0 );
	Canvas.DrawText( TypingPrompt, false );
	Canvas.SetOrigin( OldOrgX, OldOrgY );
	Canvas.SetClip( MyOldClipX, OldClipY );
}

simulated function bool DisplayMessages( canvas Canvas )
{
	return true;
}

simulated function float DrawNextMessagePart(Canvas Canvas, string MString, float XOffset, int YPos)
{
	local float XL, YL;

	Canvas.SetPos(4 + XOffset, YPos);
	Canvas.StrLen( MString, XL, YL );
	Canvas.DrawText( MString, false );
	return (XOffset + XL);
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * 1000.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		if ( Pawn(Other).bIsPlayer && !Other.bHidden )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 3.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
		return false;

	return true;
}

simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
{
	local float XL, YL, XOffset, X1;

	Canvas.Style = Style;
	Canvas.StrLen(TitleString$": ", XL, YL);
	X1 = XL;
	Canvas.StrLen(ValueString, XL, YL);
	XOffset = Canvas.ClipX/2 - (X1+XL)/2;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,0);
	XOffset += X1;
	Canvas.DrawText(TitleString);
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,1);
	Canvas.DrawText(ValueString);
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
}

simulated event PreRender( canvas Canvas );

defaultproperties {
	ServerInfoClass=Class'PureServerInfoAS'
}
