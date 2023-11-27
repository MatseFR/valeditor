package valeditor;

import openfl.display.BitmapData;
import valedit.ValEditClassSettings;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClassSettings extends ValEditClassSettings 
{
	static private var _POOL:Array<ValEditorClassSettings> = new Array<ValEditorClassSettings>();
	
	static public function fromPool():ValEditorClassSettings
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorClassSettings();
	}
	
	/** @default true **/
	public var canBeCreated:Bool = true;
	
	/** @default null **/
	public var categories:Array<String> = new Array<String>();
	
	/** tells if object uses radian rotation
	 *  @default false */
	public var hasRadianRotation:Bool;
	
	public var iconBitmapData:BitmapData;
	
	/** function that will create the clickable/touchable object for that object.
	 *  this is only useful if isDisplayObject is set to true **/
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	
	/** tells if pivot values should be scaled when clicking/moving object
	 *  @default false */
	public var usePivotScaling:Bool;

	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		super.clear();
		
		this.canBeCreated = true;
		this.categories.resize(0);
		this.hasRadianRotation = false;
		this.iconBitmapData = null;
		this.interactiveFactory = null;
		this.usePivotScaling = false;
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addCategory(category:String):Void
	{
		this.categories[this.categories.length] = category;
	}
	
}