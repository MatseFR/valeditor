package valeditor.ui;

/**
 * @author Matse
 */
interface IInteractiveObject 
{
	public var visibilityLocked:Bool;
	function hasInterestIn(regularPropertyName:String):Bool;
	function objectUpdate(object:ValEditorObject):Void;
	function pool():Void;
}