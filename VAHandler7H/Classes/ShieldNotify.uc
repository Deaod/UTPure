// ============================================================
// allmodel.ShieldNotify: server-side spawn notification of shield effect.
// Needed so that a custom effect which sets the mesh via the owner CLIENT-SIDE
// This is not replicated.
// ============================================================

class ShieldNotify expands SpawnNotify;

event Actor SpawnNotification( Actor A )
{
   A.Destroy();
   return Spawn( class'AL_ShieldBeltEffect', a.owner ,,a.owner.Location, a.owner.Rotation);
}
defaultproperties {
bAlwaysRelevant=False
remoterole=role_none
Actorclass=class'UT_ShieldBeltEffect';
}
