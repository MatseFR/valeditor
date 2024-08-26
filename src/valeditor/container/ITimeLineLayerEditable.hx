package valeditor.container;
import openfl.events.IEventDispatcher;
import valeditor.container.ITimeLineContainerEditable;

/**
 * @author Matse
 */
interface ITimeLineLayerEditable extends IEventDispatcher
{
	public var allObjects(default, null):Array<ValEditorObject>;
	public var container(get, set):ITimeLineContainerEditable;
	public var index(get, set):Int;
	public var locked(get, set):Bool;
	public var name(get, set):String;
	public var selected(get, set):Bool;
	public var timeLine(default, null):ValEditorTimeLine;
	public var visible(get, set):Bool;
	
	function clear():Void;
	function pool():Void;
	function canAddObject():Bool;
	function addObject(object:ValEditorObject):Void;
	function removeObject(object:ValEditorObject):Void;
	function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>;
	function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>;
	function hasVisibleObject():Bool;
	function indexUpdate(newIndex:Int):Void;
	function cloneTo(layer:ITimeLineLayerEditable):Void;
	function fromJSONSave(json:Dynamic):Void;
	function toJSONSave(json:Dynamic = null):Dynamic;
}