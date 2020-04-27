// ============================================================
// allmodel.ALPlayerMeshClient: allows unreali animation and such
// mine and psychic's code
// ============================================================

class ALPlayerMeshClient expands UMenuPlayerMeshClient;
function created()
{
  super.created();
  if ((string(meshactor.mesh)~="UnrealI.sktrooper") || 
(string(MeshActor.Mesh)~="OldModels.SelectSkTrooper"))
    meshactor.drawscale=0.065000;          //make it fit :D
    // Psychic_313: made it even smaller, it still didn't fit :-)
  else
    meshactor.drawscale=0.100000;
}


function SetMesh(mesh NewMesh)
{
  
  MeshActor.bMeshEnviroMap = False;
  MeshActor.DrawScale = MeshActor.Default.DrawScale;
  MeshActor.SkelAnim = None; // Psychic_313: fix skeletal meshes. Important!
  MeshActor.Mesh = NewMesh;
  if(MeshActor.Mesh != None)
  {
    //HASANIM  the code never before used
    //for normals....
    if(MeshActor.HasAnim ('Breath3'))
      MeshActor.PlayAnim('Breath3', 0.5);
    //Unreal I humans and broken skeletal models
    else if(MeshActor.HasAnim ('Look'))
      MeshActor.Loopanim('Look', 0.7);
    //cow
    else if(MeshActor.HasAnim ('Poop'))
      MeshActor.Loopanim('Poop');
    //anything else that might come in the future...
    else if(MeshActor.HasAnim ('Breath'))
      MeshActor.LoopAnim('Breath');
    else if(MeshActor.HasAnim ('Breath1'))
      MeshActor.LoopAnim('Breath1');
    else if(MeshActor.HasAnim ('Breath2'))
      MeshActor.LoopAnim('Breath2');
    else if(MeshActor.HasAnim ('Fighter'))
      MeshActor.LoopAnim('Fighter');
    //the final test... will look very weird on most models
    else
   {
    log("Warning: ALPlayerMeshClient's model "$MeshActor.Mesh$" is reverting to 'All' animation!");
      MeshActor.LoopAnim('All');
   }
  }
}
function AnimEnd(MeshActor MyMesh)
{
  if ( MyMesh.AnimSequence == 'Breath3' )
  {
    if (MyMesh.HasAnim('DuckDnlgfr')&&!MyMesh.HasAnim('alltrue'))
      //HL model fix (new ones don't need fixing)
      MyMesh.TweenAnim('breath2', 0.4);
    else
      MyMesh.TweenAnim('All', 0.4);
  } else if (MyMesh.HasAnim('Breath3'))
    MyMesh.PlayAnim('Breath3', 0.4);
}

defaultproperties {
}
