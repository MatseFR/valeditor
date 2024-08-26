package valeditor.container;
import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventType;
import valeditor.editor.data.ContainerSaveData;

/**
 * @author Matse
 */
interface IContainerEditable
{
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject>;
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject>;
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var containerUI(default, null):DisplayObjectContainer;
	public var isOpen(get, never):Bool;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	function addObject(object:ValEditorObject):Void;
	function adjustView():Void;
	function canAddObject(object:ValEditorObject):Bool;
	function close():Void;
	function fromJSONSave(json:Dynamic):Void;
	function getActiveObject(objectID:String):ValEditorObject;
	function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getContainerDependencies(data:ContainerSaveData):Void;
	function getObject(objectID:String):ValEditorObject;
	function hasActiveObject(objectID:String):Bool;
	function hasObject(objectID:String):Bool;
	function hasVisibleObject():Bool;
	function open():Void;
	function pool():Void;
	function removeObject(object:ValEditorObject):Void;
	function removeObjectCompletely(object:ValEditorObject):Void;
	function toJSONSave(json:Dynamic = null):Dynamic;
	
	function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	function hasEventListener(type:String):Bool;
	function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void;
	function willTrigger(type:String):Bool;
}