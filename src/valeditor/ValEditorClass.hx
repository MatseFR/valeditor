package valeditor;
import valedit.ExposedCollection;
import valedit.ValEditClass;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClass extends ValEditClass 
{
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformProperty:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasVisibleProperty:Bool;
	
	public var hasRadianRotation:Bool;

	public function new(?classReference:Class<Dynamic>, ?className:String, ?objectCollection:ExposedCollection, canBeCreated:Bool = true, isDisplayObject:Bool = false, ?constructorCollection:ExposedCollection)
	{
		super(classReference, className, objectCollection, canBeCreated, isDisplayObject, constructorCollection);
	}
	
}