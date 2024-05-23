package valeditor;
import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventType;
import valedit.IValEditContainer;
//import valeditor.editor.action.MultiAction;

/**
 * @author Matse
 */
interface IValEditorContainer extends IValEditContainer
{
	public var containerUI(default, null):DisplayObjectContainer;
	public var objectCollection(default, null):ArrayCollection<ValEditorObject>;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	
	function adjustView():Void;
	function canAddObject():Bool;
	function close():Void;
	function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>;
	function hasVisibleObject():Bool;
	function layerNameExists(name:String):Bool;
	function open():Void;
	function toJSONSave(json:Dynamic = null):Dynamic;
	
	function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	function hasEventListener(type:String):Bool;
	function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void;
	function willTrigger(type:String):Bool;
}