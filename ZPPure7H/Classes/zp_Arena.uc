//================================================================================
// zp_Arena.
//================================================================================
class zp_Arena expands Zeroping
	abstract;

var name WeaponName;
var name AmmoName;
var string WeaponString;
var string AmmoString;

function AddMutator (Mutator M)
{
	if ( M.IsA('zp_Arena') || M.IsA('AccuGib') || M.IsA('Arena') )
	{
		Log(string(M) $ " not allowed (already have a Zeroping Arena mutator)");
		return;
	}
	Super.AddMutator(M);
}

function bool AlwaysKeep (Actor Other)
{
	local byte bTemp;

//	CheckReplacement(Other,bTemp);
	if ( Other.IsA(WeaponName) )
	{
		CheckReplacement(Other,bTemp);
		Weapon(Other).PickupAmmoCount=Weapon(Other).AmmoName.Default.MaxAmmo;
		return True;
	}
	if ( Other.IsA(AmmoName) )
	{
		Ammo(Other).AmmoAmount=Ammo(Other).MaxAmmo;
		return True;
	}
	if ( NextMutator != None )
	{
		return NextMutator.AlwaysKeep(Other);
	}
	return False;
}

function bool CheckReplacement (Actor Other, out byte bSuperRelevant)
{
	if ( Other == None )
	{
		return False;
	}

	if ( Other.IsA('Translocator') && bAllowTranslocator)
		return True;

	if ( Other.IsA('Weapon'))
	{
		if ( WeaponString == "" )
		{
			return False;
		}
		else
		{
			if ( (WeaponString != "") &&  !Other.IsA(WeaponName) )
			{
				Level.Game.bCoopWeaponMode=False;
				if (Other.Owner != None)
					Other.SetLocation(Other.Owner.Location);
				ReplaceWith(Other,zp_Package $ Class'UTPure'.Default.ThisVer $ WeaponString);
				return False;
			}
		}
	}
	if ( Other.IsA('Ammo') )
	{
		if ( AmmoString == "" )
		{
			return False;
		}
		else
		{
			if ( (AmmoString != "") &&  !Other.IsA(AmmoName) )
			{
				ReplaceWith(Other,AmmoString);
				return False;
			}
		}
	}
	if (  !Super.CheckReplacement(Other,bSuperRelevant) )
	{
		return False;
	}
	bSuperRelevant=0;
	return True;
}

