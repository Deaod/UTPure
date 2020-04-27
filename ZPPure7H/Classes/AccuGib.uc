//================================================================================
// AccuGib.
//================================================================================
class AccuGib expands Zeroping;

var name AmmoName;

function AddMutator (Mutator M)
{
	if ( M.IsA('zp_Arena') || M.IsA('SuperShock') )
	{
		Log(string(M) $ " not allowed (does not work with AccuGib)");
		return;
	}
	Super.AddMutator(M);
}

function bool CheckReplacement (Actor Other, out byte bSuperRelevant)
{
	if ( Other == None )
		return False;

	if ( Other.IsA('TournamentHealth') || Other.IsA('UT_ShieldBelt') || Other.IsA('Armor2') || Other.IsA('ThighPads') || Other.IsA('UT_invisibility') || Other.IsA('UDamage') )
		return False;

	if ( Other.IsA('Translocator') && bAllowTranslocator)
		return True;

	if ( Other.IsA('Weapon') && (Other.Class != DefaultWeapon) )
		return False;

	if ( Other.IsA('Ammo') &&  !Other.IsA(AmmoName) )
		return False;

	if ( Other.IsA('zp_SuperShockRifle') )
		Weapon(Other).PickupAmmoCount=Weapon(Other).AmmoName.Default.MaxAmmo;

	if (  !Super.CheckReplacement(Other,bSuperRelevant) )
		return False;
	return True;
}

defaultproperties
{
    AmmoName=SuperShockCore
    DefaultWeapon=Class'zp_SuperShockRifle'
}
