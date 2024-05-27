package valeditor;
import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventType;
import valedit.IValEditContainer;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valedit.ValEditTimeLine;

/**
 * @author Matse
 */
interface IValEditorContainer
{
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var containerUI(default, null):DisplayObjectContainer;
	//public var currentLayer(get, set):ValEditLayer;
	//public var frameIndex(get, set):Int;
	//public var isPlaying(get, never):Bool;
	//public var juggler(get, set):Juggler;
	//public var lastFrameIndex(get, never):Int;
	public var objectCollection(default, null):ArrayCollection<ValEditorObject>;
	public var rootContainer(get, set):DisplayObjectContainer;
	#if starling
	public var rootContainerStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	//public var timeLine(default, null):ValEditTimeLine;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	function add(object:ValEditObject):Void;
	function adjustView():Void;
	function canAddObject():Bool;
	function close():Void;
	function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>;
	function hasVisibleObject():Bool;
	function layerNameExists(name:String):Bool;
	function open():Void;
	//function play():Void;
	function pool():Void;
	function remove(object:ValEditObject):Void;
	//function stop():Void;
	function toJSONSave(json:Dynamic = null):Dynamic;
	
	function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	function hasEventListener(type:String):Bool;
	function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void;
	function willTrigger(type:String):Bool;
}