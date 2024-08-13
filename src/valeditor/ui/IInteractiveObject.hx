package valeditor.ui;

/**
 * @author Matse
 */
interface IInteractiveObject 
{
	public var debug(get, set):Bool;
	public var debugAlpha(get, set):Float;
	public var debugColor(get, set):Int;
	public var visibilityLocked:Bool;
	function hasInterestIn(regularPropertyName:String):Bool;
	function objectUpdate(object:ValEditorObject):Void;
	function pool():Void;
}