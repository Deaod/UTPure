// ============================================================
// allmodel.Al_ShieldBeltEffect: custom shieldbelt effect.
// This baby allows the mesh to be swapped client-side.
// ============================================================

class Al_ShieldBeltEffect expands UT_ShieldBeltEffect;

simulated function Tick(float DeltaTime)
{
  super.tick(deltatime);
  if (owner != None)
  {
    mesh=owner.mesh; //set it client-side
    drawscale=owner.drawscale; //sk trooper
    prepivot=owner.prepivot;
  }
}

defaultproperties {}
