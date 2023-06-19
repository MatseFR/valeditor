package valeditor;
import valedit.ExposedValue;

import flash.display.DisplayObjectContainer;
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
	public var hasRadianRotation:Bool;

	public function new(?classReference:Class<Dynamic>, ?className:String, ?sourceCollection:ExposedCollection, canBeCreated:Bool = true, objectType:Int = -1, ?constructorCollection:ExposedCollection)
	{
		super(classReference, className, sourceCollection, canBeCreated, objectType, constructorCollection);
	}
	
	override public function addContainer(container:DisplayObjectContainer, object:Dynamic, parentValue:ExposedValue = null):ExposedCollection 
	{
		var collection:ExposedCollection = super.addContainer(container, object, parentValue);
		if (Std.isOfType(object, ValEditorObject))
		{
			cast(object, ValEditorObject).collection = collection;
		}
		return collection;
	}
	
	override public function removeContainer(container:DisplayObjectContainer):Void 
	{
		var collection:ExposedCollection = this._containers[container];
		if (collection != null)
		{
			if (Std.isOfType(collection.object, ValEditorObject))
			{
				cast(collection.object, ValEditorObject).collection = null;
			}
		}
		super.removeContainer(container);
	}
	
}