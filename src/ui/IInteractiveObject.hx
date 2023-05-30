package ui;
import valedit.ValEditObject;

/**
 * @author Matse
 */
interface IInteractiveObject 
{
	function hasInterestIn(regularPropertyName:String):Bool;
	function objectUpdate(object:ValEditObject):Void;
	function pool():Void;
}