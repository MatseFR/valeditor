package valeditor;
import feathers.data.ArrayCollection;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventType;
import valedit.ValEditObject;
import valeditor.editor.data.ContainerSaveData;

/**
 * @author Matse
 */
interface IValEditorContainer
{
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject>;
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject>;
	public var alpha(get, set):Float;
	public var blendMode(get, set):BlendMode;
	#if starling
	public var blendModeStarling(get, set):String;
	#end
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var container(get, never):DisplayObjectContainer;
	#if starling
	public var containerStarling(get, never):starling.display.DisplayObjectContainer;
	#end
	public var containerUI(default, null):DisplayObjectContainer;
	public var isOpen(get, never):Bool;
	public var rootContainer(get, set):DisplayObjectContainer;
	#if starling
	public var rootContainerStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var visible(get, set):Bool;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	function addObject(object:ValEditObject):Void;
	function adjustView():Void;
	function canAddObject():Bool;
	function close():Void;
	function fromJSONSave(json:Dynamic):Void;
	function getActiveObject(objectID:String):ValEditObject;
	function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getContainerDependencies(data:ContainerSaveData):Void;
	function getObject(objectID:String):ValEditObject;
	function hasActiveObject(objectID:String):Bool;
	function hasObject(objectID:String):Bool;
	function hasVisibleObject():Bool;
	function open():Void;
	function pool():Void;
	function removeObject(object:ValEditObject):Void;
	function toJSONSave(json:Dynamic = null):Dynamic;
	
	function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	function hasEventListener(type:String):Bool;
	function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void;
	function willTrigger(type:String):Bool;
}