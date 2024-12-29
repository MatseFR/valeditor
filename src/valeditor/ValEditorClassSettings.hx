package valeditor;

import haxe.Constraints.Function;
import openfl.display.BitmapData;
import valedit.ExposedCollection;
import valedit.utils.PropertyMap;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClassSettings
{
	static private var _POOL:Array<ValEditorClassSettings> = new Array<ValEditorClassSettings>();
	
	static public function fromPool():ValEditorClassSettings
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorClassSettings();
	}
	
	/** external/static function of type Dynamic->DisplayObjectContainer->Void to call instead of doing a simple addChild
	 *  This is only useful if isDisplayObject is set to true */
	public var addToDisplayFunction:Function;
	
	/** name of the object's DisplayObjectContainer->Void function to call instead of doing a simple addChild */
	public var addToDisplayFunctionName:String;
	
	/** @default true */
	public var canBeCreated:Bool = true;
	
	/** @default null */
	public var categories:Array<String> = new Array<String>();
	
	/** name of the cloneFrom function, if any */
	public var cloneFromFunctionName:String;
	
	/** name of the cloneTo function, if any */
	public var cloneToFunctionName:String;
	
	/** class collection */
	public var collection:ExposedCollection;
	
	/** constructor collection */
	public var constructorCollection:ExposedCollection;
	
	/** if not null, this function will be used to create objects from this class
	 *  make sure the function's signature matches the constructorCollection (if any) */
	public var creationFunction:Function;
	
	/** If not null, this function will be used to create an object from this class while ValEditor is loading a saved file. 
	 * The function's signature has to match the constructorCollection. */
	public var creationFunctionForLoading:Function;
	
	/** If not null, this function will be used to create a template instance object from this class (taking priority over creationFunction in this case).
	 * The function's signature has to match the constructorCollection. */
	public var creationFunctionForTemplateInstance:Function;
	
	/** external/static function of type Dynamic->Void to call on object creation */
	public var creationInitFunction:Function;
	
	/** name of the object's function to call on object creation */
	public var creationInitFunctionName:String;
	
	/** Name of the event to listen for after creating the object to know when it's ready to use, if any */
	public var creationReadyEventName:String;
	
	/** Name of the object's function to call with a callback after creating the object to know when it's ready to use, if any */
	public var creationReadyRegisterFunctionName:String;
	
	/** external/static function of type Dynamic->Void to call on object destruction */
	public var disposeFunction:Function;
	
	/** name of the object's function to call on object destruction */
	public var disposeFunctionName:String;
	
	/** @default null **/
	public var exportClassName:String;
	
	/** @default "getBounds" **/
	public var getBoundsFunctionName:String = "getBounds";
	
	/** tells if object uses radian rotation
	 *  @default false */
	public var hasRadianRotation:Bool;
	
	public var iconBitmapData:BitmapData;
	
	/** function that will create the clickable/touchable object for that object.
	 *  this is only useful if isDisplayObject is set to true */
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	
	/** set this to true if the class implements IValEditContainer */
	public var isContainer:Bool;
	
	/** set this to true if the class implements IValEditContainerOpenFL */
	public var isContainerOpenFL:Bool;
	
	#if starling
	/** set this to true if the class implements IValEditContainerStarling */
	public var isContainerStarling:Bool;
	#end
	
	/** Set this to true if the object is an OpenFL or Starling DisplayObject.
	 * @default false */
	public var isDisplayObject:Bool;
	
	/** Set this to true if the object is an OpenFL DisplayObject.
	 * @default	false */
	public var isDisplayObjectOpenFL:Bool;
	
	#if starling
	/** Set this to true if the object is a Starling DisplayObject. 
	 * @default false */
	public var isDisplayObjectStarling:Bool;
	#end
	
	/** @default false */
	public var isTimeLineContainer:Bool;
	
	public var propertyMap:PropertyMap;
	
	/** external/static function of type Dynamic->DisplayObjectContainer->Void to call instead of doing a simple removeChild
	 *  This is only useful is isDisplayObject is set to true */
	public var removeFromDisplayFunction:Function;
	
	/** name of the object's DisplayObjectContainer->Void function to call instead of doing a simple removeChild */
	public var removeFromDisplayFunctionName:String;
	
	/* if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	
	/** tells if pivot values should be scaled when clicking/moving object
	 *  @default false */
	public var usePivotScaling:Bool;
	
	public var visibilityCollection:ClassVisibilityCollection;

	public function new() 
	{
		
	}
	
	public function clear():Void 
	{
		this.addToDisplayFunction = null;
		this.addToDisplayFunctionName = null;
		this.canBeCreated = true;
		this.categories.resize(0);
		this.collection = null;
		this.constructorCollection = null;
		this.creationFunction = null;
		this.creationFunctionForLoading = null;
		this.creationFunctionForTemplateInstance = null;
		this.creationInitFunction = null;
		this.creationInitFunctionName = null;
		this.creationReadyEventName = null;
		this.creationReadyRegisterFunctionName = null;
		this.disposeFunction = null;
		this.disposeFunctionName = null;
		this.exportClassName = null;
		this.getBoundsFunctionName = "getBounds";
		this.hasRadianRotation = false;
		this.iconBitmapData = null;
		this.interactiveFactory = null;
		this.isContainer = false;
		this.isContainerOpenFL = false;
		#if starling
		this.isContainerStarling = false;
		#end
		this.isDisplayObject = false;
		this.isDisplayObjectOpenFL = false;
		#if starling
		this.isDisplayObjectStarling = false;
		#end
		this.propertyMap = null;
		this.removeFromDisplayFunction = null;
		this.removeFromDisplayFunctionName = null;
		this.useBounds = false;
		this.usePivotScaling = false;
		this.visibilityCollection = null;
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addCategory(category:String):Void
	{
		this.categories[this.categories.length] = category;
	}
	
}