package valeditor;
import feathers.data.ArrayCollection;
import valedit.IValEditContainer;

/**
 * @author Matse
 */
interface IValEditorContainer extends IValEditContainer
{
	public var objectCollection(default, null):ArrayCollection<ValEditorObject>;
	function open():Void;
	function close():Void;
}