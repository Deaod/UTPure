// ============================================================
// VAbeta2.VAGibber: designed to spawn gibs on client-side
// only real way to handle temp stuff..
// ============================================================

class VAGibber expands Actor;
var alcarcass zzmycarc;
var bool zzbgib; //whether anim player or just gib.

replication{
  reliable if (role==role_authority)
    zzmycarc, zzbgib;
}

simulated function postbeginplay(){
settimer(5,false); //should be repped by then.
  if (role==role_authority)
    disable('tick');
  else
    bhidden=true;
}
simulated function timer(){
  destroy();
}

simulated function tick(float delta){
//  if (zzbgib)
  //  texture=Texture'Engine.S_Weapon';
  if (role==role_authority)
    return;
  if (zzmycarc!=none&&zzmycarc.playerowner!=none){
 //   log (self@"proccessing. Chunk?"@zzbgib);
    if (zzbgib) //chunk
      zzmycarc.clientchunk();
    else
      zzmycarc.SetDeathAnim();
    destroy();
  }
}

defaultproperties {
  bNetTemporary=True
  CollisionRadius=0.000000
  CollisionHeight=0.000000
  RemoteRole=ROLE_SimulatedProxy
}
