package valeditor;
import valedit.ValEditClass;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClass extends ValEditClass 
{
	static private var _POOL:Array<ValEditorClass> = new Array<ValEditorClass>();
	
	static public function fromPool(classReference:Class<Dynamic>):ValEditorClass
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(classReference);
		return new ValEditorClass(classReference);
	}
	
	public var canBeCreated:Bool;
	public var categories(default, null):Array<String> = new Array<String>();
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasTransformProperty:Bool;
	public var hasVisibleProperty:Bool;	
	public var hasRadianRotation:Bool;
	public var interactiveFactory:ValEditorObject->IInteractiveObject;

	public function new(classReference:Class<Dynamic>)//, ?className:String, ?objectCollection:ExposedCollection, canBeCreated:Bool = true, isDisplayObject:Bool = false, ?constructorCollection:ExposedCollection)
	{
		super(classReference, className, objectCollection, isDisplayObject, constructorCollection);
		//this.canBeCreated = canBeCreated;
	}
	
	override public function clear():Void 
	{
		this.canBeCreated = false;
		this.categories.resize(0);
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformationMatrixProperty = false;
		this.hasTransformProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.interactiveFactory = null;
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addCategory(category:String):Void
	{
		this.categories.push(category);
	}
	
}