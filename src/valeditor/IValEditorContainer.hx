package valeditor;
import feathers.data.ArrayCollection;
import valedit.IValEditContainer;

/**
 * @author Matse
 */
interface IValEditorContainer extends IValEditContainer
{
	public var objectCollection(default, null):ArrayCollection<ValEditorObject>;
	function layerNameExists(name:String):Bool;
	function open():Void;
	function close():Void;
	function selectAllVisible():Void;
}