package valeditor.ui;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class InteractiveFactories 
{

	static public function openFL_default(object:ValEditObject):IInteractiveObject
	{
		var interactive:InteractiveObjectDefault = InteractiveObjectDefault.fromPool();
		return interactive;
	}
	
	static public function openFL_visible(object:ValEditObject):IInteractiveObject
	{
		var interactive:InteractiveObjectVisible = InteractiveObjectVisible.fromPool();
		return interactive;
	}
	
	#if starling
	static public function starling_default(object:ValEditObject):IInteractiveObject
	{
		var interactive:InteractiveObjectStarlingDefault = InteractiveObjectStarlingDefault.fromPool();
		return interactive;
	}
	
	static public function starling_visible(object:ValEditObject):IInteractiveObject
	{
		var interactive:InteractiveObjectStarlingVisible = InteractiveObjectStarlingVisible.fromPool();
		return interactive;
	}
	
	static public function starling_3D(object:ValEditObject):IInteractiveObject
	{
		var interactive:InteractiveObjectStarling3D = InteractiveObjectStarling3D.fromPool();
		return interactive;
	}
	#end
	
}