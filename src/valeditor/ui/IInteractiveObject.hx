package valeditor.ui;

/**
 * @author Matse
 */
interface IInteractiveObject 
{
	function hasInterestIn(regularPropertyName:String):Bool;
	function objectUpdate(object:ValEditorObject):Void;
	function pool():Void;
}